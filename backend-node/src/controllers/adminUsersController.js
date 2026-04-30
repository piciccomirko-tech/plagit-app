const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const { logAdminAction, extractRequestContext } = require('../services/adminAuditService');
const { sendPasswordResetEmail } = require('../services/emailService');
const AppError = require('../utils/AppError');

// Admin-triggered reset links live longer than the 15-minute self-service
// flow because support staff often need a window to coach the user through
// the email step over a phone call. Still single-use, still single-token-
// per-row, still capped by the active-token rate limit.
const ADMIN_RESET_TTL_MS = 60 * 60 * 1000; // 1 hour
const ADMIN_RESET_MAX_ACTIVE = 3;

// Status / reason guards shared by updateStatus + forcePasswordChange.
// Reason is mandatory at the API layer (audit-log discipline) — kept
// generous (500 chars) so support staff can paste a ticket excerpt.
const ALLOWED_STATUSES = Object.freeze(['active', 'suspended', 'banned']);
const REASON_MIN = 3;
const REASON_MAX = 500;

function normalizeReason(raw) {
  if (typeof raw !== 'string') return null;
  const r = raw.trim();
  if (r.length < REASON_MIN) return null;
  return r.slice(0, REASON_MAX);
}

const SAFE_COLS = ['id','name','initials','email','phone','user_type','admin_role','location','role','status','is_verified','profile_strength','flag_count','avatar_hue','plan','created_at','updated_at'];

async function listUsers(req, res, next) {
  try {
    const { page = 1, limit = 50, status, user_type, search } = req.query;
    let q = db('users');
    if (status) q = q.where('status', status);
    if (user_type) q = q.where('user_type', user_type);
    if (search) q = q.where((b) => b.whereILike('name', `%${search}%`).orWhereILike('email', `%${search}%`).orWhereILike('location', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const users = await q.clone().select(SAFE_COLS).orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, users, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function getUser(req, res, next) {
  try {
    const user = await db('users').select(SAFE_COLS).where({ id: req.params.id }).first();
    if (!user) throw AppError.notFound('User not found.');
    ok(res, user);
  } catch (e) { next(e); }
}

async function updateUser(req, res, next) {
  try {
    const { name, email, role, location, status, is_verified } = req.body;
    const [updated] = await db('users').where({ id: req.params.id })
      .update({ name, email, role, location, status, is_verified, updated_at: db.fn.now() }).returning(SAFE_COLS);
    if (!updated) throw AppError.notFound('User not found.');
    await log(req.user.email, 'Updated user', updated.name, 'Users');
    ok(res, updated);
  } catch (e) { next(e); }
}

// PATCH /admin/users/:id/status
//
// Sets users.status to one of ALLOWED_STATUSES with a mandatory reason
// (>=3 chars). Writes an admin_audit_log row with old/new status. When
// moving INTO suspended/banned we stamp suspended_reason/at/by; when
// moving back to active we clear them. Self-targeting is rejected so an
// admin cannot lock themselves out by mistake.
async function updateStatus(req, res, next) {
  const { id: targetUserId } = req.params;
  const { status, reason: rawReason } = req.body || {};
  const ctx = extractRequestContext(req);

  try {
    if (!ALLOWED_STATUSES.includes(status)) {
      throw AppError.badRequest(
        `Invalid status. Allowed: ${ALLOWED_STATUSES.join(', ')}.`,
        'INVALID_STATUS',
      );
    }
    const reason = normalizeReason(rawReason);
    if (!reason) {
      throw AppError.badRequest(
        `A reason of at least ${REASON_MIN} characters is required.`,
        'REASON_REQUIRED',
      );
    }
    if (req.user.id === targetUserId) {
      throw AppError.badRequest(
        'Admins cannot change their own status.',
        'SELF_TARGET_FORBIDDEN',
      );
    }

    const target = await db('users').where({ id: targetUserId }).first();
    if (!target) throw AppError.notFound('User not found.');

    const oldStatus = target.status;
    const upd = { status, updated_at: db.fn.now() };
    if (status === 'suspended' || status === 'banned') {
      upd.suspended_reason = reason;
      upd.suspended_at = db.fn.now();
      upd.suspended_by = req.user.id;
    } else {
      // status === 'active' — wipe the suspension stamp
      upd.suspended_reason = null;
      upd.suspended_at = null;
      upd.suspended_by = null;
    }

    const [u] = await db('users').where({ id: targetUserId }).update(upd).returning(['id','name','status']);

    // Suspending or banning must kick the user out immediately. The
    // /auth/login + /auth/refresh gates would block re-auth anyway, but
    // active sessions hold an access token until expiry — revoking the
    // refresh tokens kills the rotation and effectively ends the session
    // within the access-token TTL.
    let refreshTokensRevoked = 0;
    if (status === 'suspended' || status === 'banned') {
      refreshTokensRevoked = await db('refresh_tokens').where({ user_id: target.id }).del();
    }

    await logAdminAction({
      admin_user_id: req.user.id,
      target_user_id: target.id,
      action: 'status_changed',
      reason,
      result: 'success',
      metadata: {
        old_status: oldStatus,
        new_status: status,
        refresh_tokens_revoked: refreshTokensRevoked,
      },
      ...ctx,
    }, { swallow: true });

    // Keep the legacy admin_logs row so the existing operational UI still works.
    await log(req.user.email, `Set status to ${status}`, u.name, 'Users');

    ok(res, { success: true, status: u.status });
  } catch (e) { next(e); }
}

// POST /admin/users/:id/force-password-change
//
// Marks the user's must_change_password flag so the next successful
// login forces a self-service password rotation. We never read, hash,
// or write the password itself — that path stays in /auth/.
//
// Idempotent: re-issuing on a user who already has the flag set still
// returns 200 and writes a fresh audit row (so we capture every issue).
async function forcePasswordChange(req, res, next) {
  const { id: targetUserId } = req.params;
  const { reason: rawReason } = req.body || {};
  const ctx = extractRequestContext(req);

  try {
    const reason = normalizeReason(rawReason);
    if (!reason) {
      throw AppError.badRequest(
        `A reason of at least ${REASON_MIN} characters is required.`,
        'REASON_REQUIRED',
      );
    }
    if (req.user.id === targetUserId) {
      throw AppError.badRequest(
        'Admins cannot force a password change on themselves.',
        'SELF_TARGET_FORBIDDEN',
      );
    }

    const target = await db('users').where({ id: targetUserId }).first();
    if (!target) throw AppError.notFound('User not found.');

    await db('users').where({ id: target.id }).update({
      must_change_password: true,
      updated_at: db.fn.now(),
    });

    // Kill active sessions so the user cannot keep working under their
    // current refresh token — the gate in /auth/login + /auth/refresh
    // will then force them through the reset flow.
    const revoked = await db('refresh_tokens').where({ user_id: target.id }).del();

    await logAdminAction({
      admin_user_id: req.user.id,
      target_user_id: target.id,
      action: 'force_password_change_required',
      reason,
      result: 'success',
      metadata: {
        previously_required: target.must_change_password === true,
        refresh_tokens_revoked: revoked,
      },
      ...ctx,
    }, { swallow: true });

    ok(res, { success: true });
  } catch (e) { next(e); }
}

// POST /admin/users/:id/set-temp-password
//
// Generates a random strong password server-side, hashes it, writes the
// hash to users.password_hash, flips must_change_password=true, and
// revokes every active refresh token for the target. The plaintext is
// returned ONCE in the response so the super_admin can hand it to the
// user via a secure channel — it is never stored, never logged, never
// re-fetched. The next /auth/login forces the user through the
// reset-password flow (Step 4-bis gate).
//
// Restricted to super_admin (mounted with requireRole('super_admin') in
// the router). support_admin uses send-reset-link instead.
const TEMP_PASSWORD_LENGTH = 16;
const TEMP_PASSWORD_ALPHABET =
  'ABCDEFGHJKLMNPQRSTUVWXYZ' +     // no I/O — easy to confuse
  'abcdefghijkmnpqrstuvwxyz' +     // no l/o
  '23456789' +                     // no 0/1
  '!@#$%&*+-';                     // safe symbols, terminal-paste friendly

function generateTempPassword() {
  // crypto.randomInt is uniform; pulling each char independently is fine
  // because the alphabet covers all four character classes and the
  // length (16) makes "missing class" outcomes vanishingly unlikely.
  // Still, retry up to 5 times in the unlikely case a class is missing.
  for (let attempt = 0; attempt < 5; attempt++) {
    let out = '';
    for (let i = 0; i < TEMP_PASSWORD_LENGTH; i++) {
      out += TEMP_PASSWORD_ALPHABET[crypto.randomInt(0, TEMP_PASSWORD_ALPHABET.length)];
    }
    if (/[A-Z]/.test(out) && /[a-z]/.test(out) && /[0-9]/.test(out)) return out;
  }
  // Fallback: deterministic seed of one char per class plus random tail.
  const tail = Array.from({ length: TEMP_PASSWORD_LENGTH - 4 }, () =>
    TEMP_PASSWORD_ALPHABET[crypto.randomInt(0, TEMP_PASSWORD_ALPHABET.length)],
  ).join('');
  return `Aa1!${tail}`;
}

async function setTempPassword(req, res, next) {
  const { id: targetUserId } = req.params;
  const { reason: rawReason } = req.body || {};
  const ctx = extractRequestContext(req);

  try {
    const reason = normalizeReason(rawReason);
    if (!reason) {
      throw AppError.badRequest(
        `A reason of at least ${REASON_MIN} characters is required.`,
        'REASON_REQUIRED',
      );
    }
    if (req.user.id === targetUserId) {
      throw AppError.badRequest(
        'Admins cannot set a temporary password for themselves.',
        'SELF_TARGET_FORBIDDEN',
      );
    }

    const target = await db('users').where({ id: targetUserId }).first();
    if (!target) throw AppError.notFound('User not found.');

    const tempPassword = generateTempPassword();
    const passwordHash = await bcrypt.hash(tempPassword, 12);

    await db('users').where({ id: target.id }).update({
      password_hash: passwordHash,
      must_change_password: true,
      password_changed_at: db.fn.now(),
      updated_at: db.fn.now(),
    });

    // Kill every existing session — old access tokens stay valid until
    // their JWT expiry but cannot be rotated, so the window collapses
    // to one access-token TTL.
    const refreshTokensRevoked = await db('refresh_tokens')
      .where({ user_id: target.id }).del();

    await logAdminAction({
      admin_user_id: req.user.id,
      target_user_id: target.id,
      action: 'temp_password_set',
      reason,
      result: 'success',
      // NEVER include the plaintext password or the hash here.
      metadata: {
        refresh_tokens_revoked: refreshTokensRevoked,
        password_length: TEMP_PASSWORD_LENGTH,
      },
      ...ctx,
    }, { swallow: true });

    // Plaintext is returned ONLY in this response. We do not persist it
    // anywhere, do not log it, do not include the hash. The super_admin
    // copies it from the UI and hands it to the user out-of-band.
    ok(res, {
      success: true,
      temporary_password: tempPassword,
      message: 'Share this password with the user via a secure channel. It will not be shown again.',
    });
  } catch (err) { next(err); }
}

async function setVerified(req, res, next) {
  try {
    const { verified } = req.body;
    const upd = { is_verified: verified, updated_at: db.fn.now() };
    if (verified) upd.status = 'active';
    const [u] = await db('users').where({ id: req.params.id }).update(upd).returning(['id','name']);
    if (!u) throw AppError.notFound('User not found.');
    await log(req.user.email, verified ? 'Verified user' : 'Unverified user', u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function deleteUser(req, res, next) {
  try {
    const u = await db('users').where({ id: req.params.id }).first();
    if (!u) throw AppError.notFound('User not found.');
    await db('users').where({ id: req.params.id }).del();
    await log(req.user.email, 'Deleted user', u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function sendMessage(req, res, next) {
  try {
    const { subject, body } = req.body;
    const u = await db('users').where({ id: req.params.id }).first();
    if (!u) throw AppError.notFound('User not found.');
    // TODO: integrate real notification service
    await log(req.user.email, `Sent message: ${subject}`, u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// POST /admin/users/:id/send-reset-link
//
// Admin-triggered password reset. The endpoint:
//   - generates a fresh 6-digit code + sha256-hashed token (TTL 1h),
//   - persists in password_reset_tokens (same table the self-service
//     forgot-password flow uses, so the existing /auth/reset-password
//     endpoint validates and consumes them with no extra logic),
//   - emails the code to the USER directly (never returned to the admin),
//   - logs an `admin_audit_log` row with admin_user_id, target_user_id,
//     ip, user-agent, and metadata.ttl_minutes.
//
// Security:
//   - The token and code are NEVER included in the API response.
//   - The reason is optional here (low-risk action) but still recorded
//     when the admin provides one in the request body.
//   - On email-send failure we still record the audit row with
//     result='failed' so the action is traceable, and surface a 502 to
//     the admin so they know the user did not receive it.
// ---------------------------------------------------------------------------
async function sendResetLink(req, res, next) {
  const { id: targetUserId } = req.params;
  const { reason = null } = req.body || {};
  const ctx = extractRequestContext(req);

  try {
    const target = await db('users').where({ id: targetUserId }).first();
    if (!target) throw AppError.notFound('User not found.');

    // Respect the same active-token rate limit used by the self-service
    // flow so an admin cannot accidentally spam the user with codes.
    const activeRow = await db('password_reset_tokens')
      .where({ user_id: target.id, used: false })
      .where('expires_at', '>', db.fn.now())
      .count('* as c').first();
    if (parseInt(activeRow.c, 10) >= ADMIN_RESET_MAX_ACTIVE) {
      await logAdminAction({
        admin_user_id: req.user.id,
        target_user_id: target.id,
        action: 'password_reset_link_sent',
        reason,
        result: 'failed',
        metadata: { error: 'rate_limited', max_active: ADMIN_RESET_MAX_ACTIVE },
        ...ctx,
      }, { swallow: true });
      throw AppError.badRequest(
        'Too many active reset codes for this user. Ask them to use one or wait for expiry.',
        'RESET_RATE_LIMITED',
      );
    }

    const code = String(Math.floor(100000 + Math.random() * 900000));
    const token = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const expiresAt = new Date(Date.now() + ADMIN_RESET_TTL_MS);

    await db('password_reset_tokens').insert({
      user_id: target.id,
      token_hash: tokenHash,
      code,
      expires_at: expiresAt,
    });

    let emailDelivered = true;
    try {
      await sendPasswordResetEmail(target.email, code);
    } catch (e) {
      emailDelivered = false;
      // eslint-disable-next-line no-console
      console.error('[admin/sendResetLink] email failed:', e.message);
    }

    await logAdminAction({
      admin_user_id: req.user.id,
      target_user_id: target.id,
      action: 'password_reset_link_sent',
      reason,
      result: emailDelivered ? 'success' : 'failed',
      metadata: {
        ttl_minutes: ADMIN_RESET_TTL_MS / 60000,
        email_delivered: emailDelivered,
      },
      ...ctx,
    }, { swallow: true });

    if (!emailDelivered) {
      throw AppError.unavailable(
        'Reset code was created but the email could not be sent.',
        'RESET_EMAIL_FAILED',
      );
    }

    // Deliberately minimal response — no token, no code, no expiry timestamp.
    ok(res, { success: true, message: 'Reset code sent to user email.' });
  } catch (err) { next(err); }
}

module.exports = {
  listUsers, getUser, updateUser, updateStatus, setVerified, deleteUser, sendMessage,
  sendResetLink,
  forcePasswordChange,
  setTempPassword,
};

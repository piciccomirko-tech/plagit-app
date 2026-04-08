const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const db = require('../config/db');
const { ok } = require('../utils/response');
const AppError = require('../utils/AppError');

function signAccessToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.user_type, admin_role: user.admin_role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );
}

async function createRefreshToken(userId) {
  const token = crypto.randomBytes(64).toString('hex');
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days
  await db('refresh_tokens').insert({ user_id: userId, token, expires_at: expiresAt });
  return token;
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;
    if (!email || !password) throw AppError.badRequest('Email and password are required.');

    const user = await db('users').where({ email: email.toLowerCase() }).first();
    if (!user) throw AppError.unauthorized('Invalid email or password.');

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) throw AppError.unauthorized('Invalid email or password.');
    if (user.status === 'banned') throw AppError.forbidden('Account is banned.');

    const accessToken = signAccessToken(user);
    const refreshToken = await createRefreshToken(user.id);

    ok(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: { id: user.id, name: user.name, email: user.email, role: user.user_type, admin_role: user.admin_role, is_verified: user.is_verified },
    });
  } catch (err) { next(err); }
}

async function refresh(req, res, next) {
  try {
    const { refresh_token } = req.body;
    if (!refresh_token) throw AppError.badRequest('Refresh token required.');

    const stored = await db('refresh_tokens').where({ token: refresh_token }).first();
    if (!stored || new Date(stored.expires_at) < new Date()) {
      if (stored) await db('refresh_tokens').where({ id: stored.id }).del();
      throw AppError.unauthorized('Invalid or expired refresh token.');
    }

    const user = await db('users').where({ id: stored.user_id }).first();
    if (!user) throw AppError.unauthorized('User not found.');

    // Rotate refresh token
    await db('refresh_tokens').where({ id: stored.id }).del();
    const newAccessToken = signAccessToken(user);
    const newRefreshToken = await createRefreshToken(user.id);

    ok(res, { access_token: newAccessToken, refresh_token: newRefreshToken });
  } catch (err) { next(err); }
}

async function me(req, res, next) {
  try {
    const user = await db('users').where({ id: req.user.id }).first();
    if (!user) throw AppError.notFound('User not found.');
    ok(res, { id: user.id, name: user.name, email: user.email, role: user.user_type, admin_role: user.admin_role, is_verified: user.is_verified, status: user.status });
  } catch (err) { next(err); }
}

async function changePassword(req, res, next) {
  try {
    const { current_password, new_password } = req.body;
    if (!new_password) throw AppError.badRequest('New password is required.');
    if (new_password.length < 12) throw AppError.badRequest('New password must be at least 12 characters.');
    if (!/[A-Z]/.test(new_password)) throw AppError.badRequest('New password must contain at least one uppercase letter.');
    if (!/[a-z]/.test(new_password)) throw AppError.badRequest('New password must contain at least one lowercase letter.');
    if (!/[0-9]/.test(new_password)) throw AppError.badRequest('New password must contain at least one number.');

    const user = await db('users').where({ id: req.user.id }).first();
    if (!user) throw AppError.notFound('User not found.');

    // Validate current password only if provided (optional for authenticated admins)
    if (current_password) {
      const valid = await bcrypt.compare(current_password, user.password_hash);
      if (!valid) throw AppError.unauthorized('Current password is incorrect.');
    }

    const sameAsOld = await bcrypt.compare(new_password, user.password_hash);
    if (sameAsOld) throw AppError.badRequest('New password must be different from the current password.');

    const hash = await bcrypt.hash(new_password, 12);
    await db('users').where({ id: user.id }).update({ password_hash: hash, updated_at: db.fn.now() });

    // Revoke all existing refresh tokens so other sessions must re-login
    await db('refresh_tokens').where({ user_id: user.id }).del();

    ok(res, { message: 'Password changed successfully. Please log in again.' });
  } catch (err) { next(err); }
}

async function forgotPassword(req, res, next) {
  try {
    const { email } = req.body;
    if (!email) throw AppError.badRequest('Email is required.');

    // Always respond the same way to prevent user enumeration
    const genericResponse = 'If an account with that email exists, a reset code has been sent.';

    const user = await db('users').where({ email: email.toLowerCase() }).first();
    if (!user) {
      ok(res, { message: genericResponse });
      return;
    }

    // Rate limit: max 3 active reset tokens per user
    const activeCount = await db('password_reset_tokens')
      .where({ user_id: user.id, used: false })
      .where('expires_at', '>', db.fn.now())
      .count('* as c').first();
    if (parseInt(activeCount.c) >= 3) {
      ok(res, { message: genericResponse });
      return;
    }

    // Generate 6-digit code + secure token
    const code = String(Math.floor(100000 + Math.random() * 900000));
    const token = crypto.randomBytes(32).toString('hex');
    const tokenHash = crypto.createHash('sha256').update(token).digest('hex');
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

    await db('password_reset_tokens').insert({
      user_id: user.id,
      token_hash: tokenHash,
      code,
      expires_at: expiresAt,
    });

    // Send email (falls back to console.log if no RESEND_API_KEY)
    const { sendPasswordResetEmail } = require('../services/emailService');
    await sendPasswordResetEmail(user.email, code);

    ok(res, { message: genericResponse });
  } catch (err) { next(err); }
}

async function resetPassword(req, res, next) {
  try {
    const { email, code, new_password } = req.body;
    if (!email || !code || !new_password) throw AppError.badRequest('Email, code, and new password are required.');
    if (new_password.length < 12) throw AppError.badRequest('Password must be at least 12 characters.');
    if (!/[A-Z]/.test(new_password)) throw AppError.badRequest('Password must contain at least one uppercase letter.');
    if (!/[a-z]/.test(new_password)) throw AppError.badRequest('Password must contain at least one lowercase letter.');
    if (!/[0-9]/.test(new_password)) throw AppError.badRequest('Password must contain at least one number.');

    const user = await db('users').where({ email: email.toLowerCase() }).first();
    if (!user) throw AppError.badRequest('Invalid reset code.');

    // Find valid, unused token with matching code
    const resetToken = await db('password_reset_tokens')
      .where({ user_id: user.id, code, used: false })
      .where('expires_at', '>', db.fn.now())
      .orderBy('created_at', 'desc')
      .first();

    if (!resetToken) throw AppError.badRequest('Invalid or expired reset code.');

    // Mark token as used
    await db('password_reset_tokens').where({ id: resetToken.id }).update({ used: true });

    // Invalidate all other reset tokens for this user
    await db('password_reset_tokens')
      .where({ user_id: user.id, used: false })
      .update({ used: true });

    // Update password
    const hash = await bcrypt.hash(new_password, 12);
    await db('users').where({ id: user.id }).update({ password_hash: hash, updated_at: db.fn.now() });

    // Revoke all refresh tokens
    await db('refresh_tokens').where({ user_id: user.id }).del();

    ok(res, { message: 'Password reset successfully. You can now log in with your new password.' });
  } catch (err) { next(err); }
}

async function logout(req, res, next) {
  try {
    const { refresh_token } = req.body;
    if (refresh_token) await db('refresh_tokens').where({ token: refresh_token }).del();
    ok(res, { success: true });
  } catch (err) { next(err); }
}

async function registerCandidate(req, res, next) {
  try {
    const { name, email, password, role, location, experience, languages, job_type } = req.body;
    if (!name || !email || !password) throw AppError.badRequest('Name, email, and password are required.');
    if (password.length < 8) throw AppError.badRequest('Password must be at least 8 characters.');

    const normalizedEmail = email.toLowerCase().trim();

    // Check duplicate
    const existing = await db('users').where({ email: normalizedEmail }).first();
    if (existing) throw AppError.badRequest('An account with this email already exists.');

    const initials = name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
    const avatarHue = Math.random() * 0.8 + 0.1; // 0.1–0.9
    const hash = await bcrypt.hash(password, 12);

    // Create user
    const [user] = await db('users').insert({
      name, initials, email: normalizedEmail, password_hash: hash,
      user_type: 'candidate', location: location || null, role: role || null,
      status: 'active', avatar_hue: avatarHue, profile_strength: 20,
    }).returning('*');

    // Create candidate record
    await db('candidates').insert({
      user_id: user.id, name, initials,
      role: role || null, location: location || null,
      experience: experience || null, languages: languages || null,
      job_type: job_type || null,
      verification_status: 'new', avatar_hue: avatarHue,
    });

    // Calculate initial profile strength
    let strength = 20;
    if (name) strength += 15;
    if (location) strength += 15;
    if (role) strength += 10;
    if (experience) strength += 15;
    if (languages) strength += 15;
    strength = Math.min(strength, 100);
    await db('users').where({ id: user.id }).update({ profile_strength: strength });

    // Auto-login: issue tokens
    const accessToken = signAccessToken(user);
    const refreshToken = await createRefreshToken(user.id);

    ok(res, {
      access_token: accessToken,
      refresh_token: refreshToken,
      user: { id: user.id, name: user.name, email: user.email, role: user.user_type, is_verified: user.is_verified },
    });
  } catch (err) { next(err); }
}

async function registerBusiness(req, res, next) {
  try {
    const { company_name, contact_person, email, password, venue_type, location,
            required_role, job_type, open_to_international } = req.body;
    if (!company_name || !email || !password) throw AppError.badRequest('Company name, email, and password are required.');
    if (password.length < 8) throw AppError.badRequest('Password must be at least 8 characters.');

    const normalizedEmail = email.toLowerCase().trim();
    const existing = await db('users').where({ email: normalizedEmail }).first();
    if (existing) throw AppError.badRequest('An account with this email already exists.');

    const initials = company_name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
    const avatarHue = Math.random() * 0.8 + 0.1;
    const hash = await bcrypt.hash(password, 12);

    const [user] = await db('users').insert({
      name: contact_person || company_name, initials, email: normalizedEmail, password_hash: hash,
      user_type: 'business', location: location || null,
      status: 'active', avatar_hue: avatarHue, profile_strength: 20,
    }).returning('*');

    await db('businesses').insert({
      user_id: user.id, name: company_name, initials,
      venue_type: venue_type || null, location: location || null,
      required_role: required_role || null, job_type: job_type || null,
      open_to_international: open_to_international || false,
      email: normalizedEmail, avatar_hue: avatarHue,
    });

    const accessToken = signAccessToken(user);
    const refreshToken = await createRefreshToken(user.id);

    ok(res, {
      access_token: accessToken, refresh_token: refreshToken,
      user: { id: user.id, name: user.name, email: user.email, role: user.user_type, is_verified: user.is_verified },
    });
  } catch (err) { next(err); }
}

module.exports = { login, refresh, me, logout, changePassword, forgotPassword, resetPassword, registerCandidate, registerBusiness };

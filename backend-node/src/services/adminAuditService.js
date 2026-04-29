/**
 * Admin Audit Service — append-only log of sensitive admin actions
 * on user accounts.
 *
 * Routed through this single helper so:
 *   1. The action enum is enforced in code (DB stores varchar, but the
 *      service whitelists what callers may pass — anything outside the
 *      list throws and the row is never written).
 *   2. All actions land in `admin_audit_log`, never in the generic
 *      `admin_logs` table — keeps the security trail un-overloaded.
 *   3. Required-field guards live in one place. `admin_user_id` and
 *      `action` are mandatory; rows without them are rejected before
 *      hitting Postgres.
 *   4. Append-only by design: no update/delete helper is exported.
 *      If a row is wrong, write a corrective row.
 *
 * Safety contract:
 *   - Plaintext passwords MUST NEVER be passed in `metadata` or
 *     `reason`. Callers strip them before invoking. The helper itself
 *     does not inspect strings, so this is a code-review rule, not a
 *     runtime check — keep callers honest.
 *   - `password_hash` MUST NEVER be passed in `metadata` either.
 *   - On DB error the helper re-throws by default so the calling
 *     endpoint can fail closed. Pass `{ swallow: true }` only when the
 *     audit row is non-critical to the action's success.
 */

'use strict';

const db = require('../config/db');

/**
 * Whitelist of action codes admins may emit. Keep alphabetical and
 * stable — adding/renaming requires a code review and (if the rename
 * matters historically) a backfill on existing rows.
 */
const ALLOWED_ACTIONS = Object.freeze([
  'account_deleted',
  'email_changed',
  'force_password_change_required',
  'password_reset_link_sent',
  'role_changed',
  'status_changed',
  'temp_password_set',
]);

const ALLOWED_RESULTS = Object.freeze(['success', 'failed']);

/**
 * Pulls IP + User-Agent from an Express request, defensively.
 * Use this in controllers so callers don't have to remember the keys.
 */
function extractRequestContext(req) {
  if (!req) return { ip_address: null, user_agent: null };
  const ua = typeof req.get === 'function' ? req.get('user-agent') : null;
  return {
    ip_address: req.ip || null,
    user_agent: ua || null,
  };
}

/**
 * Append a single audit row.
 *
 * @param {Object} input
 * @param {string} input.admin_user_id   Required. UUID of the admin actor.
 * @param {string} input.action          Required. One of ALLOWED_ACTIONS.
 * @param {string} [input.target_user_id] Optional. UUID of the affected user.
 * @param {string} [input.reason]         Optional free text. Required at
 *                                        the API layer for high-risk
 *                                        actions (temp_password_set,
 *                                        suspend/ban) — enforced by the
 *                                        controllers, not here.
 * @param {Object} [input.metadata]       Optional plain object; serialized
 *                                        as jsonb. MUST NOT contain
 *                                        plaintext passwords or hashes.
 * @param {'success'|'failed'} [input.result='success']
 * @param {string} [input.ip_address]
 * @param {string} [input.user_agent]
 * @param {Object} [opts]
 * @param {boolean} [opts.swallow=false]  When true, DB errors are
 *                                        caught and logged to console
 *                                        but not re-thrown. Use only
 *                                        for non-critical audit calls.
 * @returns {Promise<{id: string} | null>} Inserted row id, or null if
 *          swallow=true and the insert failed.
 */
async function logAdminAction(input, opts = {}) {
  const {
    admin_user_id,
    action,
    target_user_id = null,
    reason = null,
    metadata = null,
    result = 'success',
    ip_address = null,
    user_agent = null,
  } = input || {};
  const { swallow = false } = opts;

  if (!admin_user_id) {
    throw new Error('adminAuditService: admin_user_id is required');
  }
  if (!action) {
    throw new Error('adminAuditService: action is required');
  }
  if (!ALLOWED_ACTIONS.includes(action)) {
    throw new Error(`adminAuditService: action "${action}" is not whitelisted`);
  }
  if (!ALLOWED_RESULTS.includes(result)) {
    throw new Error(`adminAuditService: result "${result}" is invalid`);
  }

  try {
    const [row] = await db('admin_audit_log')
      .insert({
        admin_user_id,
        target_user_id,
        action,
        reason,
        ip_address,
        user_agent,
        metadata: metadata ? JSON.stringify(metadata) : null,
        result,
      })
      .returning('id');
    return row;
  } catch (err) {
    if (swallow) {
      // eslint-disable-next-line no-console
      console.error('[adminAudit] insert failed (swallowed):', err.message);
      return null;
    }
    throw err;
  }
}

module.exports = {
  logAdminAction,
  extractRequestContext,
  ALLOWED_ACTIONS,
  ALLOWED_RESULTS,
};

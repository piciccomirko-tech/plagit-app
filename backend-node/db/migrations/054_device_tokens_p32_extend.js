/**
 * Phase 3.2 — extend `device_tokens` table for production push.
 *
 * The original schema (mig 016) was a minimal placeholder during the
 * SSE-only era. P3.2 layers the columns needed to operate real push
 * notifications without rewriting the table:
 *
 *   • role          — denorm of users.user_type at registration time.
 *                     Lets push fanout query device_tokens by role
 *                     without joining users on every send; matches
 *                     how subscriber.js already filters role:admin.
 *   • apns_token    — optional native APNs token. The primary token
 *                     column stays as the FCM token (FCM bridges to
 *                     APNs natively); apns_token is here for direct
 *                     APNs sends or future audit only.
 *   • device_id     — optional stable device identifier for multi-
 *                     install disambiguation. Nullable — FCM tokens
 *                     are already instance-scoped so this is a
 *                     nice-to-have, not load-bearing.
 *   • revoked_at    — soft-delete timestamp. P3.2 unregister marks
 *                     this column instead of deleting the row so
 *                     audit history survives.
 *
 * Additive ONLY — no column drops, no renames, no constraint
 * tightening. The 44 existing rows backfill `role` from
 * `users.user_type` in a single UPDATE so the post-migration table
 * has no NULL role for live tokens.
 *
 * Idempotent: re-running the migration on a partially-upgraded DB
 * skips column additions that already exist.
 */
exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('device_tokens');
  if (!exists) {
    // Defensive: if mig 016 hasn't run, abort with a clear error
    // rather than create the table out of order.
    throw new Error('device_tokens table missing — run migration 016 first');
  }

  const hasRole       = await knex.schema.hasColumn('device_tokens', 'role');
  const hasApnsToken  = await knex.schema.hasColumn('device_tokens', 'apns_token');
  const hasDeviceId   = await knex.schema.hasColumn('device_tokens', 'device_id');
  const hasRevokedAt  = await knex.schema.hasColumn('device_tokens', 'revoked_at');

  await knex.schema.alterTable('device_tokens', (t) => {
    if (!hasRole)      t.text('role'); // nullable, backfilled below
    if (!hasApnsToken) t.text('apns_token');
    if (!hasDeviceId)  t.text('device_id');
    if (!hasRevokedAt) t.timestamp('revoked_at', { useTz: true });
  });

  // Backfill role from users.user_type for the 44 existing rows
  // (or whatever count is live at migration time). Safe even if the
  // role column already had values — the UPDATE only overwrites NULL.
  if (!hasRole) {
    await knex.raw(`
      UPDATE device_tokens dt
      SET role = u.user_type
      FROM users u
      WHERE dt.user_id = u.id
        AND dt.role IS NULL
    `);
  }

  // Index on (user_id, revoked_at) so the push subscriber's
  // active-token lookup stays O(log n) once the table grows. The
  // existing idx(user_id) from mig 016 stays in place.
  const hasRevokedIdx = (await knex.raw(`
    SELECT indexname FROM pg_indexes
    WHERE tablename = 'device_tokens'
      AND indexname = 'idx_device_tokens_user_active'
  `)).rows.length > 0;
  if (!hasRevokedIdx) {
    await knex.raw(`
      CREATE INDEX idx_device_tokens_user_active
      ON device_tokens (user_id)
      WHERE revoked_at IS NULL
    `);
  }
};

exports.down = async function (knex) {
  // Conservative rollback — drop the additive columns + index. We
  // do NOT undo the role backfill data (the column drop takes the
  // values with it).
  await knex.raw('DROP INDEX IF EXISTS idx_device_tokens_user_active');
  await knex.schema.alterTable('device_tokens', (t) => {
    t.dropColumn('role');
    t.dropColumn('apns_token');
    t.dropColumn('device_id');
    t.dropColumn('revoked_at');
  });
};

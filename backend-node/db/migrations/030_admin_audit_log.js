/**
 * Dedicated audit table for sensitive admin actions on user accounts.
 *
 * The pre-existing `admin_logs` table is too generic (varchar columns,
 * no FK to users, no IP/UA, no enum on action) and is already used for
 * a wide variety of operational events. Overloading it with security-
 * critical actions like "temp password issued" or "force change" would
 * make tamper detection and compliance review harder.
 *
 * `admin_audit_log` has stricter shape:
 *
 *  - admin_user_id       — required FK to users(id), the actor
 *  - target_user_id      — required FK to users(id), the subject
 *  - action              — free varchar at DB level; backend layer
 *                          MUST whitelist against a fixed enum (see
 *                          src/services/adminAuditService.js)
 *  - reason              — free text; required by API layer for
 *                          temp_password_set / status_changed→suspended/banned
 *  - ip_address          — request IP captured from req.ip
 *  - user_agent          — User-Agent header
 *  - metadata            — jsonb for shape-specific fields
 *                          (old_status, new_status, ttl_minutes, etc.)
 *  - result              — 'success' | 'failed' (CHECK enforced)
 *  - created_at          — append-only; no updated_at (audit rows
 *                          are immutable by convention)
 *
 * Two indices for the common admin-UI queries:
 *   1. by target user, recency-first  → "show me everything done to Elena"
 *   2. by admin user, recency-first   → "show me everything Mirko did"
 */

exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('admin_audit_log');
  if (exists) return;

  await knex.schema.createTable('admin_audit_log', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('admin_user_id').notNullable().references('id').inTable('users').onDelete('RESTRICT');
    t.uuid('target_user_id').notNullable().references('id').inTable('users').onDelete('RESTRICT');
    t.string('action', 64).notNullable();
    t.text('reason');
    t.specificType('ip_address', 'inet');
    t.text('user_agent');
    t.jsonb('metadata');
    t.string('result', 16).notNullable().defaultTo('success');
    t.timestamp('created_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
  });

  await knex.raw(`
    ALTER TABLE admin_audit_log
    ADD CONSTRAINT admin_audit_log_result_check
    CHECK (result IN ('success', 'failed'))
  `);

  await knex.raw(`
    CREATE INDEX idx_admin_audit_target
    ON admin_audit_log (target_user_id, created_at DESC)
  `);

  await knex.raw(`
    CREATE INDEX idx_admin_audit_admin
    ON admin_audit_log (admin_user_id, created_at DESC)
  `);
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('admin_audit_log');
};

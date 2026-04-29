/**
 * Admin account-control hardening — user-side security columns.
 *
 * Six additive columns on `users`, all nullable / defaulted so the
 * migration is safe on a populated DB and reversible:
 *
 *  - last_login_at         — refreshed by authController.login() on every
 *                            successful authentication. Read by admin UI
 *                            for support triage. NULL means the user has
 *                            never logged in.
 *  - must_change_password  — hard gate consumed by the login flow: when
 *                            true, the issued JWT carries a reduced
 *                            scope and the client redirects to the
 *                            change-password screen before any other
 *                            action is allowed. Set true by admin
 *                            "force change" and by the temp-password
 *                            issuance flow.
 *  - password_changed_at   — touched whenever password_hash is rotated
 *                            (self-service, reset link, temp password,
 *                            admin-issued temp). Lets us answer
 *                            "is this account hash older than X days?"
 *                            without exposing the hash itself.
 *  - suspended_reason      — free text, mandatory at API level when
 *                            status moves to 'suspended' or 'banned'.
 *  - suspended_at          — when the suspension/ban was applied.
 *  - suspended_by          — admin user.id who applied the action.
 *
 * No column ever stores a plaintext password. password_hash remains
 * the only credential field, hidden from every API serializer.
 */

exports.up = async function (knex) {
  const cols = await Promise.all([
    knex.schema.hasColumn('users', 'last_login_at'),
    knex.schema.hasColumn('users', 'must_change_password'),
    knex.schema.hasColumn('users', 'password_changed_at'),
    knex.schema.hasColumn('users', 'suspended_reason'),
    knex.schema.hasColumn('users', 'suspended_at'),
    knex.schema.hasColumn('users', 'suspended_by'),
  ]);
  const [hasLastLogin, hasMustChange, hasPwChanged, hasSuspReason, hasSuspAt, hasSuspBy] = cols;

  await knex.schema.alterTable('users', (t) => {
    if (!hasLastLogin) t.timestamp('last_login_at', { useTz: true });
    if (!hasMustChange) t.boolean('must_change_password').notNullable().defaultTo(false);
    if (!hasPwChanged) t.timestamp('password_changed_at', { useTz: true });
    if (!hasSuspReason) t.text('suspended_reason');
    if (!hasSuspAt) t.timestamp('suspended_at', { useTz: true });
    if (!hasSuspBy) t.uuid('suspended_by').references('id').inTable('users').onDelete('SET NULL');
  });
};

exports.down = async function (knex) {
  await knex.schema.alterTable('users', (t) => {
    t.dropColumn('suspended_by');
    t.dropColumn('suspended_at');
    t.dropColumn('suspended_reason');
    t.dropColumn('password_changed_at');
    t.dropColumn('must_change_password');
    t.dropColumn('last_login_at');
  });
};

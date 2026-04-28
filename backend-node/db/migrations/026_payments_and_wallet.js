/**
 * Step 1.4 — Payments + credit wallet + credit transactions.
 *
 * THREE tables, all additive, all idempotent.
 *
 * 1. `job_payments`  Phase-1-neutral payment record.
 *    - During Phase 1 only `provider in ('admin','test')` and
 *      `payment_status in ('test_mode','pending','paid_manual',
 *      'comped','refunded','failed')` are populated.
 *    - Phase 2 adds `provider in ('stripe','apple','google')` and
 *      `payment_status in ('paid_stripe','paid_apple','paid_google')`
 *      with NO migration: both columns are plain varchar so the enum
 *      is enforced in the service layer, not the schema. This is the
 *      payment-swap-in pattern Mirko approved.
 *    - `receipt_payload` is JSONB so we can drop entire receipt blobs
 *      from any provider once Phase 2 starts.
 *
 * 2. `business_credit_wallet`  one row per business (created lazily
 *    on first credit grant). Tracks `credits_available` (current
 *    spendable balance) plus lifetime totals for analytics and admin.
 *
 * 3. `business_credit_transactions`  ledger. Every wallet mutation
 *    writes a row here with `delta`, `reason`, and `balance_after`
 *    so we can audit, refund, and reconstruct any wallet's state.
 */

exports.up = async function (knex) {
  // -- job_payments -----------------------------------------------------
  const hasPayments = await knex.schema.hasTable('job_payments');
  if (!hasPayments) {
    await knex.schema.createTable('job_payments', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('business_id').notNullable();
      t.uuid('job_id'); // null for credit-pack purchases
      t.string('product_code', 50).notNullable();

      t.integer('amount_minor').notNullable().defaultTo(0);
      t.string('currency', 3).notNullable().defaultTo('GBP');

      // 'admin' | 'test' | 'stripe' | 'apple' | 'google'
      t.string('provider', 20).notNullable();

      // Provider-side transaction reference (null for admin/test).
      t.string('provider_tx_id', 200);

      // 'test_mode' | 'pending' | 'paid_manual' | 'comped'
      // | 'paid_stripe' | 'paid_apple' | 'paid_google'
      // | 'refunded' | 'failed'
      t.string('payment_status', 30).notNullable().defaultTo('pending');

      // Full provider receipt (Phase 2). Null in Phase 1.
      t.jsonb('receipt_payload');

      t.uuid('admin_user_id'); // who recorded the manual entry, if any
      t.text('notes');

      t.timestamp('verified_at', { useTz: true });
      t.timestamp('refunded_at', { useTz: true });
      t.timestamps(true, true);
    });

    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_payments_business_id_idx
         ON job_payments (business_id)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_payments_status_idx
         ON job_payments (payment_status)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_payments_provider_idx
         ON job_payments (provider)`
    );
  }

  // -- business_credit_wallet ------------------------------------------
  const hasWallet = await knex.schema.hasTable('business_credit_wallet');
  if (!hasWallet) {
    await knex.schema.createTable('business_credit_wallet', (t) => {
      t.uuid('business_id').primary();
      t.integer('credits_available').notNullable().defaultTo(0);
      t.integer('credits_total_purchased').notNullable().defaultTo(0);
      t.integer('credits_total_comped').notNullable().defaultTo(0);
      t.integer('credits_total_spent').notNullable().defaultTo(0);
      t.timestamp('last_recharge_at', { useTz: true });
      t.timestamps(true, true);
    });
  }

  // -- business_credit_transactions ------------------------------------
  const hasTx = await knex.schema.hasTable('business_credit_transactions');
  if (!hasTx) {
    await knex.schema.createTable('business_credit_transactions', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').notNullable();

      // Positive on grant/purchase/refund, negative on spend.
      t.integer('delta').notNullable();

      // 'admin_grant' | 'spend' | 'refund' | 'comped' | 'test_grant' | 'purchase'
      t.string('reason', 30).notNullable();

      t.uuid('job_id');     // set on spend
      t.uuid('payment_id'); // set on purchase
      t.uuid('boost_id');   // set on spend (links wallet → boost)

      t.integer('balance_after').notNullable();

      t.uuid('admin_user_id');
      t.text('notes');

      t.timestamps(true, true);
    });

    await knex.raw(
      `CREATE INDEX IF NOT EXISTS business_credit_tx_business_id_idx
         ON business_credit_transactions (business_id, created_at DESC)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS business_credit_tx_reason_idx
         ON business_credit_transactions (reason)`
    );
  }
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS business_credit_tx_reason_idx');
  await knex.raw('DROP INDEX IF EXISTS business_credit_tx_business_id_idx');
  await knex.schema.dropTableIfExists('business_credit_transactions');
  await knex.schema.dropTableIfExists('business_credit_wallet');

  await knex.raw('DROP INDEX IF EXISTS job_payments_provider_idx');
  await knex.raw('DROP INDEX IF EXISTS job_payments_status_idx');
  await knex.raw('DROP INDEX IF EXISTS job_payments_business_id_idx');
  await knex.schema.dropTableIfExists('job_payments');
};

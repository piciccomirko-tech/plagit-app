/**
 * Payments Step 1 — provider-agnostic premium entitlements.
 *
 * Single source of truth for "is this user premium right now?", independent
 * of which store paid (Apple IAP / Google Play Billing / Stripe). The app
 * reads only a derived `is_premium` (GET /v1/subscription/status) and never
 * branches on the provider.
 *
 *   is_premium = EXISTS row WHERE status IN (active|trialing|past_due)
 *                AND current_period_end > now()  [+ environment gate]
 *
 * UNIQUE (provider, provider_ref) gives idempotency: the verify endpoint and
 * every provider webhook upsert the SAME row, so renewals/cancellations never
 * create duplicates.
 *
 * Scope: candidate-side single product 'plagit_premium' (monthly|yearly).
 * Business tiers (basic/pro/premium) are a separate track — NOT touched here.
 *
 * Additive + idempotent (hasTable guard). Rollback drops the table.
 */
exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('user_entitlements');
  if (exists) return;
  await knex.schema.createTable('user_entitlements', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').notNullable()
      .references('id').inTable('users').onDelete('CASCADE');
    t.string('product', 64).notNullable();   // 'plagit_premium'
    t.string('plan', 16).notNullable();      // 'monthly' | 'yearly'
    t.string('provider', 16).notNullable();  // 'apple' | 'google' | 'stripe'
    t.text('provider_ref').notNullable();    // stable subscription id per provider
    t.string('status', 16).notNullable();    // trialing|active|past_due|cancelled|expired
    t.timestamp('current_period_start', { useTz: true });
    t.timestamp('current_period_end', { useTz: true });
    t.timestamp('trial_end', { useTz: true });
    t.boolean('cancel_at_period_end').notNullable().defaultTo(false);
    t.string('environment', 16).notNullable().defaultTo('production'); // sandbox|production
    t.jsonb('raw_payload'); // last validated provider payload (audit/debug — no secrets)
    t.timestamps(true, true);

    t.unique(['provider', 'provider_ref'], 'user_entitlements_provider_ref_uniq');
    t.index('user_id', 'user_entitlements_user_id_idx');
    t.index(['status', 'current_period_end'], 'user_entitlements_status_period_idx');
  });
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('user_entitlements');
};

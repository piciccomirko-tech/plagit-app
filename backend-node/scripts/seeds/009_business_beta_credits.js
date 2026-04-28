/**
 * Seed 009 — beta credits for every existing business.
 *
 * Mirko-approved Phase 1 rule: each business gets 3 free beta/test
 * credits seeded into the wallet. These are used to exercise the boost
 * flow end-to-end without any real payment integration.
 *
 * Idempotent: re-running this seed does NOT stack credits. We:
 *   1. Insert the wallet row if missing (3 credits available).
 *   2. Skip the credit grant if a 'test_grant' transaction already
 *      exists for that business (so reruns are no-ops).
 *
 * Ledger row uses reason='test_grant' so admin/UI can clearly see
 * these are beta seeds, not real comps and not real purchases.
 */

const BETA_CREDITS = 3;

exports.seed = async function (knex) {
  const businesses = await knex('businesses').select('id');

  for (const b of businesses) {
    // 1. Wallet — insert if missing, otherwise leave existing balance alone.
    const existingWallet = await knex('business_credit_wallet')
      .where({ business_id: b.id })
      .first();

    if (!existingWallet) {
      await knex('business_credit_wallet').insert({
        business_id: b.id,
        credits_available: BETA_CREDITS,
        credits_total_purchased: 0,
        credits_total_comped: 0,
        credits_total_spent: 0,
        last_recharge_at: knex.fn.now(),
      });
    }

    // 2. Ledger — skip if a test_grant row already exists for this business.
    const existingGrant = await knex('business_credit_transactions')
      .where({ business_id: b.id, reason: 'test_grant' })
      .first();

    if (!existingGrant) {
      const wallet = existingWallet || { credits_available: BETA_CREDITS };
      await knex('business_credit_transactions').insert({
        business_id: b.id,
        delta: BETA_CREDITS,
        reason: 'test_grant',
        balance_after: wallet.credits_available,
        notes: 'Phase 1 beta seed — 3 free credits for boost system testing',
      });
    }
  }
};

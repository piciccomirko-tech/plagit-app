/**
 * Seed 008 — `job_products` catalog.
 *
 * UPSERT-style seed (NOT destructive). Re-running this seed on a
 * populated DB updates prices/copy without wiping history. Existing
 * seeds in this directory use `del()` + insert; this one deliberately
 * does NOT, because `job_products` is referenced by `job_payments`,
 * `job_boosts`, and credit transactions.
 *
 * Pricing in MINOR units (pence). UI converts to £xx.xx on read.
 *
 * Apple/Google/Stripe IDs are intentionally null — Phase 2 will fill
 * them when real billing is wired in.
 */

const PRODUCTS = [
  // ── Urgent ─────────────────────────────────────────────────────────
  {
    code: 'urgent_24h',
    name: 'Urgent — 24 hours',
    description: 'Mark your job as Urgent for 24 hours. Adds an Urgent badge and a small visibility lift on relevant matches.',
    boost_type: 'urgent',
    boost_priority: 25,
    duration_hours: 24,
    price_minor: 499,
    sort_order: 10,
  },
  {
    code: 'urgent_3d',
    name: 'Urgent — 3 days',
    description: 'Urgent badge and visibility lift for 3 days.',
    boost_type: 'urgent',
    boost_priority: 30,
    duration_hours: 72,
    price_minor: 999,
    sort_order: 11,
  },
  {
    code: 'urgent_7d',
    name: 'Urgent — 7 days',
    description: 'Urgent badge and visibility lift for a full week.',
    boost_type: 'urgent',
    boost_priority: 35,
    duration_hours: 168,
    price_minor: 1499,
    sort_order: 12,
  },

  // ── Top of List ────────────────────────────────────────────────────
  {
    code: 'top_24h',
    name: 'Top of List — 24 hours',
    description: 'Pin your job near the top for matching candidates for 24 hours.',
    boost_type: 'top',
    boost_priority: 60,
    duration_hours: 24,
    price_minor: 499,
    sort_order: 20,
  },
  {
    code: 'top_3d',
    name: 'Top of List — 3 days',
    description: 'Top placement on relevant searches for 3 days.',
    boost_type: 'top',
    boost_priority: 70,
    duration_hours: 72,
    price_minor: 999,
    sort_order: 21,
  },
  {
    code: 'top_7d',
    name: 'Top of List — 7 days',
    description: 'Top placement on relevant searches for a full week.',
    boost_type: 'top',
    boost_priority: 80,
    duration_hours: 168,
    price_minor: 1999,
    sort_order: 22,
  },

  // ── Featured ───────────────────────────────────────────────────────
  {
    code: 'featured',
    name: 'Featured Job',
    description: 'Premium hero card placement, capped to one Featured every 8 results to stay non-spammy.',
    boost_type: 'featured',
    boost_priority: 50,
    duration_hours: 168, // featured runs 7d by default
    price_minor: 999,
    sort_order: 30,
  },

  // ── Fast Hire Pack (bundle) ────────────────────────────────────────
  {
    code: 'fast_hire_pack',
    name: 'Fast Hire Pack',
    description: 'All-in-one push for a single role: Urgent + Top + Featured for 7 days.',
    boost_type: null, // bundle expanded by service layer
    boost_priority: 0,
    duration_hours: 168,
    price_minor: 2999,
    is_bundle: true,
    bundle_contents: 'urgent_7d + top_7d + featured',
    sort_order: 40,
  },

  // ── Credit Packs (non-boost products) ──────────────────────────────
  {
    code: 'credit_3',
    name: 'Credit Pack — 3 credits',
    description: '3 credits to spend on any boost product.',
    boost_type: null,
    boost_priority: 0,
    duration_hours: null,
    price_minor: 3499,
    credits_granted: 3,
    sort_order: 50,
  },
  {
    code: 'credit_5',
    name: 'Credit Pack — 5 credits',
    description: '5 credits to spend on any boost product.',
    boost_type: null,
    boost_priority: 0,
    duration_hours: null,
    price_minor: 4999,
    credits_granted: 5,
    sort_order: 51,
  },
  {
    code: 'credit_10',
    name: 'Credit Pack — 10 credits',
    description: '10 credits to spend on any boost product.',
    boost_type: null,
    boost_priority: 0,
    duration_hours: null,
    price_minor: 7499,
    credits_granted: 10,
    sort_order: 52,
  },
];

exports.seed = async function (knex) {
  for (const p of PRODUCTS) {
    const row = {
      code: p.code,
      name: p.name,
      description: p.description,
      boost_type: p.boost_type,
      boost_priority: p.boost_priority,
      duration_hours: p.duration_hours,
      price_minor: p.price_minor,
      currency: 'GBP',
      apple_product_id: null,
      google_product_id: null,
      stripe_price_id: null,
      credits_granted: p.credits_granted || 0,
      is_bundle: !!p.is_bundle,
      bundle_contents: p.bundle_contents || null,
      is_active: true,
      sort_order: p.sort_order,
      updated_at: knex.fn.now(),
    };

    await knex('job_products')
      .insert(row)
      .onConflict('code')
      .merge({
        name: row.name,
        description: row.description,
        boost_type: row.boost_type,
        boost_priority: row.boost_priority,
        duration_hours: row.duration_hours,
        price_minor: row.price_minor,
        currency: row.currency,
        credits_granted: row.credits_granted,
        is_bundle: row.is_bundle,
        bundle_contents: row.bundle_contents,
        is_active: row.is_active,
        sort_order: row.sort_order,
        updated_at: row.updated_at,
      });
  }
};

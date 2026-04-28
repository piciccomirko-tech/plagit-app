/**
 * Step 1.2 — `job_products` catalog.
 *
 * Single source of truth for every monetizable job-visibility product.
 * Seeded with the 11 SKUs Mirko approved (see 008_job_products seed):
 *   urgent_24h, urgent_3d, urgent_7d
 *   top_24h, top_3d, top_7d
 *   featured
 *   fast_hire_pack
 *   credit_3, credit_5, credit_10
 *
 * Pricing is stored in **minor units** (pence) to avoid float drift. UI
 * formats as £xx.xx on read.
 *
 * `apple_product_id`, `google_product_id`, and `stripe_price_id` are
 * placeholders — null for the entirety of Phase 1. They exist now so
 * Phase 2 can drop in real store identifiers without touching schema.
 *
 * `boost_type` and `boost_priority` define how the product affects
 * ranking when applied to a job. `duration_hours` defines the window
 * length the cron expiry uses. Credit packs and the fast-hire pack are
 * non-boost products, so `boost_type` is null and `boost_priority` is 0.
 *
 * Idempotent via hasTable check.
 */

exports.up = async function (knex) {
  const hasTable = await knex.schema.hasTable('job_products');
  if (!hasTable) {
    await knex.schema.createTable('job_products', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('code', 50).notNullable().unique();
      t.string('name', 100).notNullable();
      t.text('description');

      // Boost shape (null for non-boost products like credit packs).
      t.string('boost_type', 20);
      t.integer('boost_priority').notNullable().defaultTo(0);
      t.integer('duration_hours');

      // Pricing in minor units (pence).
      t.integer('price_minor').notNullable().defaultTo(0);
      t.string('currency', 3).notNullable().defaultTo('GBP');

      // Phase 2 store identifiers (null in Phase 1).
      t.string('apple_product_id', 100);
      t.string('google_product_id', 100);
      t.string('stripe_price_id', 100);

      // For credit packs only — how many credits this purchase grants.
      t.integer('credits_granted').notNullable().defaultTo(0);

      // For the Fast Hire Pack — counts as a bundle of multiple boosts
      // / job-post entitlements consumed over a window.
      t.boolean('is_bundle').notNullable().defaultTo(false);
      t.text('bundle_contents'); // free-form description for now

      // Catalog control.
      t.boolean('is_active').notNullable().defaultTo(true);
      t.integer('sort_order').notNullable().defaultTo(0);

      t.timestamps(true, true);
    });

    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_products_active_sort_idx
         ON job_products (is_active, sort_order)`
    );
  }
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS job_products_active_sort_idx');
  await knex.schema.dropTableIfExists('job_products');
};

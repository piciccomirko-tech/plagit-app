/**
 * Business Quick Plug daily-swipe tracking.
 *
 * `business_quickplug_swipes` is the per-swipe audit log used to enforce
 * a real, server-side daily cap on how many candidate cards a business
 * can swipe in the Quick Plug deck. Each row is a single swipe action —
 * it is the source of truth for `swipesUsed`, `swipesRemaining`, and
 * `hasReachedLimit` returned by GET /business/quickplug/deck.
 *
 * Both interested=true (shortlist) and interested=false (pass) rows are
 * written. A swipe counts toward the daily cap regardless of direction
 * so a business cannot game the limit by mass-passing.
 *
 * Index on (business_id, swiped_at) keeps the daily count query fast
 * even at scale: WHERE business_id = ? AND swiped_at >= today.
 *
 * No unique constraint on (business_id, candidate_id) — re-swipes after
 * a deck refresh are legal and must each consume a slot.
 */

exports.up = async function (knex) {
  const has = await knex.schema.hasTable('business_quickplug_swipes');
  if (has) return;

  await knex.schema.createTable('business_quickplug_swipes', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('business_id').notNullable();
    t.uuid('candidate_id').notNullable();
    t.boolean('interested').notNullable();
    t.timestamp('swiped_at', { useTz: true })
      .notNullable()
      .defaultTo(knex.fn.now());
    t.index(['business_id', 'swiped_at']);
  });
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('business_quickplug_swipes');
};

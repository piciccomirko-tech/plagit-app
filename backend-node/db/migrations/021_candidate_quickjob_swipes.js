/**
 * Candidate Quick Jobs daily-swipe tracking.
 *
 * `candidate_quickjob_swipes` is the per-swipe audit log used to enforce
 * a real, server-side daily cap on how many cards a candidate can swipe
 * in the Quick Jobs deck. Each row is a single swipe action — it is the
 * source of truth for `swipesUsed`, `swipesRemaining`, and
 * `hasReachedLimit` returned by GET /candidate/quickjobs/deck.
 *
 * Both interested=true and interested=false rows are written. A swipe
 * counts toward the daily cap regardless of direction so the candidate
 * cannot game the limit by mass-passing.
 *
 * Index on (candidate_id, swiped_at) keeps the daily count query fast
 * even at scale: WHERE candidate_id = ? AND swiped_at >= today.
 *
 * No unique constraint on (candidate_id, job_id) — re-swipes after a
 * withdraw or deck refresh are legal and must each consume a slot.
 */

exports.up = async function (knex) {
  const has = await knex.schema.hasTable('candidate_quickjob_swipes');
  if (has) return;

  await knex.schema.createTable('candidate_quickjob_swipes', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('candidate_id').notNullable();
    t.uuid('job_id').notNullable();
    t.boolean('interested').notNullable();
    t.timestamp('swiped_at', { useTz: true })
      .notNullable()
      .defaultTo(knex.fn.now());
    t.index(['candidate_id', 'swiped_at']);
  });
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('candidate_quickjob_swipes');
};

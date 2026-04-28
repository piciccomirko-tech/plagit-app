/**
 * Step 1.5 — `job_visibility_events`.
 *
 * Append-only analytics log for the boost engine. Every meaningful
 * surface event (impression, click, apply, boost lifecycle) writes
 * one row. Powers:
 *   - business-side ROI dashboards ("your boost got 240 impressions
 *     and 9 applies")
 *   - admin revenue / ranking-fairness analytics
 *   - debug per-job ("why isn't this boost converting")
 *
 * `event_type`: 'impression' | 'click' | 'apply' | 'boost_start' |
 *               'boost_end' | 'boost_revoked'
 * `source`:     'list' | 'quickjobs' | 'search' | 'detail' | 'system'
 *
 * `boost_active` is denormalized at write time so analytics queries
 * don't have to time-join against `job_boosts`. It's a snapshot of
 * whether the job was in active-boost state when the event fired.
 *
 * `candidate_id` is null for system events (boost_start, boost_end).
 *
 * Designed for high write volume — minimal columns, no FKs, partial
 * indexes on (job_id, event_type) and (created_at) for time-windowed
 * rollups.
 */

exports.up = async function (knex) {
  const hasTable = await knex.schema.hasTable('job_visibility_events');
  if (!hasTable) {
    await knex.schema.createTable('job_visibility_events', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('job_id').notNullable();
      t.string('event_type', 20).notNullable();
      t.string('source', 20).notNullable().defaultTo('list');

      t.uuid('candidate_id');             // null for system events
      t.boolean('boost_active').notNullable().defaultTo(false);
      t.string('boost_type', 20);         // snapshot, may be null
      t.uuid('boost_id');                 // logical FK to job_boosts.id

      // Optional context bag for things like rank-position-in-list,
      // matchScore at impression time, etc. Kept lightweight.
      t.jsonb('context');

      t.timestamp('created_at', { useTz: true })
        .notNullable()
        .defaultTo(knex.fn.now());
    });

    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_visibility_events_job_event_idx
         ON job_visibility_events (job_id, event_type)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_visibility_events_created_idx
         ON job_visibility_events (created_at DESC)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_visibility_events_boost_id_idx
         ON job_visibility_events (boost_id)
         WHERE boost_id IS NOT NULL`
    );
  }
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS job_visibility_events_boost_id_idx');
  await knex.raw('DROP INDEX IF EXISTS job_visibility_events_created_idx');
  await knex.raw('DROP INDEX IF EXISTS job_visibility_events_job_event_idx');
  await knex.schema.dropTableIfExists('job_visibility_events');
};

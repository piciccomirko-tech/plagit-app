/**
 * Phase 4 — Entity-share attachment support for chat messages.
 *
 * Adds a polymorphic pair of columns so a message can point at any
 * shareable entity (candidate profile, business profile, job posting,
 * interview) without one FK column per type. The pair (type, id)
 * lets the backend route to the right table at lookup time and the
 * client navigate to the right route on tap.
 *
 * Why no FK: the target table changes per `shared_entity_type` value
 * (`candidates` / `businesses` / `jobs` / `interviews`). A polymorphic
 * association keeps the schema flat at the cost of integrity guards
 * — those move to the controller layer (existence check on send)
 * and the listMessages envelope (graceful null on missing entity).
 *
 * Both columns NULLable: existing messages and any future non-share
 * messages leave them NULL. No backfill needed.
 */
exports.up = async (knex) => {
  await knex.schema.alterTable('messages', (t) => {
    // Whitelisted at the controller level:
    //   'profile_candidate' | 'profile_business' | 'job' | 'interview'
    t.text('shared_entity_type').nullable();
    t.uuid('shared_entity_id').nullable();
    // Composite index so listMessages can fetch the matching entities
    // for a thread page in one indexed scan per type, instead of one
    // sequential query per row.
    t.index(
      ['shared_entity_type', 'shared_entity_id'],
      'messages_shared_entity_idx',
    );
  });
};

exports.down = async (knex) => {
  await knex.schema.alterTable('messages', (t) => {
    t.dropIndex(
      ['shared_entity_type', 'shared_entity_id'],
      'messages_shared_entity_idx',
    );
    t.dropColumn('shared_entity_id');
    t.dropColumn('shared_entity_type');
  });
};

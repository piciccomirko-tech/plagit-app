/**
 * Add `delivered_at` timestamp to messages for read-receipts / slice #7.
 *
 *   null       → message sent but never reached a peer device
 *   timestamp  → message delivered to the peer's SSE client (single grey check)
 *   is_read    → message opened in the peer's chat view (double teal check)
 */
exports.up = async function (knex) {
  const has = await knex.schema.hasColumn('messages', 'delivered_at');
  if (has) return;
  await knex.schema.alterTable('messages', (t) => {
    t.timestamp('delivered_at').nullable();
  });
};

exports.down = async function (knex) {
  const has = await knex.schema.hasColumn('messages', 'delivered_at');
  if (!has) return;
  await knex.schema.alterTable('messages', (t) => {
    t.dropColumn('delivered_at');
  });
};

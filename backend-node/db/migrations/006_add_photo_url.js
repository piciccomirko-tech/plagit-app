exports.up = function (knex) {
  return knex.schema.alterTable('users', (t) => {
    t.text('photo_url');
  });
};
exports.down = function (knex) {
  return knex.schema.alterTable('users', (t) => { t.dropColumn('photo_url'); });
};

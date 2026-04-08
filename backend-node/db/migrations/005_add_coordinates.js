exports.up = function (knex) {
  return knex.schema
    .alterTable('jobs', (t) => {
      t.float('latitude');
      t.float('longitude');
    })
    .alterTable('businesses', (t) => {
      t.float('latitude');
      t.float('longitude');
    })
    .alterTable('users', (t) => {
      t.float('latitude');
      t.float('longitude');
    });
};

exports.down = function (knex) {
  return knex.schema
    .alterTable('jobs', (t) => { t.dropColumn('latitude'); t.dropColumn('longitude'); })
    .alterTable('businesses', (t) => { t.dropColumn('latitude'); t.dropColumn('longitude'); })
    .alterTable('users', (t) => { t.dropColumn('latitude'); t.dropColumn('longitude'); });
};

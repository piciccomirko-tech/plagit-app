/**
 * Location Messages — extends `messages` with location-attachment metadata.
 *
 * Mirror of mig 031 / 035 / 036 but no upload endpoint: coordinates
 * travel directly inside the `sendMessage` JSON body, since they're a
 * tiny payload (two doubles + an optional address string) and there's
 * no binary blob to persist on the storage adapter.
 *
 * `attachment_type` is already present from 031 — this migration only
 * adds the location-specific columns. The runtime gates `attachment_type`
 * to one of {'text','audio','image','document','entity_share','location'}
 * at the controller layer.
 *
 * Idempotent: each `addColumn` is gated by `hasColumn`. Down() removes
 * only the columns we added.
 */
exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('location_lat'))) {
    await knex.schema.alterTable('messages', (t) => {
      // `double precision` matches the IEEE-754 64-bit range Flutter
      // sends. Range gating to [-90, 90] is enforced at the controller
      // layer — keeping the column itself permissive avoids painful
      // schema changes if we ever surface 6-decimal places of debug
      // data.
      t.double('location_lat').nullable();
    });
  }
  if (!(await has('location_lng'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.double('location_lng').nullable();
    });
  }
  if (!(await has('location_address'))) {
    await knex.schema.alterTable('messages', (t) => {
      // Optional reverse-geocoded human-readable address. Nullable —
      // Sprint 3 ships without client-side geocoding so this stays
      // null until a future sprint wires Apple/Google geocoder.
      t.text('location_address').nullable();
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.alterTable('messages', (t) => {
    t.dropColumn('location_address');
    t.dropColumn('location_lng');
    t.dropColumn('location_lat');
  });
};

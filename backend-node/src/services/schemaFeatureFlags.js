// Schema feature-flag — runtime probes for columns/tables that are
// added by migrations the deploy pipeline may apply AFTER the new
// code rolls out (typical on Railway: image redeploys before the
// `knex migrate:latest` step finishes). Without this guard, every
// listMessages SELECT that names `album_image_urls` would 500 on a
// pre-migration DB and break the inbox.
//
// Cache strategy:
//   • once we observe the column exists → cache TRUE forever
//     (migrations are additive in this codebase, columns aren't
//     dropped at runtime)
//   • when we observe it doesn't exist → cache FALSE with a 30s
//     re-probe TTL so the backend self-heals as soon as
//     `migrate:latest` finishes — no manual restart needed
//
// The probe is a single `information_schema` lookup (~1 ms) and only
// runs at first use + every 30s while the answer stays FALSE, so the
// runtime overhead is negligible.

const db = require('../config/db');

const _cache = {
  album_image_urls: { present: null, lastCheckedAt: 0 },
};

const _RECHECK_INTERVAL_MS = 30 * 1000;

async function _probe(column) {
  try {
    return await db.schema.hasColumn('messages', column);
  } catch (_e) {
    return false;
  }
}

async function isAlbumColumnPresent() {
  const entry = _cache.album_image_urls;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const result = await _probe('album_image_urls');
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // ignore: avoid_print — single line at the moment we transition
    // from "missing" to "present" lets the operator see in Railway
    // logs that the schema is now ready (no re-deploy required).
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.album_image_urls is now PRESENT');
  }
  return result;
}

module.exports = { isAlbumColumnPresent };

/**
 * Phase CallKit/PushKit Step C — add voip_token to device_tokens.
 *
 * PushKit VoIP tokens are separate from FCM tokens: Apple issues them
 * independently, they expire/rotate less often, and they MUST be sent
 * via a direct APNs HTTP/2 connection with push-type:voip (firebase-admin
 * cannot send VoIP pushes, so we need the raw token + our own sender).
 *
 * Why a separate column instead of reusing apns_token:
 *   • apns_token (added in 054) was designed for the native APNs token
 *     that FCM already manages internally — a "nice-to-have audit" column.
 *   • voip_token carries a different semantic (different APNs topic:
 *     <bundle>.voip, different expiry behaviour) and will be actively
 *     read by the VoIP sender. Keeping them separate avoids silent
 *     type confusion in the sender and lets us revoke/refresh each
 *     independently.
 *
 * Additive + idempotent: safe to re-run on a partially-upgraded DB.
 * Rollback: drops the column only (data lost — acceptable; tokens
 * re-register on next app launch).
 */
exports.up = async function (knex) {
  const hasCol = await knex.schema.hasColumn('device_tokens', 'voip_token');
  if (!hasCol) {
    await knex.schema.alterTable('device_tokens', (t) => {
      t.text('voip_token'); // nullable — not all platforms have VoIP tokens
    });
  }
};

exports.down = async function (knex) {
  const hasCol = await knex.schema.hasColumn('device_tokens', 'voip_token');
  if (hasCol) {
    await knex.schema.alterTable('device_tokens', (t) => {
      t.dropColumn('voip_token');
    });
  }
};

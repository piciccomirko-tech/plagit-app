/**
 * Centralised feature flag reader.
 *
 * All flags default to OFF. Production safety relies on this default —
 * if Railway never sets the env var, the new boost behaviour stays
 * dormant and the API behaves exactly like Step 1.
 *
 * Flags are read once at module load. Tests/dev that need to flip a
 * flag at runtime can require this module and mutate the exported
 * object — the controller code reads the live value on each request.
 *
 * | env var                   | exported key       | behaviour when ON                                |
 * |---------------------------|--------------------|--------------------------------------------------|
 * | BOOST_RANKING_ENABLED     | rankingEnabled     | jobRanking.rankJobs() applies the formula        |
 * | BOOST_RANKING_LOG         | rankingLog         | rankJobs() logs the per-job breakdown            |
 * | BOOST_CRON_ENABLED        | cronEnabled        | cron registry boots its scheduled jobs           |
 * | BOOST_ACTIVATION_ENABLED  | activationEnabled  | admin/business boost activation endpoints accept |
 *                                                   | requests; OFF returns 503 BOOST_ACTIVATION_OFF   |
 * | VOIP_PUSH_ENABLED         | voipPushEnabled    | arms apnsVoipSender (still STUB — no real send    |
 *                                                   | until the Apple .p8 key + HTTP/2 client land)    |
 */

function asBool(value, fallback = false) {
  if (value === undefined || value === null || value === '') return fallback;
  const v = String(value).trim().toLowerCase();
  return v === '1' || v === 'true' || v === 'yes' || v === 'on';
}

const flags = {
  rankingEnabled:       asBool(process.env.BOOST_RANKING_ENABLED,    false),
  rankingLog:           asBool(process.env.BOOST_RANKING_LOG,        false),
  cronEnabled:          asBool(process.env.BOOST_CRON_ENABLED,       false),
  activationEnabled:    asBool(process.env.BOOST_ACTIVATION_ENABLED, false),
  callRingSweepEnabled: asBool(process.env.CALL_RING_SWEEP_ENABLED,  false),
  voipPushEnabled:      asBool(process.env.VOIP_PUSH_ENABLED,        false),
};

module.exports = flags;
module.exports.asBool = asBool; // exported for tests

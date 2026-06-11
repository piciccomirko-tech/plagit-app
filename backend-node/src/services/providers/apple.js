/**
 * Apple In-App Purchase — StoreKit 2 verification + App Store Server
 * Notifications V2 (Payments Step 2 — SCAFFOLDING).
 *
 * What is REAL + tested here (no credentials needed):
 *   • product→plan mapping, transaction→entitlement mapping, the Apple
 *     status lifecycle, sandbox/production separation. Pure functions,
 *     unit-tested with mock decoded payloads.
 *
 * What is GATED on config (so no unvalidated purchase can ever grant
 * premium until real credentials/certs are in place — it THROWS):
 *   • JWS signature verification (SignedDataVerifier) — needs the Apple
 *     root certificates (public, downloadable) + bundleId (+ appAppleId for
 *     production).
 *   • App Store Server API calls (status re-check) — needs the .p8 key +
 *     Key ID + Issuer ID.
 *
 * The mobile app attaches `appAccountToken = <our user id>` to the purchase
 * so the webhook (which doesn't carry our user_id) can resolve the owner
 * from the transaction; verify also cross-checks it against the caller.
 *
 * Products (new, clean): com.plagit.premium.monthly | com.plagit.premium.yearly
 * NEVER log the .p8 / signing key.
 */
const fs = require('fs');
const path = require('path');
const AppError = require('../../utils/AppError');
const db = require('../../config/db');
const entitlements = require('../entitlements');

const PRODUCT_PLAN = Object.freeze({
  'com.plagit.premium.monthly': { product: 'plagit_premium', plan: 'monthly' },
  'com.plagit.premium.yearly': { product: 'plagit_premium', plan: 'yearly' },
});

// ── config ────────────────────────────────────────────────────────────
// Apple public root certs are bundled in the repo (downloaded from
// apple.com/certificateauthority) — override only for tests.
const DEFAULT_CERTS_DIR = path.join(__dirname, 'apple_root_certs');

// App Store Server API signing key (.p8). Accept base64 (Railway-safe,
// recommended) OR raw PEM OR a file path. NEVER logged.
function readPrivateKey() {
  const raw = process.env.APPLE_PRIVATE_KEY;
  if (raw && raw.trim()) {
    if (raw.includes('BEGIN PRIVATE KEY')) return raw; // already PEM
    try {
      const pem = Buffer.from(raw.trim(), 'base64').toString('utf8');
      return pem.includes('BEGIN PRIVATE KEY') ? pem : null;
    } catch (_) { return null; }
  }
  const p = process.env.APPLE_PRIVATE_KEY_PATH;
  if (p && fs.existsSync(p)) return fs.readFileSync(p, 'utf8');
  return null;
}

function cfg() {
  return {
    bundleId: process.env.APPLE_BUNDLE_ID || 'com.plagit.plagit',
    appAppleId: process.env.APPLE_APP_APPLE_ID ? Number(process.env.APPLE_APP_APPLE_ID) : undefined,
    issuerId: process.env.APPLE_ISSUER_ID || null,
    keyId: process.env.APPLE_KEY_ID || null,
    privateKey: readPrivateKey(),
    rootCertsDir: process.env.APPLE_ROOT_CERTS_DIR || DEFAULT_CERTS_DIR,
  };
}

// ── PURE mapping (credential-free, unit-tested) ───────────────────────

function mapEnvironment(appleEnv) {
  return String(appleEnv || '').toLowerCase() === 'production' ? 'production' : 'sandbox';
}

function isFreeTrial(decoded, renewal) {
  if (renewal && renewal.offerDiscountType) return renewal.offerDiscountType === 'FREE_TRIAL';
  return decoded.offerType === 1; // INTRODUCTORY — best-effort without renewal info
}

/**
 * Map a decoded StoreKit 2 transaction (+ optional renewal info) and a
 * resolved userId to an entitlement object for upsertEntitlement(), or null
 * if the product isn't ours.
 */
function transactionToEntitlement(decoded, userId, renewal) {
  const pp = PRODUCT_PLAN[decoded.productId];
  if (!pp) return null;
  const now = Date.now();
  const expiresMs = Number(decoded.expiresDate) || 0;
  const revoked = decoded.revocationDate != null;

  let status;
  if (revoked) status = 'cancelled';
  else if (expiresMs && expiresMs <= now) status = 'expired';
  else if (isFreeTrial(decoded, renewal)) status = 'trialing';
  else status = 'active';

  const cancelAtPeriodEnd = !!(renewal && renewal.autoRenewStatus === 0);

  return {
    userId,
    product: pp.product,
    plan: pp.plan,
    provider: 'apple',
    providerRef: String(decoded.originalTransactionId),
    status,
    currentPeriodStart: decoded.purchaseDate ? new Date(Number(decoded.purchaseDate)) : null,
    currentPeriodEnd: expiresMs ? new Date(expiresMs) : null,
    trialEnd: status === 'trialing' && expiresMs ? new Date(expiresMs) : null,
    cancelAtPeriodEnd,
    environment: mapEnvironment(decoded.environment),
    rawPayload: { productId: decoded.productId, type: decoded.type, offerType: decoded.offerType },
  };
}

/**
 * Apple ASSN V2 notification → the status the entitlement should move to,
 * or null when the notification only changes auto-renew (handled via the
 * renewal info, not a status flip).
 */
function notificationStatusHint(notificationType, subtype) {
  switch (notificationType) {
    case 'SUBSCRIBED':
    case 'DID_RENEW':
    case 'OFFER_REDEEMED':
      return 'active';
    case 'DID_CHANGE_RENEWAL_STATUS':
      return null;
    case 'DID_FAIL_TO_RENEW':
      return subtype === 'GRACE_PERIOD' ? 'past_due' : 'expired';
    case 'GRACE_PERIOD_EXPIRED':
    case 'EXPIRED':
      return 'expired';
    case 'REFUND':
    case 'REVOKE':
      return 'cancelled';
    default:
      return null;
  }
}

/**
 * Bind a verified transaction to the authenticated user. The signed
 * `appAccountToken` (set by our app at purchase, included in Apple's signed
 * payload) is the ONLY trustworthy link between an Apple transaction and our
 * user. REQUIRE it and require an exact match — otherwise a replayed or shared
 * receipt could grant premium to whoever submits it. Pure + unit-tested.
 */
function assertTransactionOwner(decoded, userId) {
  if (!decoded.appAccountToken) {
    throw AppError.badRequest(
      'Transaction missing appAccountToken; cannot bind to user.',
      'APPLE_NO_ACCOUNT_TOKEN',
    );
  }
  if (decoded.appAccountToken !== userId) {
    throw AppError.forbidden(
      'Transaction does not belong to this user.',
      'APPLE_USER_MISMATCH',
    );
  }
}

// ── GATED verification (real credentials/certs plug in here) ──────────

function loadAppleLib() {
  try {
    // eslint-disable-next-line global-require
    return require('@apple/app-store-server-library');
  } catch (_) {
    throw new AppError('Apple library not installed.', 501, 'APPLE_LIB_MISSING');
  }
}

function loadRootCerts(dir) {
  if (!dir || !fs.existsSync(dir)) {
    throw new AppError('Apple root certificates not configured (APPLE_ROOT_CERTS_DIR).', 501, 'APPLE_CERTS_MISSING');
  }
  const files = fs.readdirSync(dir).filter((f) => /\.(cer|der|pem)$/i.test(f));
  if (!files.length) throw new AppError('No Apple root certificates found.', 501, 'APPLE_CERTS_MISSING');
  return files.map((f) => fs.readFileSync(path.join(dir, f)));
}

function buildVerifier(environment) {
  const c = cfg();
  const lib = loadAppleLib();
  const certs = loadRootCerts(c.rootCertsDir);
  const env = environment === 'production' ? lib.Environment.PRODUCTION : lib.Environment.SANDBOX;
  return new lib.SignedDataVerifier(certs, true, env, c.bundleId, c.appAppleId);
}

// App Store Server API client (status/history queries) — uses the .p8 signing
// key + Key ID + Issuer ID. Available for status re-checks; the verify/webhook
// paths verify the signed JWS directly and don't require it.
function buildApiClient(environment) {
  const c = cfg();
  if (!c.privateKey || !c.keyId || !c.issuerId) {
    throw new AppError('App Store Server API not configured.', 501, 'APPLE_API_NOT_CONFIGURED');
  }
  const lib = loadAppleLib();
  const env = environment === 'production' ? lib.Environment.PRODUCTION : lib.Environment.SANDBOX;
  return new lib.AppStoreServerAPIClient(c.privateKey, c.keyId, c.issuerId, c.bundleId, env);
}

// Non-secret config self-check (verify Railway env after deploy via
// `railway ssh`). Returns booleans / non-secret values only — NEVER the key.
function configStatus() {
  const c = cfg();
  const missing = [];
  if (!c.appAppleId) missing.push('APPLE_APP_APPLE_ID');
  if (!c.issuerId) missing.push('APPLE_ISSUER_ID');
  if (!c.keyId) missing.push('APPLE_KEY_ID');
  if (!c.privateKey) missing.push('APPLE_PRIVATE_KEY');
  let certsLoaded = 0;
  try { certsLoaded = loadRootCerts(c.rootCertsDir).length; } catch (_) { /* none */ }
  let libInstalled = false;
  try { loadAppleLib(); libInstalled = true; } catch (_) { /* missing */ }
  return {
    bundleId: c.bundleId,
    appAppleId: c.appAppleId || null,
    hasPrivateKey: !!c.privateKey,
    hasKeyId: !!c.keyId,
    hasIssuerId: !!c.issuerId,
    certsLoaded,
    libInstalled,
    ready: missing.length === 0 && certsLoaded > 0 && libInstalled,
    missing,
  };
}

// Try production first, fall back to sandbox (TestFlight uses sandbox).
async function verifyTransaction(jws) {
  try {
    return await buildVerifier('production').verifyAndDecodeTransaction(jws);
  } catch (e) {
    if (e instanceof AppError) throw e; // config error → don't mask
    return buildVerifier('sandbox').verifyAndDecodeTransaction(jws);
  }
}

// Resolve our user for a webhook transaction: prefer appAccountToken (set by
// the app at purchase), else the existing entitlement row by provider_ref.
async function resolveUserId(decoded) {
  if (decoded.appAccountToken) return decoded.appAccountToken;
  const row = await db('user_entitlements')
    .where({ provider: 'apple', provider_ref: String(decoded.originalTransactionId) })
    .first();
  return row ? row.user_id : null;
}

/**
 * POST /v1/subscription/verify (provider=apple). Validate a StoreKit 2 JWS
 * signed transaction and upsert the entitlement. Throws (NO grant) until
 * certs/config are present.
 */
async function validatePurchase({ userId, jws } = {}) {
  if (!userId) throw AppError.badRequest('Missing user.', 'APPLE_NO_USER');
  if (!jws || typeof jws !== 'string') throw AppError.badRequest('Missing signed transaction.', 'APPLE_NO_JWS');
  const decoded = await verifyTransaction(jws);
  // Bind the signed transaction to this caller (replay/sharing guard).
  assertTransactionOwner(decoded, userId);
  const ent = transactionToEntitlement(decoded, userId, null);
  if (!ent) throw AppError.badRequest('Unknown Apple product.', 'APPLE_UNKNOWN_PRODUCT');
  return entitlements.upsertEntitlement(ent);
}

/**
 * POST /v1/webhooks/apple — App Store Server Notifications V2. Verify +
 * decode the signedPayload, map the notification to an entitlement update,
 * and upsert (idempotent on provider_ref). Throws until certs/config exist.
 */
async function handleNotification({ signedPayload } = {}) {
  if (!signedPayload) throw AppError.badRequest('Missing signedPayload.', 'APPLE_NO_PAYLOAD');

  let verifier;
  let notif;
  try {
    verifier = buildVerifier('production');
    notif = await verifier.verifyAndDecodeNotification(signedPayload);
  } catch (e) {
    if (e instanceof AppError) throw e;
    verifier = buildVerifier('sandbox');
    notif = await verifier.verifyAndDecodeNotification(signedPayload);
  }

  const data = notif.data || {};
  const tx = data.signedTransactionInfo
    ? await verifier.verifyAndDecodeTransaction(data.signedTransactionInfo) : null;
  const renewal = data.signedRenewalInfo
    ? await verifier.verifyAndDecodeRenewalInfo(data.signedRenewalInfo) : null;
  if (!tx) return { handled: false, reason: 'no transaction in notification' };

  const userId = await resolveUserId(tx);
  if (!userId) return { handled: false, reason: 'no known user for transaction' };

  const ent = transactionToEntitlement(tx, userId, renewal);
  if (!ent) return { handled: false, reason: 'unknown product' };

  // Let an explicit terminal/grace notification override the derived status.
  const hint = notificationStatusHint(notif.notificationType, notif.subtype);
  if (hint) ent.status = hint;

  await entitlements.upsertEntitlement(ent);
  return { handled: true, notificationType: notif.notificationType, status: ent.status };
}

module.exports = {
  validatePurchase,
  handleNotification,
  configStatus,
  _internal: {
    PRODUCT_PLAN,
    mapEnvironment,
    isFreeTrial,
    transactionToEntitlement,
    notificationStatusHint,
    assertTransactionOwner,
    readPrivateKey,
    buildVerifier,
    buildApiClient,
  },
};

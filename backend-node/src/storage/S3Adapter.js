const StorageAdapter = require('./StorageAdapter');

/**
 * S3-backed storage — STUB.
 *
 * Activation requires:
 *   1. `npm install @aws-sdk/client-s3`
 *   2. Env vars: AWS_REGION, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,
 *      S3_BUCKET (and optionally S3_PUBLIC_BASE_URL for CloudFront).
 *   3. Set STORAGE_DRIVER=s3 in `.env` / Railway env.
 *
 * Until then this stub throws on construction so a misconfigured prod
 * boots loudly instead of silently writing audio bytes nowhere.
 *
 * See `src/storage/README.md` for the full setup checklist.
 */
class S3Adapter extends StorageAdapter {
  constructor() {
    super();
    throw new Error(
      'S3Adapter is not configured. Install @aws-sdk/client-s3 and set ' +
      'AWS_REGION / AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / S3_BUCKET ' +
      'before setting STORAGE_DRIVER=s3. See src/storage/README.md.',
    );
  }

  async save(_buffer, _opts) {
    throw new Error('S3Adapter.save not implemented');
  }

  async delete(_url) {
    throw new Error('S3Adapter.delete not implemented');
  }

  driverName() {
    return 's3';
  }
}

module.exports = S3Adapter;

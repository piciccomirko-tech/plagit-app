const LocalDiskAdapter = require('./LocalDiskAdapter');

/**
 * Pick the storage adapter at boot from STORAGE_DRIVER env.
 *
 * Defaults to 'local' so dev `npm start` works out of the box. Set
 * 'STORAGE_DRIVER=s3' once the S3 (or S3-compatible — R2, MinIO, etc.)
 * env vars are wired (see src/storage/README.md).
 *
 * The S3Adapter (and its `@aws-sdk/client-s3` dependency, ~3MB) is
 * required lazily so a default 'local' boot doesn't pay the cost of
 * loading the S3 client into memory.
 */
function buildStorage() {
  const driver = (process.env.STORAGE_DRIVER || 'local').toLowerCase();

  // Production safety: the local-disk adapter persists audio to the
  // container's filesystem, which is ephemeral on Railway / any
  // typical PaaS — every redeploy would silently lose every voice
  // message. Fail the boot loudly instead of silently corrupting prod
  // data. To run prod-style locally, set NODE_ENV=development.
  if (driver === 'local' && process.env.NODE_ENV === 'production') {
    throw new Error(
      'Unsafe storage config: STORAGE_DRIVER=local is not allowed when ' +
      'NODE_ENV=production. Set STORAGE_DRIVER=s3 and the S3/R2 env vars ' +
      '(STORAGE_S3_BUCKET, STORAGE_S3_ACCESS_KEY_ID, ' +
      'STORAGE_S3_SECRET_ACCESS_KEY, STORAGE_S3_ENDPOINT) before ' +
      'deploying. See src/storage/README.md for the full checklist.',
    );
  }

  switch (driver) {
    case 's3': {
      // Lazy require so dev/local boots don't load aws-sdk.
      const S3Adapter = require('./S3Adapter');
      const adapter = new S3Adapter(process.env);
      console.log(
        `[storage] driver=s3 bucket=${adapter.bucket}` +
        (adapter.endpoint ? ` endpoint=${adapter.endpoint}` : ''),
      );
      return adapter;
    }
    case 'local':
    default: {
      const adapter = new LocalDiskAdapter();
      console.log(`[storage] driver=local baseDir=${adapter.baseDir}`);
      return adapter;
    }
  }
}

const storage = buildStorage();

module.exports = storage;

const LocalDiskAdapter = require('./LocalDiskAdapter');
const S3Adapter = require('./S3Adapter');

/**
 * Pick the storage adapter at boot from STORAGE_DRIVER env.
 *
 * Defaults to 'local' so dev `npm start` works out of the box. Set
 * 'STORAGE_DRIVER=s3' once the AWS bits are wired (see README).
 */
function buildStorage() {
  const driver = (process.env.STORAGE_DRIVER || 'local').toLowerCase();
  switch (driver) {
    case 's3':
      return new S3Adapter();
    case 'local':
    default:
      return new LocalDiskAdapter();
  }
}

const storage = buildStorage();

module.exports = storage;

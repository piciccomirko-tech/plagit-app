/**
 * Pluggable file storage interface — every concrete adapter
 * (LocalDiskAdapter, S3Adapter) must implement these methods.
 *
 * Audio uploads are routed through this layer so swapping local
 * filesystem for S3 is a one-line change in `STORAGE_DRIVER`.
 */
class StorageAdapter {
  /**
   * Persist `buffer` and return a public URL string callers can store
   * in `messages.audio_url`. The adapter chooses the path / object key.
   *
   * @param {Buffer} buffer
   * @param {Object} opts
   * @param {string} opts.ext           - file extension WITHOUT dot, e.g. 'm4a'
   * @param {string} opts.mimeType      - 'audio/m4a' etc., used for S3 ContentType
   * @param {string} opts.kind          - 'audio' (extensible for future media types)
   * @returns {Promise<string>}         - public URL or path the API can return
   */
  async save(buffer, opts) {
    throw new Error('save() not implemented');
  }

  /**
   * Best-effort delete. Used by future cleanup jobs / orphan reaping.
   * Implementations should NOT throw on missing files.
   *
   * @param {string} url
   * @returns {Promise<void>}
   */
  async delete(url) {
    throw new Error('delete() not implemented');
  }

  /**
   * Adapter identity for logs / diagnostics. Return 'local' or 's3'.
   * @returns {string}
   */
  driverName() {
    throw new Error('driverName() not implemented');
  }
}

module.exports = StorageAdapter;

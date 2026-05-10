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

  /**
   * True if [url] was issued by `save()` on THIS adapter — i.e. it
   * points to our own storage namespace and is safe to accept as a
   * sendMessage attachment. Used by chat controllers to gate
   * `image_url` / `document_url` so a malicious client can't inject
   * a third-party http URL into a chat bubble.
   *
   * The previous guard (`url.startsWith('/uploads/image/')`) only
   * matched the LocalDiskAdapter shape and silently rejected every
   * S3/R2 URL the production adapter emits — that's the bug fix
   * that motivates this method.
   *
   * @param {string} url
   * @returns {boolean}
   */
  isOwnedUrl(url) {
    throw new Error('isOwnedUrl() not implemented');
  }
}

module.exports = StorageAdapter;

const crypto = require('crypto');
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const StorageAdapter = require('./StorageAdapter');

/**
 * S3-compatible storage adapter — works with AWS S3 and any S3-compat
 * service (Cloudflare R2, DigitalOcean Spaces, Wasabi, Backblaze B2,
 * MinIO for local smoke testing).
 *
 * Configuration is fully env-driven so this file has no provider-specific
 * branching. The only nuance is `forcePathStyle` which R2 / MinIO need
 * (vs AWS which prefers virtual-hosted style by default).
 *
 * Required env:
 *   STORAGE_S3_BUCKET
 *   STORAGE_S3_ACCESS_KEY_ID
 *   STORAGE_S3_SECRET_ACCESS_KEY
 *
 * Optional env:
 *   STORAGE_S3_ENDPOINT         (R2: https://<acc>.r2.cloudflarestorage.com)
 *   STORAGE_S3_REGION           (default: 'auto' for R2, 'us-east-1' for AWS without endpoint)
 *   STORAGE_S3_PUBLIC_BASE_URL  (custom domain / CloudFront — replaces the canonical bucket URL in returned URLs)
 *   STORAGE_S3_FORCE_PATH_STYLE (default: 'true' if endpoint set, else 'false')
 *   STORAGE_S3_PUBLIC_READ_ACL  ('true' to set ACL: 'public-read' on PUT — leave 'false' for R2 which manages access via bucket policy)
 *
 * The adapter does NOT pre-validate bucket existence at construction
 * time; first-write failures surface as save() rejections. That keeps
 * the boot path fast and avoids needing list-bucket permission on the
 * IAM key (least privilege).
 */
class S3Adapter extends StorageAdapter {
  constructor(env = process.env) {
    super();
    const required = [
      'STORAGE_S3_BUCKET',
      'STORAGE_S3_ACCESS_KEY_ID',
      'STORAGE_S3_SECRET_ACCESS_KEY',
    ];
    const missing = required.filter((k) => !env[k]);
    if (missing.length > 0) {
      throw new Error(
        `S3Adapter: missing required env vars: ${missing.join(', ')}. ` +
        `Set them (and STORAGE_DRIVER=s3) before booting in production. ` +
        `See src/storage/README.md for the full activation checklist.`,
      );
    }

    this.bucket = env.STORAGE_S3_BUCKET;
    this.endpoint = env.STORAGE_S3_ENDPOINT || undefined;
    this.region = env.STORAGE_S3_REGION || (this.endpoint ? 'auto' : 'us-east-1');
    this.publicBaseUrl = (env.STORAGE_S3_PUBLIC_BASE_URL || '').replace(/\/+$/, '');
    this.forcePathStyle =
      env.STORAGE_S3_FORCE_PATH_STYLE != null
        ? env.STORAGE_S3_FORCE_PATH_STYLE === 'true'
        : !!this.endpoint; // default: path-style if custom endpoint (R2/MinIO)
    this.publicReadAcl = env.STORAGE_S3_PUBLIC_READ_ACL === 'true';

    this.client = new S3Client({
      region: this.region,
      endpoint: this.endpoint,
      forcePathStyle: this.forcePathStyle,
      credentials: {
        accessKeyId: env.STORAGE_S3_ACCESS_KEY_ID,
        secretAccessKey: env.STORAGE_S3_SECRET_ACCESS_KEY,
      },
    });
  }

  async save(buffer, { ext, mimeType, kind = 'audio' } = {}) {
    if (!Buffer.isBuffer(buffer)) {
      throw new Error('S3Adapter.save requires a Buffer');
    }
    const cleanExt = (ext || 'bin').replace(/^\.+/, '').toLowerCase();
    const key = `${kind}/${crypto.randomUUID()}.${cleanExt}`;

    const cmd = new PutObjectCommand({
      Bucket: this.bucket,
      Key: key,
      Body: buffer,
      ContentType: mimeType || 'application/octet-stream',
      // Only AWS S3 supports ACL on PUT; R2 ignores it (or rejects depending
      // on bucket setup). Gate via env so the same code path works for both.
      ...(this.publicReadAcl ? { ACL: 'public-read' } : {}),
    });
    await this.client.send(cmd);

    return this._publicUrlFor(key);
  }

  async delete(url) {
    if (typeof url !== 'string' || url.length === 0) return;
    const key = this._keyFromUrl(url);
    if (!key) return; // not ours, ignore
    try {
      await this.client.send(new DeleteObjectCommand({ Bucket: this.bucket, Key: key }));
    } catch (e) {
      // Best-effort cleanup — never throw to caller. Log so an orphan-cleanup
      // sweep can pick it up later.
      // 404 / NoSuchKey is normal (already deleted) — don't even warn.
      const code = e?.$metadata?.httpStatusCode;
      if (code !== 404) {
        console.warn('[S3Adapter] delete failed:', e.message || e);
      }
    }
  }

  driverName() {
    return 's3';
  }

  isOwnedUrl(url) {
    if (typeof url !== 'string' || url.length === 0) return false;
    // _keyFromUrl returns null for any URL we did not issue —
    // exactly the boolean signal we need.
    return this._keyFromUrl(url) != null;
  }

  // ── helpers ────────────────────────────────────────────────────

  _publicUrlFor(key) {
    if (this.publicBaseUrl) {
      return `${this.publicBaseUrl}/${key}`;
    }
    if (this.endpoint) {
      // Custom endpoint (R2 / MinIO / Wasabi) — return the canonical
      // path-style URL. CDN / custom domain SHOULD override this via
      // STORAGE_S3_PUBLIC_BASE_URL in production.
      const base = this.endpoint.replace(/\/+$/, '');
      return `${base}/${this.bucket}/${key}`;
    }
    // AWS S3 default
    return `https://${this.bucket}.s3.${this.region}.amazonaws.com/${key}`;
  }

  /**
   * Reverse of [_publicUrlFor]: extract the object key from a URL we
   * previously returned. Tolerates path-style and virtual-hosted style.
   * Returns null when the URL is from a different driver / unknown shape.
   */
  _keyFromUrl(url) {
    try {
      const u = new URL(url);
      // 1) STORAGE_S3_PUBLIC_BASE_URL prefix match — everything after the
      // base path is the key.
      if (this.publicBaseUrl) {
        const baseUrl = new URL(this.publicBaseUrl);
        if (
          u.host === baseUrl.host &&
          u.pathname.startsWith(baseUrl.pathname.replace(/\/+$/, ''))
        ) {
          return u.pathname
            .slice(baseUrl.pathname.replace(/\/+$/, '').length)
            .replace(/^\/+/, '');
        }
      }
      // 2) Path-style under our endpoint host: /<bucket>/<key>
      const segments = u.pathname.replace(/^\/+/, '').split('/');
      if (segments[0] === this.bucket) {
        return segments.slice(1).join('/');
      }
      // 3) Virtual-hosted style: <bucket>.s3.<region>.amazonaws.com/<key>
      if (u.host.startsWith(`${this.bucket}.`)) {
        return u.pathname.replace(/^\/+/, '');
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

module.exports = S3Adapter;

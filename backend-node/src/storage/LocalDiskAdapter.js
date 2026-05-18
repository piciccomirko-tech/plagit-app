const fs = require('fs/promises');
const path = require('path');
const crypto = require('crypto');
const StorageAdapter = require('./StorageAdapter');

/**
 * Filesystem-backed storage for development.
 *
 * Files land under `<repo>/uploads/<kind>/<uuid>.<ext>` and are served
 * publicly via `express.static('/uploads', ...)` mounted in app.js.
 *
 * NOT suitable for Railway / any container-based prod deploy — the
 * filesystem there is ephemeral and files vanish on every redeploy.
 * Switch to S3Adapter when shipping to production. See README.md.
 */
class LocalDiskAdapter extends StorageAdapter {
  constructor({ baseDir, publicPrefix, publicBaseUrl } = {}) {
    super();
    // Default: <project-root>/uploads — sibling to src/, ignored via .gitignore.
    this.baseDir =
      baseDir || path.resolve(__dirname, '..', '..', 'uploads');
    this.publicPrefix = publicPrefix || '/uploads';
    // Optional absolute origin (`http://localhost:3000` in dev) prepended
    // to every returned URL so consumers (Flutter `ProfilePhoto`, chat
    // header avatar, etc.) can fetch via `NetworkImage` instead of
    // trying to resolve a bare `/uploads/...` against the bundled
    // assets and silently falling back to initials.
    //
    // Lookup order:
    //   1. Constructor override (tests can inject)
    //   2. `STORAGE_LOCAL_PUBLIC_BASE_URL` env (explicit operator value)
    //   3. `http://localhost:${PORT || 3000}` (sensible dev default)
    //
    // Returned without a trailing slash so concatenation is unambiguous.
    const envBase =
      (process.env.STORAGE_LOCAL_PUBLIC_BASE_URL || '').replace(/\/+$/, '');
    const port = process.env.PORT || '3000';
    this.publicBaseUrl =
      (publicBaseUrl !== undefined ? publicBaseUrl : envBase) ||
      `http://localhost:${port}`;
  }

  async save(buffer, { ext, kind = 'audio' }) {
    if (!Buffer.isBuffer(buffer)) {
      throw new Error('LocalDiskAdapter.save requires a Buffer');
    }
    const cleanExt = (ext || 'bin').replace(/^\.+/, '').toLowerCase();
    const dir = path.join(this.baseDir, kind);
    await fs.mkdir(dir, { recursive: true });
    const id = crypto.randomUUID();
    const filename = `${id}.${cleanExt}`;
    const fullPath = path.join(dir, filename);
    await fs.writeFile(fullPath, buffer);
    // Return an ABSOLUTE URL so Flutter's NetworkImage path triggers
    // correctly. See constructor for the publicBaseUrl resolution order.
    return `${this.publicBaseUrl}${this.publicPrefix}/${kind}/${filename}`;
  }

  async delete(url) {
    if (typeof url !== 'string' || !url.startsWith(this.publicPrefix + '/')) {
      return; // not ours, ignore
    }
    const rel = url.slice(this.publicPrefix.length + 1); // 'audio/<uuid>.m4a'
    const fullPath = path.join(this.baseDir, rel);
    try {
      await fs.unlink(fullPath);
    } catch (e) {
      if (e.code !== 'ENOENT') {
        // log but never throw — cleanup is best-effort
        console.warn('[LocalDiskAdapter] delete failed:', e.message);
      }
    }
  }

  driverName() {
    return 'local';
  }

  isOwnedUrl(url) {
    if (typeof url !== 'string' || url.length === 0) return false;
    // Accept both the legacy relative form (`/uploads/...`) — old rows
    // stored before `publicBaseUrl` rollout — and the new absolute
    // form (`http://localhost:3000/uploads/...`) returned by `save`.
    if (url.startsWith(this.publicPrefix + '/')) return true;
    if (this.publicBaseUrl &&
        url.startsWith(`${this.publicBaseUrl}${this.publicPrefix}/`)) {
      return true;
    }
    return false;
  }

  // Exposed so app.js can mount express.static at the right base.
  staticConfig() {
    return { baseDir: this.baseDir, publicPrefix: this.publicPrefix };
  }
}

module.exports = LocalDiskAdapter;

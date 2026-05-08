const AppError = require('../utils/AppError');
const { ok } = require('../utils/response');
const storage = require('../storage');

// Client-declared MIME allowlist. The first guard checks the
// `Content-Type` header multer parsed from the multipart part — but a
// malicious client can send any header, so we ALSO sniff the actual
// file bytes (see _detectAudioMime below) before accepting the upload.
const ALLOWED_AUDIO_MIME = new Set([
  'audio/m4a',
  'audio/mp4',
  'audio/aac',
  'audio/x-m4a',
  'audio/mpeg', // mp3 fallback
]);

// Server-trusted MIME — what file-type's magic-byte sniffer is allowed
// to return. file-type emits `audio/x-m4a` for files whose ftyp brand
// is `M4A ` (the iOS / Android recorder default) and `audio/mp4` for
// the generic `mp42`/`isom` brand. Both are valid AAC-in-MP4 audio
// for our purposes.
const SNIFFED_AUDIO_MIME = new Set([
  'audio/x-m4a', // ftyp brand 'M4A ' — iOS record_darwin default
  'audio/mp4',   // ftyp brand 'mp42' / 'isom' — generic AAC-in-MP4
  'audio/aac',   // raw AAC stream
  'audio/mpeg',  // mp3
]);

const MIME_TO_EXT = {
  'audio/m4a': 'm4a',
  'audio/mp4': 'm4a',
  'audio/aac': 'm4a',
  'audio/x-m4a': 'm4a',
  'audio/mpeg': 'mp3',
};

/**
 * Magic-byte sniffer using the `file-type` package. Returns `null`
 * when the buffer can't be identified at all (binary garbage / empty).
 *
 * `file-type` v22 is ESM-only — required via dynamic `import()` so
 * this CommonJS module loads it on demand without a bundler.
 */
async function _detectAudioMime(buffer) {
  const { fileTypeFromBuffer } = await import('file-type');
  const detected = await fileTypeFromBuffer(buffer);
  return detected || null;
}

/**
 * POST /v1/uploads/audio
 *
 * Multipart form-data with field `file`. Returns the public URL the
 * client should attach to the next `sendMessage` call as `audio_url`.
 *
 * Optional `duration_ms` form field carries the client-side measured
 * duration so the receiver doesn't have to decode the file just to
 * render the bubble timer.
 *
 * Three validation gates, in order:
 *   1. Client-declared MIME header is in [ALLOWED_AUDIO_MIME].
 *   2. File size ≤ 5MB (also enforced by multer at the route layer).
 *   3. Magic-byte sniff of the buffer matches an audio format from
 *      [SNIFFED_AUDIO_MIME]. This catches MIME-spoofed uploads
 *      (e.g. a `.exe` with `Content-Type: audio/m4a`).
 */
async function uploadAudio(req, res, next) {
  try {
    if (!req.file) {
      throw AppError.badRequest('Missing audio file under field "file".');
    }
    const { mimetype, size, buffer } = req.file;

    // Gate 1 — client-declared MIME
    if (!ALLOWED_AUDIO_MIME.has(mimetype)) {
      throw AppError.badRequest(
        `Unsupported audio type: ${mimetype}. Use M4A/AAC/MP3.`,
        'INVALID_MEDIA_TYPE',
      );
    }

    // Gate 2 — size cap. 60s @ 64kbps ≈ 480KB; 5MB is 10× headroom.
    if (size > 5 * 1024 * 1024) {
      throw AppError.badRequest(
        'Audio file too large (max 5MB).',
        'AUDIO_FILE_TOO_LARGE',
      );
    }

    // Gate 3 — magic-byte sniff. Trust the buffer, not the header.
    const sniffed = await _detectAudioMime(buffer);
    if (!sniffed || !SNIFFED_AUDIO_MIME.has(sniffed.mime)) {
      throw AppError.badRequest(
        sniffed
          ? `File contents look like ${sniffed.mime} (.${sniffed.ext}), not an audio recording.`
          : 'File contents are not a recognized audio format.',
        'INVALID_AUDIO_FILE',
      );
    }

    const ext = MIME_TO_EXT[mimetype] || sniffed.ext || 'bin';
    const url = await storage.save(buffer, {
      ext,
      mimeType: mimetype,
      kind: 'audio',
    });

    const durationMs = parseInt(req.body?.duration_ms, 10);
    ok(res, {
      audio_url: url,
      audio_size_bytes: size,
      audio_mime_type: mimetype,
      audio_duration_ms: Number.isFinite(durationMs) ? durationMs : null,
      driver: storage.driverName(),
    });
  } catch (err) {
    next(err);
  }
}

// ─────────────────────────────────────────────────────────────────
// Image uploads — Phase 5 (Photos + Camera chat plugs).
//
// Same three-gate pattern as uploadAudio (declared MIME → size → magic
// sniff). 10MB cap covers HEIC/JPEG photos straight from the iPhone
// camera roll without forcing a downscale on the client.
// ─────────────────────────────────────────────────────────────────

const ALLOWED_IMAGE_MIME = new Set([
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
]);

const SNIFFED_IMAGE_MIME = new Set([
  'image/jpeg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
]);

const IMAGE_MIME_TO_EXT = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/heic': 'heic',
  'image/heif': 'heic',
};

const IMAGE_MAX_BYTES = 10 * 1024 * 1024; // 10MB

/**
 * POST /v1/uploads/image
 *
 * Multipart form-data with field `file`. Optional form fields:
 *   - `width` (int) — client-decoded image width in pixels
 *   - `height` (int) — client-decoded image height in pixels
 *
 * Carries width/height so the receiver bubble can size its
 * placeholder before the bytes finish loading (no layout jump).
 */
async function uploadImage(req, res, next) {
  try {
    if (!req.file) {
      throw AppError.badRequest('Missing image file under field "file".');
    }
    const { mimetype, size, buffer } = req.file;

    if (!ALLOWED_IMAGE_MIME.has(mimetype)) {
      throw AppError.badRequest(
        `Unsupported image type: ${mimetype}. Use JPEG/PNG/WEBP/HEIC.`,
        'INVALID_MEDIA_TYPE',
      );
    }

    if (size > IMAGE_MAX_BYTES) {
      throw AppError.badRequest(
        'Image file too large (max 10MB).',
        'IMAGE_FILE_TOO_LARGE',
      );
    }

    const sniffed = await _detectFileType(buffer);
    if (!sniffed || !SNIFFED_IMAGE_MIME.has(sniffed.mime)) {
      throw AppError.badRequest(
        sniffed
          ? `File contents look like ${sniffed.mime} (.${sniffed.ext}), not an image.`
          : 'File contents are not a recognized image format.',
        'INVALID_IMAGE_FILE',
      );
    }

    const ext = IMAGE_MIME_TO_EXT[mimetype] || sniffed.ext || 'bin';
    const url = await storage.save(buffer, {
      ext,
      mimeType: mimetype,
      kind: 'image',
    });

    const width = parseInt(req.body?.width, 10);
    const height = parseInt(req.body?.height, 10);
    ok(res, {
      image_url: url,
      image_size_bytes: size,
      image_mime_type: mimetype,
      image_width: Number.isFinite(width) ? width : null,
      image_height: Number.isFinite(height) ? height : null,
      driver: storage.driverName(),
    });
  } catch (err) {
    next(err);
  }
}

/** Generic magic-byte sniff — same `file-type` library used for audio. */
async function _detectFileType(buffer) {
  const { fileTypeFromBuffer } = await import('file-type');
  return (await fileTypeFromBuffer(buffer)) || null;
}

module.exports = { uploadAudio, uploadImage };

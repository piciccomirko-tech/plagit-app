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

// ─────────────────────────────────────────────────────────────────
// Document uploads — Sprint 3 (Document chat plug).
//
// Same three-gate pattern as audio/image. 20MB cap covers a long CV
// or a contract PDF without being abuseable as a generic file dump.
//
// Allowlist intentionally narrow: PDF + DOC + DOCX + TXT only. Skip
// XLS/XLSX for now — they aren't part of the recruitment use case
// the chat plug targets and they have their own lookalike-malware
// concerns (macro-enabled spreadsheets).
// ─────────────────────────────────────────────────────────────────

const ALLOWED_DOCUMENT_MIME = new Set([
  'application/pdf',
  'application/msword', // .doc
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document', // .docx
  'text/plain',
]);

// What `file-type` is allowed to return after sniffing the buffer.
// DOCX is a ZIP container under the hood — `file-type` v22 reports
// the OOXML mime when the inner _rels marks it as a Word document,
// but on older docs (or stripped zips) it falls back to plain
// `application/zip`. We accept either, gated by the declared MIME.
const SNIFFED_DOCUMENT_MIME = new Set([
  'application/pdf',
  'application/x-cfb', // OLE compound — DOC files
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/zip', // DOCX inner container — only OK when declared mime IS docx
]);

const DOCUMENT_MIME_TO_EXT = {
  'application/pdf': 'pdf',
  'application/msword': 'doc',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document': 'docx',
  'text/plain': 'txt',
};

const DOCUMENT_MAX_BYTES = 20 * 1024 * 1024; // 20MB

/**
 * Heuristic for plain-text bodies: file-type can't sniff `text/plain`
 * (no magic bytes) so we run a simple structural check on the first
 * 1KB. A genuine UTF-8/ASCII document has zero NUL bytes; a binary
 * blob mislabelled as text/plain almost always has at least one. This
 * isn't a perfect classifier but catches the obvious abuse.
 */
function _looksLikePlainText(buffer) {
  const sample = buffer.slice(0, Math.min(buffer.length, 1024));
  for (let i = 0; i < sample.length; i++) {
    if (sample[i] === 0x00) return false;
  }
  return true;
}

// ─────────────────────────────────────────────────────────────────
// Video uploads — Sprint Video Posts (Mirko 2026-05-16).
//
// Same three-gate pattern as audio/image/document. 50 MB cap covers
// ~15-20 sec of 1080p iPhone video without forcing a re-encode on the
// client. `image_picker.pickVideo()` can ask for a `maxDuration` but
// iOS doesn't honor it on every device — the server-side hard cap is
// the only safety net we can rely on.
// ─────────────────────────────────────────────────────────────────

const ALLOWED_VIDEO_MIME = new Set([
  'video/mp4',
  'video/quicktime', // iPhone .mov
  'video/x-m4v',
]);

const SNIFFED_VIDEO_MIME = new Set([
  'video/mp4',
  'video/quicktime',
  'video/x-m4v',
]);

const VIDEO_MIME_TO_EXT = {
  'video/mp4': 'mp4',
  'video/quicktime': 'mov',
  'video/x-m4v': 'm4v',
};

const VIDEO_MAX_BYTES = 50 * 1024 * 1024; // 50 MB

/**
 * POST /v1/uploads/video
 *
 * Multipart form-data with field `file`. Optional form fields:
 *   - `duration_ms` (int) — client-measured video duration so the feed
 *     can render the duration overlay without decoding bytes.
 *   - `width` (int), `height` (int) — client-decoded video dimensions
 *     so the receiver can size the placeholder before bytes finish
 *     loading (no layout jump on slow networks).
 *
 * Three validation gates — mirror of [uploadImage]:
 *   1. Client-declared MIME header is in [ALLOWED_VIDEO_MIME].
 *   2. File size ≤ 50 MB (also enforced by multer at the route layer).
 *   3. Magic-byte sniff of the buffer matches [SNIFFED_VIDEO_MIME].
 */
async function uploadVideo(req, res, next) {
  try {
    if (!req.file) {
      throw AppError.badRequest('Missing video file under field "file".');
    }
    const { mimetype, size, buffer } = req.file;

    if (!ALLOWED_VIDEO_MIME.has(mimetype)) {
      throw AppError.badRequest(
        `Unsupported video type: ${mimetype}. Use MP4/MOV/M4V.`,
        'INVALID_MEDIA_TYPE',
      );
    }

    if (size > VIDEO_MAX_BYTES) {
      throw AppError.badRequest(
        'Video file too large (max 50MB).',
        'VIDEO_FILE_TOO_LARGE',
      );
    }

    const sniffed = await _detectFileType(buffer);
    if (!sniffed || !SNIFFED_VIDEO_MIME.has(sniffed.mime)) {
      throw AppError.badRequest(
        sniffed
          ? `File contents look like ${sniffed.mime} (.${sniffed.ext}), not a video.`
          : 'File contents are not a recognized video format.',
        'INVALID_VIDEO_FILE',
      );
    }

    const ext = VIDEO_MIME_TO_EXT[mimetype] || sniffed.ext || 'bin';
    const url = await storage.save(buffer, {
      ext,
      mimeType: mimetype,
      kind: 'video',
    });

    const durationMs = parseInt(req.body?.duration_ms, 10);
    const width = parseInt(req.body?.width, 10);
    const height = parseInt(req.body?.height, 10);
    ok(res, {
      video_url: url,
      video_size_bytes: size,
      video_mime_type: mimetype,
      video_duration_ms: Number.isFinite(durationMs) ? durationMs : null,
      video_width: Number.isFinite(width) ? width : null,
      video_height: Number.isFinite(height) ? height : null,
      driver: storage.driverName(),
    });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /v1/uploads/document
 *
 * Multipart form-data with field `file`. Optional form field:
 *   - `filename` (string) — original filename the sender's OS reported.
 *     Persisted so the receiver bubble can show "Curriculum.pdf"
 *     instead of the storage adapter's randomly-generated UUID. The
 *     filename never enters the storage path itself — we always save
 *     under `<uuid>.<ext>` to avoid path-traversal and to deduplicate.
 */
async function uploadDocument(req, res, next) {
  try {
    if (!req.file) {
      throw AppError.badRequest('Missing document file under field "file".');
    }
    const { mimetype, size, buffer, originalname } = req.file;

    if (!ALLOWED_DOCUMENT_MIME.has(mimetype)) {
      throw AppError.badRequest(
        `Unsupported document type: ${mimetype}. Use PDF/DOC/DOCX/TXT.`,
        'INVALID_MEDIA_TYPE',
      );
    }

    if (size > DOCUMENT_MAX_BYTES) {
      throw AppError.badRequest(
        'Document file too large (max 20MB).',
        'DOCUMENT_FILE_TOO_LARGE',
      );
    }

    // Plain-text bypasses the magic-byte sniff (text has no magic) and
    // goes through a NUL-byte heuristic instead. Everything else must
    // match the SNIFFED_DOCUMENT_MIME allowlist.
    if (mimetype === 'text/plain') {
      if (!_looksLikePlainText(buffer)) {
        throw AppError.badRequest(
          'File contents are not plain text.',
          'INVALID_DOCUMENT_FILE',
        );
      }
    } else {
      const sniffed = await _detectFileType(buffer);
      if (!sniffed || !SNIFFED_DOCUMENT_MIME.has(sniffed.mime)) {
        throw AppError.badRequest(
          sniffed
            ? `File contents look like ${sniffed.mime} (.${sniffed.ext}), not a document.`
            : 'File contents are not a recognized document format.',
          'INVALID_DOCUMENT_FILE',
        );
      }
      // DOCX edge case: file-type reports plain ZIP for stripped or
      // legacy variants. Only accept when the declared MIME matches.
      if (
        sniffed.mime === 'application/zip' &&
        mimetype !==
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      ) {
        throw AppError.badRequest(
          'File contents are a ZIP archive, not a recognized document.',
          'INVALID_DOCUMENT_FILE',
        );
      }
    }

    const ext = DOCUMENT_MIME_TO_EXT[mimetype] || 'bin';
    const url = await storage.save(buffer, {
      ext,
      mimeType: mimetype,
      kind: 'document',
    });

    // Filename precedence: explicit `filename` form field, then the
    // multipart `originalname`, then a generic fallback. We never
    // pull the name from the storage URL (that's a UUID).
    const declaredName =
      typeof req.body?.filename === 'string' && req.body.filename.trim().length > 0
        ? req.body.filename.trim()
        : null;
    const filename = declaredName || originalname || `document.${ext}`;

    ok(res, {
      document_url: url,
      document_size_bytes: size,
      document_mime_type: mimetype,
      document_filename: filename,
      driver: storage.driverName(),
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { uploadAudio, uploadImage, uploadVideo, uploadDocument };

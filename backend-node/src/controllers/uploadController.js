const AppError = require('../utils/AppError');
const { ok } = require('../utils/response');
const storage = require('../storage');

// Allowed audio MIME types — guard against arbitrary file uploads.
// Extensions are normalised server-side; we never trust the client filename.
const ALLOWED_AUDIO_MIME = new Set([
  'audio/m4a',
  'audio/mp4',
  'audio/aac',
  'audio/x-m4a',
  'audio/mpeg', // mp3 fallback
]);

const MIME_TO_EXT = {
  'audio/m4a': 'm4a',
  'audio/mp4': 'm4a',
  'audio/aac': 'm4a',
  'audio/x-m4a': 'm4a',
  'audio/mpeg': 'mp3',
};

/**
 * POST /v1/uploads/audio
 *
 * Multipart form-data with field `file`. Returns the public URL the
 * client should attach to the next `sendMessage` call as `audio_url`.
 *
 * Optional `duration_ms` form field carries the client-side measured
 * duration so the receiver doesn't have to decode the file just to
 * render the bubble timer.
 */
async function uploadAudio(req, res, next) {
  try {
    if (!req.file) {
      throw AppError.badRequest('Missing audio file under field "file".');
    }
    const { mimetype, size, buffer } = req.file;
    if (!ALLOWED_AUDIO_MIME.has(mimetype)) {
      throw AppError.badRequest(
        `Unsupported audio type: ${mimetype}. Use M4A/AAC/MP3.`,
      );
    }
    // Hard ceiling per audio file. 60s @ 64kbps ≈ 480KB; 5MB is 10×
    // headroom for users who somehow send higher-bitrate clips.
    if (size > 5 * 1024 * 1024) {
      throw AppError.badRequest('Audio file too large (max 5MB).');
    }

    const ext = MIME_TO_EXT[mimetype] || 'bin';
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

module.exports = { uploadAudio };

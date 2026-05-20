const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');
const { batchEntityShareEnvelopes } = require('../services/entityShareEnvelope');
const { isAlbumColumnPresent, isVideoColumnsPresent, isVideoAlbumColumnsPresent, isForwardedColumnsPresent } = require('../services/schemaFeatureFlags');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let base = db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      .leftJoin('jobs', 'conversations.job_id', 'jobs.id');
    if (status) base = base.where('conversations.status', status);
    if (search) base = base.where((b) => b.whereILike('candidates.name', `%${search}%`).orWhereILike('businesses.name', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('conversations.*', 'candidates.name as candidate_name', 'candidates.initials as candidate_initials', 'businesses.name as business_name', 'businesses.initials as business_initials', 'jobs.title as job_title').orderBy('conversations.updated_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('conversations').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Conversation status → ${req.body.status}`, u.id, 'Messages');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const r = await db('conversations').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound();
    await db('conversations').where({ id: req.params.id }).del(); await log(req.user.email, 'Deleted conversation', r.id, 'Messages');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function thread(req, res, next) {
  try {
    const conv = await db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      .leftJoin('jobs', 'conversations.job_id', 'jobs.id')
      .where('conversations.id', req.params.id)
      .select(
        'conversations.*',
        'candidates.name as candidate_name',
        'candidates.initials as candidate_initials',
        'businesses.name as business_name',
        'businesses.initials as business_initials',
        'jobs.title as job_title',
      )
      .first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const { page = 1, limit = 200 } = req.query;
    // Sprint 4F — exclude synthetic 'reaction' rows from the admin
    // thread viewer too. They drive unread/last_message bookkeeping
    // for end users but are not real chat bubbles.
    const total = await db('messages')
      .where({ conversation_id: conv.id })
      .whereNot('attachment_type', 'reaction')
      .count('* as c').first().then(r => +r.c);
    // Phase 3D — surface reply preview for the admin thread viewer.
    // Same LEFT JOIN approach as candidate / business listMessages.
    // Album column is guarded so a redeploy that races ahead of the
    // migrate step doesn't 500 the admin thread.
    const albumReady = await isAlbumColumnPresent();
    // Forward columns (migration 041, not yet applied). Same pattern.
    const forwardReady = await isForwardedColumnsPresent();
    const videoReady = await isVideoColumnsPresent();
    const videoAlbumReady = await isVideoAlbumColumnsPresent();
    const selectCols = [
      'messages.id', 'messages.body', 'messages.is_read', 'messages.delivered_at',
      'messages.sender_id', 'messages.created_at',
      'messages.attachment_type',
      'messages.audio_url', 'messages.audio_duration_ms',
      'messages.audio_size_bytes', 'messages.audio_mime_type',
      'messages.image_url', 'messages.image_size_bytes',
      'messages.image_mime_type', 'messages.image_width',
      'messages.image_height',
      'messages.document_url', 'messages.document_size_bytes',
      'messages.document_mime_type', 'messages.document_filename',
      'messages.location_lat', 'messages.location_lng',
      'messages.location_address',
      'messages.deleted_for_everyone_at',
      'messages.reply_to_message_id',
      'messages.shared_entity_type',
      'messages.shared_entity_id',
      'users.name as sender_name', 'users.user_type as sender_type',
      'replied.body as reply_body',
      'replied.attachment_type as reply_attachment_type',
      'replied.audio_duration_ms as reply_audio_duration_ms',
      'replied.shared_entity_type as reply_shared_entity_type',
      'replied_user.user_type as reply_sender_type',
      'replied_user.name as reply_sender_name',
    ];
    if (albumReady) {
      selectCols.push('messages.album_image_urls');
      selectCols.push('replied.album_image_urls as reply_album_image_urls');
    }
    if (videoReady) {
      selectCols.push('messages.video_url');
      selectCols.push('messages.video_size_bytes');
      selectCols.push('messages.video_mime_type');
      selectCols.push('messages.video_duration_ms');
      selectCols.push('messages.video_width');
      selectCols.push('messages.video_height');
    }
    if (videoAlbumReady) {
      selectCols.push('messages.album_video_urls');
      selectCols.push('messages.album_video_metadata');
      selectCols.push('replied.album_video_urls as reply_album_video_urls');
    }
    if (forwardReady) {
      selectCols.push('messages.forwarded_from_message_id');
      selectCols.push('messages.is_forwarded');
    }
    const rawMsgs = await db('messages')
      .leftJoin('users', 'messages.sender_id', 'users.id')
      .leftJoin('messages as replied', 'messages.reply_to_message_id', 'replied.id')
      .leftJoin('users as replied_user', 'replied.sender_id', 'replied_user.id')
      .where('messages.conversation_id', conv.id)
      .whereNot('messages.attachment_type', 'reaction')
      .select(...selectCols)
      .orderBy('messages.created_at', 'asc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    // Phase 4 — batch entity-share envelopes for the admin viewer.
    const shareItems = rawMsgs
      .filter((m) => m.attachment_type === 'entity_share' && m.shared_entity_id)
      .map((m) => ({ type: m.shared_entity_type, id: m.shared_entity_id }));
    const shareEnvelopes = await batchEntityShareEnvelopes(shareItems, 'admin');

    // Sprint 4A — admin's own stars (private). Same per-user pattern as
    // candidate/business: admin only sees their own stars in the thread,
    // never other users'. Surfaces `is_starred_by_me` to keep the
    // payload shape stable across all 3 viewer roles.
    const ids = rawMsgs.map((m) => m.id);
    const starredIds = ids.length === 0
      ? new Set()
      : new Set(
          (await db('message_stars')
            .whereIn('message_id', ids)
            .where('user_id', req.user.id)
            .pluck('message_id')),
        );

    const msgs = rawMsgs.map((m) => {
      const {
        reply_body,
        reply_attachment_type,
        reply_audio_duration_ms,
        reply_shared_entity_type,
        reply_album_image_urls,
        reply_album_video_urls,
        reply_sender_type,
        reply_sender_name,
        ...rest
      } = m;
      let replyTo = null;
      if (m.reply_to_message_id && reply_attachment_type !== null) {
        replyTo = {
          id: m.reply_to_message_id,
          sender_type: reply_sender_type || null,
          sender_name: reply_sender_name || null,
          attachment_type: reply_attachment_type,
          body_preview: _replyBodyPreview(reply_attachment_type, reply_body, reply_shared_entity_type, reply_album_image_urls, reply_album_video_urls),
          audio_duration_ms: reply_audio_duration_ms || null,
        };
      }
      const sharedEntity = m.attachment_type === 'entity_share' && m.shared_entity_id
        ? (shareEnvelopes.get(`${m.shared_entity_type}:${m.shared_entity_id}`) || null)
        : null;
      return {
        ...rest,
        // Pre-migration: m.album_image_urls is undefined; ship null
        // so every admin payload always carries the field.
        album_image_urls: albumReady ? _normalizeAlbumUrls(m.album_image_urls) : null,
        album_video_urls: videoAlbumReady ? _normalizeAlbumUrls(m.album_video_urls) : null,
        album_video_metadata: videoAlbumReady ? _normalizeAlbumMetadata(m.album_video_metadata) : null,
        video_url: videoReady ? (m.video_url || null) : null,
        video_size_bytes: videoReady ? (m.video_size_bytes || null) : null,
        video_mime_type: videoReady ? (m.video_mime_type || null) : null,
        video_duration_ms: videoReady ? (m.video_duration_ms || null) : null,
        video_width: videoReady ? (m.video_width || null) : null,
        video_height: videoReady ? (m.video_height || null) : null,
        // Pre-migration: forward fields default to null/false. Once
        // migration 041 lands, the runtime probe flips this on
        // within 30s without a backend restart.
        forwarded_from_message_id: forwardReady ? (m.forwarded_from_message_id || null) : null,
        is_forwarded: forwardReady ? !!m.is_forwarded : false,
        reply_to: replyTo,
        shared_entity: sharedEntity,
        is_starred_by_me: starredIds.has(m.id),
      };
    });

    ok(res, { conversation: conv, messages: msgs, pagination: { page: +page, limit: +limit, total } });
  } catch (e) { next(e); }
}

/** See candidateController._replyBodyPreview / _entitySharePreview —
 *  keep the three implementations in sync. */
function _replyBodyPreview(attachmentType, body, sharedEntityType, albumImageUrls, albumVideoUrls) {
  if (attachmentType === 'deleted') return 'This message was deleted';
  if (attachmentType === 'audio') return '🎤 Voice message';
  if (attachmentType === 'image') return '🖼 Photo';
  if (attachmentType === 'document') return '📄 Document';
  if (attachmentType === 'video') return '🎥 Video';
  if (attachmentType === 'location') return '📍 Location';
  if (attachmentType === 'entity_share') {
    return _entitySharePreview(sharedEntityType);
  }
  if (attachmentType === 'album') {
    const urls = _normalizeAlbumUrls(albumImageUrls);
    const len = Array.isArray(urls) ? urls.length : 0;
    return `📷 Album · ${len} photo${len === 1 ? '' : 's'}`;
  }
  if (attachmentType === 'video_album') {
    const urls = _normalizeAlbumUrls(albumVideoUrls);
    const len = Array.isArray(urls) ? urls.length : 0;
    return `🎥 Album · ${len} video${len === 1 ? '' : 's'}`;
  }
  return (body || '').slice(0, 200);
}

/** See candidateController._normalizeAlbumUrls — keep in sync. */
function _normalizeAlbumUrls(value) {
  if (value == null) return null;
  if (Array.isArray(value)) return value;
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : null;
    } catch (_) {
      return null;
    }
  }
  return null;
}
/** See candidateController._normalizeAlbumMetadata — keep in sync. */
function _normalizeAlbumMetadata(value) {
  if (value == null) return null;
  if (Array.isArray(value)) return value;
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : null;
    } catch (_) {
      return null;
    }
  }
  return null;
}
function _entitySharePreview(type) {
  switch (type) {
    case 'profile_candidate':
    case 'profile_business':
      return '📋 Profile';
    case 'job':
      return '💼 Job';
    case 'interview':
      return '📅 Interview';
    default:
      return '📎 Shared item';
  }
}

module.exports = { list, updateStatus, remove, thread };

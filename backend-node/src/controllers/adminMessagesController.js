const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

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
    const total = await db('messages').where({ conversation_id: conv.id }).count('* as c').first().then(r => +r.c);
    // Phase 3D — surface reply preview for the admin thread viewer.
    // Same LEFT JOIN approach as candidate / business listMessages.
    const rawMsgs = await db('messages')
      .leftJoin('users', 'messages.sender_id', 'users.id')
      .leftJoin('messages as replied', 'messages.reply_to_message_id', 'replied.id')
      .leftJoin('users as replied_user', 'replied.sender_id', 'replied_user.id')
      .where('messages.conversation_id', conv.id)
      .select(
        'messages.id', 'messages.body', 'messages.is_read', 'messages.delivered_at',
        'messages.sender_id', 'messages.created_at',
        'messages.reply_to_message_id',
        'users.name as sender_name', 'users.user_type as sender_type',
        'replied.body as reply_body',
        'replied.attachment_type as reply_attachment_type',
        'replied.audio_duration_ms as reply_audio_duration_ms',
        'replied_user.user_type as reply_sender_type',
        'replied_user.name as reply_sender_name',
      )
      .orderBy('messages.created_at', 'asc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    const msgs = rawMsgs.map((m) => {
      const {
        reply_body,
        reply_attachment_type,
        reply_audio_duration_ms,
        reply_sender_type,
        reply_sender_name,
        ...rest
      } = m;
      let replyTo = null;
      if (m.reply_to_message_id && reply_attachment_type !== null) {
        const isVoice = reply_attachment_type === 'audio';
        replyTo = {
          id: m.reply_to_message_id,
          sender_type: reply_sender_type || null,
          sender_name: reply_sender_name || null,
          attachment_type: reply_attachment_type,
          body_preview: isVoice
            ? '🎤 Voice message'
            : (reply_body || '').slice(0, 200),
          audio_duration_ms: reply_audio_duration_ms || null,
        };
      }
      return { ...rest, reply_to: replyTo };
    });

    ok(res, { conversation: conv, messages: msgs, pagination: { page: +page, limit: +limit, total } });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, remove, thread };

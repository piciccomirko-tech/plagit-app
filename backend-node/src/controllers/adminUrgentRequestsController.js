const db = require('../config/db');
const { paginated } = require('../utils/response');
const { isUrgentRequestsTablePresent } = require('../services/schemaFeatureFlags');

/**
 * Stage AL.5.9 — Admin urgent_requests visibility (read-only).
 *
 * Mirrors the chrome of `adminJobsController.list` for consistency:
 * paginated list with optional `status` filter + `search` ILIKE
 * across role/business name/location. Joins:
 *   • businesses → expose business name + initials + verified seal
 *   • candidates  → expose candidate name when `filled_by_candidate_id`
 *                   is non-null (LEFT JOIN, so unfilled rows still
 *                   return)
 *
 * Read-only — no admin moderation in AL.5.9 (decision #1). The
 * business owns the urgent_request lifecycle (AL.5.2 PATCH cancel,
 * AL.5.6 candidate accept). Admin observability only.
 *
 * Schema-flag-gated on the `urgent_requests` table (mig 052) so a
 * pre-mig deploy returns 503, not 500.
 */
async function list(req, res, next) {
  try {
    if (!(await isUrgentRequestsTablePresent())) {
      return res.status(503).json({
        success: false,
        error: 'Urgent requests are temporarily unavailable.',
        code: 'URGENT_REQUESTS_NOT_READY',
      });
    }
    const { page = 1, limit = 50, status, search } = req.query;
    const pageN = Math.max(1, parseInt(page, 10) || 1);
    const limitN = Math.max(1, Math.min(parseInt(limit, 10) || 50, 100));

    let base = db('urgent_requests')
      .leftJoin('businesses', 'urgent_requests.business_id', 'businesses.id')
      .leftJoin('candidates', 'urgent_requests.filled_by_candidate_id', 'candidates.id');

    if (status) {
      base = base.where('urgent_requests.status', status);
    }
    if (search) {
      const q = `%${search}%`;
      base = base.where((b) => b
        .whereILike('urgent_requests.role', q)
        .orWhereILike('businesses.name', q)
        .orWhereILike('urgent_requests.location', q));
    }

    const total = await base.clone().count('urgent_requests.id as c').first().then((r) => +r.c);
    const rows = await base.clone()
      .select(
        'urgent_requests.id',
        'urgent_requests.business_id',
        'urgent_requests.role',
        'urgent_requests.location',
        'urgent_requests.starts_at',
        'urgent_requests.ends_at',
        'urgent_requests.expires_at',
        'urgent_requests.status',
        'urgent_requests.notes',
        'urgent_requests.filled_by_candidate_id',
        'urgent_requests.created_at',
        'urgent_requests.updated_at',
        'businesses.name as business_name',
        'businesses.initials as business_initials',
        'businesses.is_verified as business_is_verified',
        'candidates.name as candidate_name',
      )
      .orderBy('urgent_requests.created_at', 'desc')
      .limit(limitN)
      .offset((pageN - 1) * limitN);

    paginated(res, rows, { page: pageN, limit: limitN, total });
  } catch (e) { next(e); }
}

module.exports = { list };

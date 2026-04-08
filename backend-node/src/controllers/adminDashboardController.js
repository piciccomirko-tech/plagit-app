const db = require('../config/db');

// GET /admin/dashboard/stats
async function getStats(req, res, next) {
  try {
    const [users, businesses, jobs, applications, interviews, reports, subscriptions, convos, notifs, posts] = await Promise.all([
      db('users').select(db.raw(`
        count(*) as total,
        count(*) filter (where user_type = 'candidate') as candidates,
        count(*) filter (where user_type = 'business') as businesses_count,
        count(*) filter (where is_verified = true) as verified,
        count(*) filter (where status = 'suspended') as suspended,
        count(*) filter (where user_type = 'candidate' and created_at > now() - interval '30 days') as new_candidates
      `)).first(),
      db('businesses').select(db.raw(`
        count(*) filter (where created_at > now() - interval '30 days') as new_businesses,
        count(*) filter (where is_verified = false and status = 'active') as pending_verification
      `)).first(),
      db('jobs').select(db.raw(`
        count(*) filter (where status = 'active') as active,
        count(*) filter (where status = 'paused') as paused,
        count(*) filter (where status = 'pending_review') as need_review,
        count(*) filter (where status = 'active' and views = 0) as no_applicants,
        count(*) filter (where status = 'active' and expiry_date < current_date + interval '7 days' and expiry_date >= current_date) as expiring
      `)).first(),
      db('applications').select(db.raw(`
        count(*) filter (where created_at::date = current_date) as today,
        count(*) filter (where status = 'applied') as applied,
        count(*) filter (where status = 'under_review') as review,
        count(*) filter (where status = 'interview') as interview,
        count(*) filter (where status = 'offer') as offer
      `)).first(),
      db('interviews').select(db.raw(`
        count(*) filter (where scheduled_at::date = current_date) as today,
        count(*) filter (where scheduled_at::date = current_date + 1) as tomorrow,
        count(*) filter (where scheduled_at >= date_trunc('week', current_date) and scheduled_at < date_trunc('week', current_date) + interval '7 days') as this_week,
        count(*) filter (where status = 'pending') as pending
      `)).first(),
      db('reports').select(db.raw(`
        count(*) filter (where status = 'open') as open,
        count(*) filter (where severity in ('urgent', 'high') and status = 'open') as urgent
      `)).first(),
      db('subscriptions').select(db.raw(`
        count(*) filter (where status = 'active') as active,
        count(*) filter (where status = 'trial') as trial,
        count(*) filter (where status = 'expiring') as renewing,
        count(*) filter (where payment_state = 'failed') as failed
      `)).first(),
      db('conversations').select(db.raw(`
        count(*) filter (where status = 'flagged') as flagged,
        count(*) filter (where status != 'archived') as unread
      `)).first(),
      db('notifications').select(db.raw(`
        count(*) filter (where delivery_state = 'pending') as pending
      `)).first(),
      db('community_posts').select(db.raw(`
        count(*) filter (where status = 'published') as published,
        count(*) filter (where status = 'draft') as drafts,
        count(*) filter (where is_featured_on_home = true) as featured,
        coalesce(sum(views), 0) as total_views
      `)).first(),
    ]);

    res.json({
      total_users: parseInt(users.total) || 0,
      total_candidates: parseInt(users.candidates) || 0,
      total_businesses: parseInt(users.businesses_count) || 0,
      verified_users: parseInt(users.verified) || 0,
      suspended_users: parseInt(users.suspended) || 0,
      new_businesses: parseInt(businesses.new_businesses) || 0,
      new_candidates: parseInt(users.new_candidates) || 0,
      active_jobs: parseInt(jobs.active) || 0,
      paused_jobs: parseInt(jobs.paused) || 0,
      expiring_jobs: parseInt(jobs.expiring) || 0,
      no_applicant_jobs: parseInt(jobs.no_applicants) || 0,
      jobs_need_review: parseInt(jobs.need_review) || 0,
      applications_today: parseInt(applications.today) || 0,
      applied_count: parseInt(applications.applied) || 0,
      review_count: parseInt(applications.review) || 0,
      interview_count: parseInt(applications.interview) || 0,
      offer_count: parseInt(applications.offer) || 0,
      hired_count: 0,
      interviews_today: parseInt(interviews.today) || 0,
      interviews_tomorrow: parseInt(interviews.tomorrow) || 0,
      interviews_this_week: parseInt(interviews.this_week) || 0,
      pending_interviews: parseInt(interviews.pending) || 0,
      open_reports: parseInt(reports.open) || 0,
      urgent_reports: parseInt(reports.urgent) || 0,
      active_plans: parseInt(subscriptions.active) || 0,
      trial_plans: parseInt(subscriptions.trial) || 0,
      renewing_plans: parseInt(subscriptions.renewing) || 0,
      failed_payments: parseInt(subscriptions.failed) || 0,
      published_posts: parseInt(posts.published) || 0,
      draft_posts: parseInt(posts.drafts) || 0,
      featured_posts: parseInt(posts.featured) || 0,
      total_views: parseInt(posts.total_views) || 0,
      unread_messages: parseInt(convos.unread) || 0,
      pending_notifications: parseInt(notifs.pending) || 0,
      flagged_content: parseInt(convos.flagged) || 0,
      // Needs attention counts
      pending_business_verification: parseInt(businesses.pending_verification) || 0,
    });
  } catch (err) {
    next(err);
  }
}

// GET /admin/dashboard/activity
async function getRecentActivity(req, res, next) {
  try {
    const logs = await db('admin_logs')
      .select('id', 'action', 'target', 'category', 'admin_user', 'result', 'created_at')
      .orderBy('created_at', 'desc')
      .limit(10);
    res.json({ success: true, data: logs });
  } catch (err) {
    next(err);
  }
}

// GET /admin/dashboard/attention
async function getNeedsAttention(req, res, next) {
  try {
    const [urgentReports, failedPayments, pendingInterviews, pendingBiz, noAppJobs] = await Promise.all([
      db('reports').where({ status: 'open' }).whereIn('severity', ['urgent', 'high']).count('* as c').first(),
      db('subscriptions').where({ payment_state: 'failed' }).count('* as c').first(),
      db('interviews').where({ status: 'pending' }).count('* as c').first(),
      db('businesses').where({ is_verified: false, status: 'active' }).count('* as c').first(),
      db('jobs').where({ status: 'active' }).where('views', 0).count('* as c').first(),
    ]);

    const items = [];
    const ur = parseInt(urgentReports.c);
    if (ur > 0) items.push({ icon: 'flag.fill', color: 'urgent', text: `${ur} high-priority report${ur > 1 ? 's' : ''}`, badge: 'Urgent', route: 'reports' });
    const fp = parseInt(failedPayments.c);
    if (fp > 0) items.push({ icon: 'creditcard', color: 'urgent', text: `${fp} failed payment${fp > 1 ? 's' : ''}`, badge: 'Urgent', route: 'subscriptions' });
    const pi = parseInt(pendingInterviews.c);
    if (pi > 0) items.push({ icon: 'calendar', color: 'indigo', text: `${pi} interview${pi > 1 ? 's' : ''} pending confirmation`, badge: 'Action', route: 'interviews' });
    const pb = parseInt(pendingBiz.c);
    if (pb > 0) items.push({ icon: 'building.2', color: 'amber', text: `${pb} business${pb > 1 ? 'es' : ''} pending verification`, badge: 'Review', route: 'businesses' });
    const na = parseInt(noAppJobs.c);
    if (na > 0) items.push({ icon: 'briefcase', color: 'amber', text: `${na} job${na > 1 ? 's' : ''} with no applicants`, badge: 'Review', route: 'jobs' });

    res.json({ success: true, data: items });
  } catch (err) {
    next(err);
  }
}

module.exports = { getStats, getRecentActivity, getNeedsAttention };

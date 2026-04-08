exports.seed = async function (knex) {
  await knex('conversations').del();
  await knex('notifications').del();
  await knex('reports').del();
  await knex('subscriptions').del();

  const candidates = await knex('candidates').select('id', 'name');
  const businesses = await knex('businesses').select('id', 'name', 'avatar_hue');
  const jobs = await knex('jobs').select('id', 'title', 'business_id');
  const users = await knex('users').select('id', 'name', 'user_type');

  const byC = Object.fromEntries(candidates.map(c => [c.name, c]));
  const byB = Object.fromEntries(businesses.map(b => [b.name, b]));
  const byJ = Object.fromEntries(jobs.map(j => [j.title, j]));
  const byU = Object.fromEntries(users.map(u => [u.name, u]));

  // ─── Conversations ───
  const convos = [
    { c: 'Elena Rossi', b: 'Nobu Restaurant', j: 'Senior Chef', msg: 'Thank you for considering me.', status: 'normal', flag_count: 0, support_state: 'none', is_interview_related: true, no_reply_days: 0 },
    { c: 'James Park', b: 'The Ritz London', j: 'Bar Manager', msg: 'Looking forward to the interview.', status: 'normal', flag_count: 0, support_state: 'none', is_interview_related: true, no_reply_days: 0 },
    { c: 'Sofia Blanc', b: 'Four Seasons', j: 'Sommelier', msg: 'Thank you for the interview experience.', status: 'normal', flag_count: 0, support_state: 'none', is_interview_related: true, no_reply_days: 0 },
    { c: 'Tom Chen', b: 'Dishoom Soho', j: 'Waitstaff', msg: 'Hi, I applied last week. Any update?', status: 'normal', flag_count: 0, support_state: 'none', is_interview_related: false, no_reply_days: 5 },
    { c: 'Marco Bianchi', b: 'Nobu Restaurant', j: 'Senior Chef', msg: 'I haven\'t received interview details.', status: 'under_review', flag_count: 1, support_state: 'open', is_interview_related: true, no_reply_days: 4 },
    { c: 'Priya Sharma', b: 'Fabric London', j: 'Bartender', msg: 'This is inappropriate. Reporting.', status: 'flagged', flag_count: 2, support_state: 'open', is_interview_related: false, no_reply_days: 0 },
    { c: 'David Okafor', b: 'Sky Lounge', j: 'Host / Hostess', msg: 'Send money for uniform deposit...', status: 'flagged', flag_count: 3, support_state: 'escalated', is_interview_related: false, no_reply_days: 0 },
  ];
  const convoRows = convos.map(cv => {
    const c = byC[cv.c], b = byB[cv.b], j = byJ[cv.j];
    if (!c || !b || !j) return null;
    return { candidate_id: c.id, business_id: b.id, job_id: j.id, last_message: cv.msg, status: cv.status, flag_count: cv.flag_count, support_state: cv.support_state, is_interview_related: cv.is_interview_related, no_reply_days: cv.no_reply_days };
  }).filter(Boolean);
  if (convoRows.length) await knex('conversations').insert(convoRows);

  // ─── Notifications ───
  const notifs = [
    { r: 'Elena Rossi', type: 'push', title: 'Interview Confirmed — Nobu Restaurant', entity: 'Interview', route: 'interview-detail', state: 'delivered', read: true, retries: 0 },
    { r: 'Nobu Restaurant', type: 'email', title: 'New Application — Senior Chef', entity: 'Application', route: 'application-detail', state: 'delivered', read: true, retries: 0 },
    { r: 'James Park', type: 'in_app', title: 'Profile Verification Complete', entity: 'Profile', route: 'profile', state: 'delivered', read: false, retries: 0 },
    { r: 'The Ritz London', type: 'push', title: 'Job Expiring Soon — Bar Manager', entity: 'Job', route: 'job-detail', state: 'failed', read: false, retries: 2 },
    { r: 'Sofia Blanc', type: 'email', title: 'Welcome to Plagit', entity: 'Onboarding', route: 'onboarding', state: 'delivered', read: true, retries: 0 },
    { r: 'Anna Weber', type: 'sms', title: 'Interview Reminder — Tomorrow 11 AM', entity: 'Interview', route: 'interview-detail', state: 'pending', read: false, retries: 0 },
    { r: 'Dishoom Soho', type: 'email', title: 'Subscription Renewal Reminder', entity: 'Subscription', route: 'subscription', state: 'failed', read: false, retries: 3 },
    { r: 'Mirko Picicco', type: 'in_app', title: 'Report Resolved — Spam Listing', entity: 'Report', route: 'report-detail', state: 'delivered', read: true, retries: 0 },
    { r: 'Tom Chen', type: 'push', title: 'New Job Match — Line Cook', entity: 'Job', route: 'job-detail', state: 'delivered', read: false, retries: 0 },
    { r: 'Fabric London', type: 'email', title: 'Payment Failed — Update Card', entity: 'Invoice', route: 'billing', state: 'failed', read: false, retries: 1 },
  ];
  const notifRows = notifs.map(n => {
    const u = byU[n.r]; if (!u) return null;
    return { recipient_id: u.id, notification_type: n.type, title: n.title, linked_entity: n.entity, destination_route: n.route, delivery_state: n.state, is_read: n.read, sent_at: n.state === 'delivered' ? knex.fn.now() : null, retry_count: n.retries };
  }).filter(Boolean);
  if (notifRows.length) await knex('notifications').insert(notifRows);

  // ─── Reports ───
  const reports = [
    { title: 'Fake Job Listing — Scam Salary', entity: 'Sky Lounge', initials: 'SL', type: 'job', reason: 'Scam', severity: 'urgent', status: 'open', reporter: 'Elena Rossi', assigned: 'Mirko', prev: 4, flags: 3, summary: 'Job listing with unrealistic salary.', hue: 0.42 },
    { title: 'Harassment in Messages', entity: 'Unknown User', initials: 'UU', type: 'message', reason: 'Harassment', severity: 'urgent', status: 'open', reporter: 'Priya Sharma', assigned: '', prev: 2, flags: 2, summary: 'Inappropriate messages.', hue: 0.30 },
    { title: 'Spam Job Batch — 12 Posts', entity: 'Unknown Venue', initials: 'UV', type: 'job', reason: 'Spam', severity: 'high', status: 'open', reporter: 'System', assigned: '', prev: 0, flags: 1, summary: 'Auto-flagged: 12 identical postings.', hue: 0.30 },
    { title: 'Suspicious Account Activity', entity: 'Tom Chen', initials: 'TC', type: 'user', reason: 'Fake', severity: 'high', status: 'under_review', reporter: 'System', assigned: 'Mirko', prev: 0, flags: 1, summary: 'Multiple logins from different countries.', hue: 0.35 },
    { title: 'Duplicate Business Profile', entity: 'Dishoom Soho', initials: 'DS', type: 'business', reason: 'Misleading', severity: 'medium', status: 'under_review', reporter: 'Priya Sharma', assigned: 'Mirko', prev: 0, flags: 1, summary: 'Business appears twice.', hue: 0.48 },
    { title: 'Misleading Description', entity: 'Fabric London', initials: 'FB', type: 'business', reason: 'Misleading', severity: 'medium', status: 'open', reporter: 'James Park', assigned: '', prev: 1, flags: 1, summary: 'Claims Michelin star but is a nightclub.', hue: 0.35 },
    { title: 'Interview No-Show Dispute', entity: 'James Park', initials: 'JP', type: 'user', reason: 'Abuse', severity: 'low', status: 'under_review', reporter: 'The Ritz London', assigned: '', prev: 0, flags: 0, summary: 'Candidate did not show for interview.', hue: 0.38 },
    { title: 'Payment Scam Attempt', entity: 'Sky Lounge', initials: 'SL', type: 'business', reason: 'Scam', severity: 'urgent', status: 'resolved', reporter: 'Multiple', assigned: 'Mirko', prev: 5, flags: 5, summary: 'Business requesting payments. Banned.', hue: 0.42 },
  ];
  await knex('reports').insert(reports.map(r => ({
    title: r.title, reported_entity: r.entity, reported_initials: r.initials,
    type: r.type, reason: r.reason, severity: r.severity, status: r.status,
    reporter: r.reporter, assigned_admin: r.assigned, previous_reports: r.prev,
    flag_count: r.flags, summary: r.summary, avatar_hue: r.hue,
  })));

  // ─── Subscriptions ───
  const subData = [
    { biz: 'Nobu Restaurant', plan: 'premium', status: 'active', cycle: 'monthly', renewal: '2026-04-15', amount: '$299/mo', payment: 'paid', auto: true, invoices: 14 },
    { biz: 'The Ritz London', plan: 'enterprise', status: 'active', cycle: 'annual', renewal: '2026-05-01', amount: '$4,999/yr', payment: 'paid', auto: true, invoices: 2 },
    { biz: 'Dishoom Soho', plan: 'basic', status: 'trial', cycle: 'monthly', renewal: '2026-04-10', amount: '$99/mo', payment: 'pending', auto: true, invoices: 0 },
    { biz: 'Four Seasons', plan: 'enterprise', status: 'active', cycle: 'annual', renewal: '2026-06-01', amount: '$4,999/yr', payment: 'paid', auto: true, invoices: 2 },
    { biz: 'Fabric London', plan: 'basic', status: 'failed', cycle: 'monthly', renewal: '2026-03-20', amount: '$99/mo', payment: 'failed', auto: true, invoices: 3 },
    { biz: 'Sky Lounge', plan: 'premium', status: 'cancelled', cycle: 'monthly', renewal: null, amount: '$299/mo', payment: 'refunded', auto: false, invoices: 8 },
  ];
  const subRows = subData.map(s => {
    const b = byB[s.biz]; if (!b) return null;
    return { business_id: b.id, plan: s.plan, status: s.status, billing_cycle: s.cycle, renewal_date: s.renewal, amount: s.amount, trial_end: s.status === 'trial' ? '2026-04-10' : null, auto_renew: s.auto, invoice_count: s.invoices, payment_state: s.payment, avatar_hue: b.avatar_hue };
  }).filter(Boolean);
  if (subRows.length) await knex('subscriptions').insert(subRows);
};

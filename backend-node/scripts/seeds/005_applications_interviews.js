exports.seed = async function (knex) {
  await knex('interviews').del();
  await knex('applications').del();

  const candidates = await knex('candidates').select('id', 'name');
  const jobs = await knex('jobs').select('id', 'title', 'business_id');
  const byCandidate = Object.fromEntries(candidates.map(c => [c.name, c]));
  const byJobTitle = Object.fromEntries(jobs.map(j => [j.title, j]));

  const apps = [
    { candidate: 'Elena Rossi', job: 'Senior Chef', status: 'interview', has_interview: true, has_offer: false, flag_count: 0, days_since_update: 1 },
    { candidate: 'James Park', job: 'Bar Manager', status: 'under_review', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 0 },
    { candidate: 'Sofia Blanc', job: 'Sommelier', status: 'applied', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 3 },
    { candidate: 'Marco Bianchi', job: 'Senior Chef', status: 'shortlisted', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 2 },
    { candidate: 'Anna Weber', job: 'Restaurant Manager', status: 'offer', has_interview: true, has_offer: true, flag_count: 0, days_since_update: 4 },
    { candidate: 'Tom Chen', job: 'Waitstaff', status: 'rejected', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 7 },
    { candidate: 'Priya Sharma', job: 'Waitstaff', status: 'withdrawn', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 3 },
    { candidate: 'David Okafor', job: 'Bartender', status: 'applied', has_interview: false, has_offer: false, flag_count: 0, days_since_update: 17 },
  ];

  const appRows = [];
  for (const a of apps) {
    const c = byCandidate[a.candidate];
    const j = byJobTitle[a.job];
    if (!c || !j) continue;
    appRows.push({
      candidate_id: c.id, job_id: j.id, status: a.status,
      has_interview: a.has_interview, has_offer: a.has_offer,
      flag_count: a.flag_count, days_since_update: a.days_since_update,
    });
  }
  if (appRows.length > 0) await knex('applications').insert(appRows);

  // Interviews for applications that have them
  const insertedApps = await knex('applications').where('has_interview', true).select('id', 'candidate_id', 'job_id');

  const ivRows = insertedApps.map((app, i) => ({
    application_id: app.id,
    candidate_id: app.candidate_id,
    job_id: app.job_id,
    scheduled_at: new Date(Date.now() + (i + 1) * 86400000).toISOString(), // stagger by day
    timezone: 'GMT',
    interview_type: i % 2 === 0 ? 'video_call' : 'in_person',
    status: i === 0 ? 'confirmed' : 'pending',
    location: i % 2 === 0 ? '—' : 'On-site',
    meeting_link: i % 2 === 0 ? 'https://zoom.us/j/123456' : '—',
    reschedule_count: 0,
    flag_count: 0,
  }));

  if (ivRows.length > 0) await knex('interviews').insert(ivRows);
};

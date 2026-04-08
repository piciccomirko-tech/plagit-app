exports.seed = async function (knex) {
  await knex('jobs').del();
  const businesses = await knex('businesses').select('id', 'name', 'avatar_hue');
  const byName = Object.fromEntries(businesses.map(b => [b.name, b]));

  const jobs = [
    { biz: 'Nobu Restaurant', title: 'Senior Chef', location: 'Dubai, UAE', employment_type: 'Full-time', salary: '$5,500/mo', category: 'Fine Dining', status: 'active', is_featured: true, views: 342, flag_count: 0 },
    { biz: 'The Ritz London', title: 'Bar Manager', location: 'London, UK', employment_type: 'Full-time', salary: '£45–55k', category: 'Luxury Hotel', status: 'active', is_featured: true, views: 218, flag_count: 0 },
    { biz: 'Dishoom Soho', title: 'Waitstaff', location: 'London, UK', employment_type: 'Part-time', salary: '£14/hr', category: 'Casual Dining', status: 'pending_review', is_featured: false, views: 45, flag_count: 0 },
    { biz: 'Fabric London', title: 'Bartender', location: 'London, UK', employment_type: 'Part-time', salary: '£15/hr + tips', category: 'Nightclub', status: 'active', is_featured: false, views: 28, flag_count: 0 },
    { biz: 'Sky Lounge', title: 'Host / Hostess', location: 'Dubai, UAE', employment_type: 'Full-time', salary: '$3,000/mo', category: 'Rooftop Bar', status: 'flagged', is_featured: false, views: 156, flag_count: 3 },
    { biz: 'Four Seasons', title: 'Sommelier', location: 'Paris, FR', employment_type: 'Full-time', salary: '€3,800/mo', category: 'Luxury Hotel', status: 'paused', is_featured: false, views: 189, flag_count: 0 },
    { biz: 'Nobu Restaurant', title: 'Sous Chef', location: 'Dubai, UAE', employment_type: 'Full-time', salary: '$4,200/mo', category: 'Fine Dining', status: 'active', is_featured: false, views: 120, flag_count: 0 },
    { biz: 'The Ritz London', title: 'Restaurant Manager', location: 'London, UK', employment_type: 'Full-time', salary: '£4,800/mo', category: 'Luxury Hotel', status: 'active', is_featured: false, views: 94, flag_count: 0 },
    { biz: 'Four Seasons', title: 'Line Cook', location: 'Paris, FR', employment_type: 'Full-time', salary: '€2,800/mo', category: 'Luxury Hotel', status: 'draft', is_featured: false, views: 0, flag_count: 0 },
    { biz: 'Nobu Restaurant', title: 'Night Reception', location: 'Dubai, UAE', employment_type: 'Part-time', salary: '$2,000/mo', category: 'Fine Dining', status: 'closed', is_featured: false, views: 67, flag_count: 0 },
  ];

  const rows = jobs.map(j => {
    const b = byName[j.biz];
    if (!b) return null;
    return {
      business_id: b.id, title: j.title, location: j.location, employment_type: j.employment_type,
      salary: j.salary, category: j.category, status: j.status, is_featured: j.is_featured,
      expiry_date: '2026-04-30', views: j.views, flag_count: j.flag_count, avatar_hue: b.avatar_hue,
    };
  }).filter(Boolean);

  if (rows.length > 0) await knex('jobs').insert(rows);
};

exports.seed = async function (knex) {
  await knex('businesses').del();

  // Get business user IDs
  const bizUsers = await knex('users').where('user_type', 'business').select('id', 'name', 'initials', 'email', 'phone', 'location', 'role', 'status', 'is_verified', 'profile_strength', 'flag_count', 'avatar_hue', 'plan');

  const bizData = {
    'Nobu Restaurant':     { venue_type: 'Fine Dining',  plan_status: 'active',    renewal_date: '2026-04-15', response_rate: 94 },
    'The Ritz London':     { venue_type: 'Luxury Hotel',  plan_status: 'active',    renewal_date: '2026-05-01', response_rate: 98 },
    'Dishoom Soho':        { venue_type: 'Casual Dining', plan_status: 'trial',     renewal_date: '2026-04-10', response_rate: 72 },
    'Sky Lounge':          { venue_type: 'Rooftop Bar',   plan_status: 'cancelled', renewal_date: null,         response_rate: 12 },
    'Fabric London':       { venue_type: 'Nightclub',     plan_status: 'expired',   renewal_date: '2026-03-20', response_rate: 45 },
    'Four Seasons':        { venue_type: 'Luxury Hotel',  plan_status: 'active',    renewal_date: '2026-06-01', response_rate: 91 },
  };

  const rows = bizUsers.map((u) => {
    const extra = bizData[u.name] || { venue_type: 'Other', plan_status: 'active', renewal_date: null, response_rate: 50 };
    return {
      user_id: u.id,
      name: u.name,
      initials: u.initials,
      venue_type: extra.venue_type,
      location: u.location,
      contact: u.name,
      email: u.email,
      status: u.status,
      is_verified: u.is_verified,
      is_featured: u.name === 'Nobu Restaurant' || u.name === 'The Ritz London',
      plan: u.plan || 'Basic',
      plan_status: extra.plan_status,
      renewal_date: extra.renewal_date,
      response_rate: extra.response_rate,
      flag_count: u.flag_count,
      avatar_hue: u.avatar_hue,
    };
  });

  if (rows.length > 0) await knex('businesses').insert(rows);
};

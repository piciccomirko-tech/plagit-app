const bcrypt = require('bcryptjs');

exports.seed = async function (knex) {
  // Clean up in order (respect foreign keys)
  await knex('interviews').del();
  await knex('applications').del();
  await knex('conversations').del();
  await knex('notifications').del();
  await knex('subscriptions').del();
  await knex('jobs').del();
  await knex('candidates').del();
  await knex('businesses').del();
  await knex('reports').del();
  await knex('refresh_tokens').del();
  await knex('admin_logs').del();
  await knex('users').del();

  const hash = await bcrypt.hash(process.env.ADMIN_SEED_PASSWORD || 'admin2026', 10);
  const userHash = await bcrypt.hash(process.env.USER_SEED_PASSWORD || 'user2026', 10);

  await knex('users').insert([
    // ─── Admin ───
    {
      name: 'Mirko Picicco', initials: 'MP', email: 'mirko@plagit.com',
      password_hash: hash, phone: '+971 50 999', user_type: 'admin',
      admin_role: 'super_admin', location: 'Dubai, UAE', role: 'Super Admin',
      status: 'active', is_verified: true, profile_strength: 100,
      flag_count: 0, avatar_hue: 0.50, plan: null,
    },

    // ─── Candidates ───
    {
      name: 'Elena Rossi', initials: 'ER', email: 'elena@email.com',
      password_hash: userHash, phone: '+39 333 1234', user_type: 'candidate',
      location: 'Milan, IT', role: 'Executive Chef',
      status: 'active', is_verified: true, profile_strength: 92,
      flag_count: 0, avatar_hue: 0.52,
    },
    {
      name: 'James Park', initials: 'JP', email: 'james@email.com',
      password_hash: userHash, phone: '+44 7700 1234', user_type: 'candidate',
      location: 'London, UK', role: 'Bar Manager',
      status: 'active', is_verified: false, profile_strength: 65,
      flag_count: 0, avatar_hue: 0.38,
    },
    {
      name: 'Sofia Blanc', initials: 'SB', email: 'sofia@email.com',
      password_hash: userHash, phone: '+33 6 1234', user_type: 'candidate',
      location: 'Paris, FR', role: 'Sommelier',
      status: 'active', is_verified: true, profile_strength: 88,
      flag_count: 0, avatar_hue: 0.62,
    },
    {
      name: 'Marco Bianchi', initials: 'MB', email: 'marco@email.com',
      password_hash: userHash, phone: '+971 50 1234', user_type: 'candidate',
      location: 'Dubai, UAE', role: 'Sous Chef',
      status: 'active', is_verified: false, profile_strength: 45,
      flag_count: 0, avatar_hue: 0.45,
    },
    {
      name: 'Anna Weber', initials: 'AW', email: 'anna@email.com',
      password_hash: userHash, phone: '+49 170 1234', user_type: 'candidate',
      location: 'Berlin, DE', role: 'Restaurant Manager',
      status: 'suspended', is_verified: true, profile_strength: 80,
      flag_count: 2, avatar_hue: 0.58,
    },
    {
      name: 'Tom Chen', initials: 'TC', email: 'tom@email.com',
      password_hash: userHash, phone: '+61 4 1234', user_type: 'candidate',
      location: 'Sydney, AU', role: 'Line Cook',
      status: 'active', is_verified: false, profile_strength: 35,
      flag_count: 0, avatar_hue: 0.35,
    },
    {
      name: 'Priya Sharma', initials: 'PS', email: 'priya@email.com',
      password_hash: userHash, phone: '+44 7900 5678', user_type: 'candidate',
      location: 'London, UK', role: 'Waitstaff',
      status: 'active', is_verified: false, profile_strength: 55,
      flag_count: 0, avatar_hue: 0.42,
    },
    {
      name: 'David Okafor', initials: 'DO', email: 'david@email.com',
      password_hash: userHash, phone: '+44 7800 9012', user_type: 'candidate',
      location: 'London, UK', role: 'Bartender',
      status: 'active', is_verified: false, profile_strength: 60,
      flag_count: 0, avatar_hue: 0.68,
    },

    // ─── Businesses ───
    {
      name: 'Nobu Restaurant', initials: 'NR', email: 'hr@nobu.com',
      password_hash: userHash, phone: '+971 4 1234', user_type: 'business',
      location: 'Dubai, UAE', role: 'Fine Dining',
      status: 'active', is_verified: true, profile_strength: 95,
      flag_count: 0, avatar_hue: 0.55, plan: 'Premium',
    },
    {
      name: 'The Ritz London', initials: 'TR', email: 'careers@theritz.com',
      password_hash: userHash, phone: '+44 20 1234', user_type: 'business',
      location: 'London, UK', role: 'Luxury Hotel',
      status: 'active', is_verified: true, profile_strength: 98,
      flag_count: 0, avatar_hue: 0.68, plan: 'Enterprise',
    },
    {
      name: 'Dishoom Soho', initials: 'DS', email: 'jobs@dishoom.com',
      password_hash: userHash, phone: '+44 20 5678', user_type: 'business',
      location: 'London, UK', role: 'Restaurant',
      status: 'active', is_verified: false, profile_strength: 72,
      flag_count: 0, avatar_hue: 0.48, plan: 'Starter',
    },
    {
      name: 'Sky Lounge', initials: 'SL', email: 'info@skylounge.com',
      password_hash: userHash, phone: '+971 4 5678', user_type: 'business',
      location: 'Dubai, UAE', role: 'Rooftop Bar',
      status: 'banned', is_verified: false, profile_strength: 40,
      flag_count: 5, avatar_hue: 0.42, plan: 'Cancelled',
    },
    {
      name: 'Fabric London', initials: 'FB', email: 'events@fabriclondon.com',
      password_hash: userHash, phone: '+44 20 9012', user_type: 'business',
      location: 'London, UK', role: 'Club',
      status: 'active', is_verified: false, profile_strength: 55,
      flag_count: 1, avatar_hue: 0.35, plan: 'Expired',
    },
    {
      name: 'Four Seasons', initials: 'FS', email: 'hr@fourseasons.com',
      password_hash: userHash, phone: '+33 1 4952', user_type: 'business',
      location: 'Paris, FR', role: 'Luxury Hotel',
      status: 'active', is_verified: true, profile_strength: 96,
      flag_count: 0, avatar_hue: 0.52, plan: 'Enterprise',
    },
  ]);
};

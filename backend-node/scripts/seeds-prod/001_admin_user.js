const bcrypt = require('bcryptjs');

// Production-safe seed: only creates the admin user if it does not exist.
// Does NOT delete or modify any existing data.
exports.seed = async function (knex) {
  const existing = await knex('users').where({ email: 'mirko@plagit.com' }).first();
  if (existing) {
    console.log('[Seed] Admin user mirko@plagit.com already exists — skipping.');
    return;
  }

  const password = process.env.ADMIN_SEED_PASSWORD || 'admin2026';
  const hash = await bcrypt.hash(password, 10);
  await knex('users').insert({
    name: 'Mirko Picicco',
    initials: 'MP',
    email: 'mirko@plagit.com',
    password_hash: hash,
    phone: '+971 50 999',
    user_type: 'admin',
    admin_role: 'super_admin',
    location: 'Dubai, UAE',
    role: 'Super Admin',
    status: 'active',
    is_verified: true,
    profile_strength: 100,
    avatar_hue: 0.50,
  });

  console.log('[Seed] Admin user created: mirko@plagit.com');
  console.log('[Seed] IMPORTANT: Change the default password after first login.');
};

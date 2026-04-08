exports.seed = async function (knex) {
  await knex('candidates').del();
  const candidateUsers = await knex('users').where('user_type', 'candidate').select('id', 'name', 'initials', 'location', 'role', 'status', 'avatar_hue');

  const extras = {
    'Elena Rossi':   { experience: '15 years', languages: 'Italian, English', verification_status: 'verified' },
    'James Park':    { experience: '8 years',  languages: 'English, Korean',  verification_status: 'pending_review' },
    'Sofia Blanc':   { experience: '6 years',  languages: 'French, English, Spanish', verification_status: 'verified' },
    'Marco Bianchi': { experience: '10 years', languages: 'Italian, English', verification_status: 'new' },
    'Anna Weber':    { experience: '12 years', languages: 'German, English',  verification_status: 'suspended' },
    'Tom Chen':      { experience: '3 years',  languages: 'English, Mandarin', verification_status: 'pending_review' },
    'Priya Sharma':  { experience: '4 years',  languages: 'English, Hindi',   verification_status: 'new' },
    'David Okafor':  { experience: '5 years',  languages: 'English',          verification_status: 'pending_review' },
  };

  const rows = candidateUsers.map((u) => {
    const e = extras[u.name] || { experience: '2 years', languages: 'English', verification_status: 'new' };
    return { user_id: u.id, name: u.name, initials: u.initials, role: u.role, location: u.location, experience: e.experience, languages: e.languages, verification_status: e.verification_status, avatar_hue: u.avatar_hue };
  });
  if (rows.length > 0) await knex('candidates').insert(rows);
};

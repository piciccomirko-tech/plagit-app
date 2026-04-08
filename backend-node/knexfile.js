require('dotenv').config();

module.exports = {
  development: {
    client: 'pg',
    connection: {
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      database: process.env.DB_NAME,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    },
    pool: { min: 2, max: 10 },
    migrations: { directory: './db/migrations' },
    seeds: { directory: './scripts/seeds' },
  },
  production: {
    client: 'pg',
    connection: {
      connectionString: process.env.DATABASE_URL,
      ssl: process.env.DB_SSL === 'false' ? false : { rejectUnauthorized: false },
    },
    pool: { min: 2, max: 20 },
    migrations: { directory: './db/migrations' },
    seeds: { directory: './scripts/seeds-prod' },
  },
};

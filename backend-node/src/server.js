require('dotenv').config();
const app = require('./app');
const db = require('./config/db');

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`[Plagit API] Running on port ${PORT}`);
  console.log(`[Plagit API] Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`[Plagit API] DATABASE_URL: ${process.env.DATABASE_URL ? 'set' : 'NOT SET'}`);

  // Verify DB connection
  db.raw('SELECT 1')
    .then(() => console.log('[Plagit API] Database connected'))
    .catch((err) => console.error('[Plagit API] Database connection failed:', err.message));
});

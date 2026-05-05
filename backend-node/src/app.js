const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const errorHandler = require('./middleware/errorHandler');
const routes = require('./routes');

const app = express();
const isProd = process.env.NODE_ENV === 'production';

// Trust proxy (required for Railway, Render, Heroku behind load balancers)
if (isProd) app.set('trust proxy', 1);

// Security
app.use(helmet());

// CORS
const corsOrigin = process.env.CORS_ORIGIN;
app.use(cors({
  origin: corsOrigin === '*' || !corsOrigin ? true : corsOrigin.split(',').map(s => s.trim()),
  credentials: true,
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));

// Public static serving for the local storage adapter. Only mounted
// when the active driver is the on-disk one — S3 / future drivers
// return absolute URLs and don't need Express to serve files.
const storage = require('./storage');
if (storage.driverName() === 'local') {
  const { baseDir, publicPrefix } = storage.staticConfig();
  app.use(publicPrefix, express.static(baseDir, {
    fallthrough: true,
    maxAge: '1d',
  }));
}

// Logging — concise in production, verbose in dev
app.use(morgan(isProd ? 'combined' : 'dev'));

// Health check (no auth required — always returns 200 so Railway healthcheck passes)
app.get('/health', async (_req, res) => {
  let dbStatus = 'unknown';
  try { await require('./config/db').raw('SELECT 1'); dbStatus = 'connected'; } catch { dbStatus = 'unavailable'; }
  res.json({
    status: 'ok',
    database: dbStatus,
    env: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString(),
  });
});

// API routes — all prefixed with /v1
app.use('/v1', routes);

// 404 catch-all
app.use((_req, res) => res.status(404).json({ error: 'Not found.' }));

// Error handler
app.use(errorHandler);

module.exports = app;

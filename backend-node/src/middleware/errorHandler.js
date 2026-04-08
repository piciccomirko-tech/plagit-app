function errorHandler(err, req, res, _next) {
  const status = err.status || 500;
  const isProd = process.env.NODE_ENV === 'production';

  // Always log server errors
  if (status >= 500) {
    console.error(`[${new Date().toISOString()}] ${err.stack || err.message}`);
  }

  res.status(status).json({
    error: status >= 500 && isProd ? 'Internal server error.' : (err.message || 'Internal server error.'),
  });
}

module.exports = errorHandler;

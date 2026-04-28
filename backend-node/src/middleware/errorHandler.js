function errorHandler(err, req, res, _next) {
  const status = err.status || 500;
  const isProd = process.env.NODE_ENV === 'production';

  // Always log server errors
  if (status >= 500) {
    console.error(`[${new Date().toISOString()}] ${err.stack || err.message}`);
  }

  const body = {
    error: status >= 500 && isProd ? 'Internal server error.' : (err.message || 'Internal server error.'),
  };
  if (err.code) body.code = err.code;

  res.status(status).json(body);
}

module.exports = errorHandler;

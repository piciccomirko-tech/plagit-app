/**
 * Domain error with HTTP status + optional machine-parsable `code`.
 *
 * The `code` is surfaced verbatim in the JSON response body so the
 * Flutter side can branch on it without parsing user-facing strings
 * (e.g. `BOOST_ALREADY_ACTIVE`, `INSUFFICIENT_CREDITS`).
 */
class AppError extends Error {
  constructor(message, status = 500, code = null) {
    super(message);
    this.status = status;
    this.code = code;
    this.name = 'AppError';
  }

  static badRequest(msg = 'Bad request.',     code = null) { return new AppError(msg, 400, code); }
  static unauthorized(msg = 'Unauthorized.',  code = null) { return new AppError(msg, 401, code); }
  static forbidden(msg = 'Forbidden.',        code = null) { return new AppError(msg, 403, code); }
  static notFound(msg = 'Not found.',         code = null) { return new AppError(msg, 404, code); }
  static conflict(msg = 'Conflict.',          code = null) { return new AppError(msg, 409, code); }
  static unavailable(msg = 'Service unavailable.', code = null) { return new AppError(msg, 503, code); }
}

module.exports = AppError;

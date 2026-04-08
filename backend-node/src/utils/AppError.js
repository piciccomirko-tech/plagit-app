class AppError extends Error {
  constructor(message, status = 500) {
    super(message);
    this.status = status;
    this.name = 'AppError';
  }

  static badRequest(msg = 'Bad request.')     { return new AppError(msg, 400); }
  static unauthorized(msg = 'Unauthorized.')  { return new AppError(msg, 401); }
  static forbidden(msg = 'Forbidden.')        { return new AppError(msg, 403); }
  static notFound(msg = 'Not found.')         { return new AppError(msg, 404); }
  static conflict(msg = 'Conflict.')          { return new AppError(msg, 409); }
}

module.exports = AppError;

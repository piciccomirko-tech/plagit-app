/// Represents an API error with categorization for UI display.
class ApiError implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const ApiError(
      {required this.type,
      required this.message,
      this.statusCode,
      this.originalError});

  @override
  String toString() => message;

  /// User-friendly message for UI display.
  /// Prefers the backend's actual error message when available.
  String get displayMessage {
    // If backend sent a real message (not just "HTTP 4xx"), use it
    final hasBackendMessage = !message.startsWith('HTTP ') && message.isNotEmpty;

    return switch (type) {
      ApiErrorType.network =>
        'No internet connection. Please check your network.',
      ApiErrorType.timeout => 'Request timed out. Please try again.',
      ApiErrorType.unauthorized => hasBackendMessage
          ? message
          : 'Your session has expired. Please sign in again.',
      ApiErrorType.forbidden => hasBackendMessage
          ? message
          : "You don't have permission to access this.",
      ApiErrorType.notFound =>
        hasBackendMessage ? message : 'The requested resource was not found.',
      ApiErrorType.validation => message,
      ApiErrorType.server =>
        'Something went wrong on our end. Please try again later.',
      ApiErrorType.unknown =>
        'An unexpected error occurred. Please try again.',
    };
  }

  /// Create from HTTP status code.
  factory ApiError.fromStatusCode(int code, [String? body]) {
    final msg = body ?? 'HTTP $code';
    return switch (code) {
      400 => ApiError(
          type: ApiErrorType.validation, message: msg, statusCode: code),
      401 => ApiError(
          type: ApiErrorType.unauthorized, message: msg, statusCode: code),
      403 => ApiError(
          type: ApiErrorType.forbidden, message: msg, statusCode: code),
      404 => ApiError(
          type: ApiErrorType.notFound, message: msg, statusCode: code),
      >= 500 =>
        ApiError(type: ApiErrorType.server, message: msg, statusCode: code),
      _ => ApiError(
          type: ApiErrorType.unknown, message: msg, statusCode: code),
    };
  }

  factory ApiError.network([dynamic error]) => ApiError(
        type: ApiErrorType.network,
        message: 'Network error',
        originalError: error,
      );

  factory ApiError.timeout() => const ApiError(
        type: ApiErrorType.timeout,
        message: 'Request timed out',
      );
}

enum ApiErrorType {
  network,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

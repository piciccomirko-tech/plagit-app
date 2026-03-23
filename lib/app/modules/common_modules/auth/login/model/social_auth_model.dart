// auth_model.dart
class AuthResponse {
  final String? token;
  final String? error;

  AuthResponse({this.token, this.error});

  factory AuthResponse.success(String token) => AuthResponse(token: token);
  factory AuthResponse.failure(String error) => AuthResponse(error: error);

  bool get isSuccess => token != null;
}

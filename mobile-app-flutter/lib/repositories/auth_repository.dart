import 'package:plagit/core/api_client.dart';
import 'package:plagit/core/token_storage.dart';
import 'package:plagit/models/user.dart';

class AuthRepository {
  final _api = ApiClient();

  Future<User> getCurrentUser() async {
    final role = await TokenStorage.getUserRole();
    final data = await _api.get('/$role/profile');
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> forgotPassword(String email) async {
    await _api.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword({required String token, required String newPassword}) async {
    await _api.post('/auth/reset-password', {
      'token': token,
      'password': newPassword,
    });
  }
}

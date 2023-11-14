import 'package:mh/app/modules/auth/login/model/login_credentials_model.dart';

import '../values/my_constant_value.dart';
import 'storage.dart';

class StorageHelper {
  StorageHelper._();

  static const String _language = "language";
  static const String _theme = "theme";
  static const String _token = "token";
  static const String _userName = "userName";
  static const String _password = "password";

  static String get getLanguage => Storage.getValue<String>(_language) ?? MyConstantValue.defaultAppLanguage;
  static set setLanguage(String lan) => Storage.saveValue(_language, lan);

  static String get getTheme => Storage.getValue<String>(_theme) ?? MyConstantValue.defaultAppTheme;
  static set setTheme(String theme) => Storage.saveValue(_theme, theme);

  static String get getToken => Storage.getValue<String>(_token) ?? "";
  static Future setToken(String token) async => await Storage.saveValue(_token, token);
  static get removeToken async => await Storage.removeValue(_token);
  static get hasToken => getToken.isNotEmpty;

  static Future<void> setLoginCredentials({required LoginCredentialsModel loginCredentials}) async {
    await Storage.saveValue(_userName, loginCredentials.username);
    await Storage.saveValue(_password, loginCredentials.password);
  }

  static LoginCredentialsModel getLoginCredentials() {
    final String username = Storage.getValue<String>(_userName) ?? '';
    final String password = Storage.getValue<String>(_password) ?? '';
    return LoginCredentialsModel(username: username, password: password);
  }
}

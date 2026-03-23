import 'package:flutter/material.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/login_credentials_model.dart';
import 'package:mh/app/modules/common_modules/auth/login/model/social_login_request_model.dart';

import '../values/my_constant_value.dart';
import 'storage.dart';

class StorageHelper {
  StorageHelper._();

  static const String _language = "language";
  static const String _theme = "theme";
  static const String _token = "token";
  static const String _refreshToken = "refreshToken";
  static const String _userName = "userName";
  static const String _password = "password";
  static const String _isFirstTimeOpen = "isFirstTimeOpen";

  //Social Login
  static const String _displayName = "displayName";
  static const String _profilePicture = "profilePicture";
  static const String _email = "email";

  static String get getLanguage => Storage.getValue<String>(_language) ?? "en";
  //MyConstantValue.defaultAppLanguage;
  static set setLanguage(String lan) => Storage.saveValue(_language, lan);

  static String get getTheme =>
      Storage.getValue<String>(_theme) ?? MyConstantValue.defaultAppTheme;
  static set setTheme(String theme) => Storage.saveValue(_theme, theme);

  static String get getToken => Storage.getValue<String>(_token) ?? "";
  static Future setToken(String token) async =>
      await Storage.saveValue(_token, token);
  static Future setRefreshToken(String refreshToken) async =>
      await Storage.saveValue(_refreshToken, refreshToken);
  static String get getRefreshToken => Storage.getValue<String>(_refreshToken) ?? "";
  static get removeToken async => await Storage.removeValue(_token);
  static get hasToken => getToken.isNotEmpty;

  static Future<void> setLoginCredentials(
      {required LoginCredentialsModel loginCredentials}) async {
    await Storage.saveValue(_userName, loginCredentials.username);
    await Storage.saveValue(_password, loginCredentials.password);
  }
  static Future<void> setCurrentLoginEmails(
      {required String email}) async {
    await Storage.saveValue('currentEmail', email);
  }

  static Future<void> setFirstTimeLogin({required String isFirstTime}) async {
    await Storage.saveValue(_isFirstTimeOpen, isFirstTime);
  }

  static Future<String> getFirstTimeLogin() async {
    return Storage.getValue<String>(_isFirstTimeOpen) ?? '';
  }

  static LoginCredentialsModel getLoginCredentials() {
    final String username = Storage.getValue<String>(_userName) ?? '';
    final String password = Storage.getValue<String>(_password) ?? '';
    return LoginCredentialsModel(username: username, password: password);
  }

  static Future<void> setSocialLoginCredentials(
      {required SocialLoginRequestModel socialLogin}) async {
    await Storage.saveValue(_displayName, socialLogin.name);
    await Storage.saveValue(_email, socialLogin.email);
    await Storage.saveValue(_profilePicture, socialLogin.picture);
  }

  static SocialLoginRequestModel getSocialLoginCredentials() {
    final String name = Storage.getValue<String>(_displayName) ?? '';
    final String picture = Storage.getValue<String>(_profilePicture) ?? '';
    final String email = Storage.getValue<String>(_email) ?? '';
    return SocialLoginRequestModel(name: name, picture: picture, email: email);
  }
  //  static const String _theme = "theme";
//theme codes by Rahat
  // Save the theme mode as 'system', 'light', or 'dark'
  static Future<void> setPlagitTheme(String theme) async {
    await Storage.saveValue(_theme, theme);
  }

  static String get getPlagitTheme => Storage.getValue<String>(_theme) ?? "system";

   // Function to get ThemeMode based on saved value
  static ThemeMode get themeMode {
    switch (getPlagitTheme) {
      case "dark":
        return ThemeMode.dark;
      case "light":
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

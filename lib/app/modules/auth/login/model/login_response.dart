import 'dart:convert';

import '../../../../models/api_errors.dart';

class LoginResponse {
  LoginResponse({
    this.status,
    this.statusCode,
    this.message,
    this.token,
    this.refreshToken,
    this.errors,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final String? token;
  final String? refreshToken;
  final List<ApiErrors>? errors;

  factory LoginResponse.fromRawJson(String str) => LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    String? token;
    String? refreshToken;

    // Server returns token as an object: {"accessToken": "...", "refreshToken": "..."}
    if (json["token"] is Map) {
      final tokenMap = json["token"] as Map<String, dynamic>;
      token = tokenMap["accessToken"];
      refreshToken = tokenMap["refreshToken"];
    } else if (json["token"] is String) {
      // Fallback: token as a plain string
      token = json["token"];
    }

    return LoginResponse(
      status: json["status"],
      statusCode: json["statusCode"],
      message: json["message"],
      token: token,
      refreshToken: refreshToken,
      errors: json["errors"] == null ? [] : List<ApiErrors>.from(json["errors"]!.map((x) => ApiErrors.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "token": token,
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x.toJson())),
  };
}

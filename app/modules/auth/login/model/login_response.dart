import 'dart:convert';

import '../../../../models/api_errors.dart';

class LoginResponse {
  LoginResponse({
    this.status,
    this.statusCode,
    this.message,
    this.token,
    this.errors,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final String? token;
  final List<ApiErrors>? errors;

  factory LoginResponse.fromRawJson(String str) => LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    token: json["token"],
    errors: json["errors"] == null ? [] : List<ApiErrors>.from(json["errors"]!.map((x) => ApiErrors.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "token": token,
    "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x.toJson())),
  };
}

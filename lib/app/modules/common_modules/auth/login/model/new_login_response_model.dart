import 'dart:convert';

import '../../../../../models/api_errors.dart';

class NewLoginResponseModel {
  NewLoginResponseModel({
      this.status,
      this.statusCode,
      this.message,
      this.token,
      this.errors,});

  NewLoginResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    token = json['token'] != null ? Token.fromJson(json['token']) : null;
    errors = json["errors"] == null ? [] : List<ApiErrors>.from(json["errors"]!.map((x) => ApiErrors.fromJson(x)));
  }
  String? status;
  num? statusCode;
  String? message;
  Token? token;
  List<ApiErrors>? errors;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (token != null) {
      map['token'] = token?.toJson();
    }
    map['errors']= errors == null ? [] : List<dynamic>.from(errors!.map((x) => x.toJson()));
    return map;
  }
  String toRawJson() => json.encode(toJson());
  factory NewLoginResponseModel.fromRawJson(String str) => NewLoginResponseModel.fromJson(json.decode(str));

}

class Token {
  Token({
      this.accessToken,
      this.refreshToken,});

  Token.fromJson(dynamic json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
  }
  String? accessToken;
  String? refreshToken;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['accessToken'] = accessToken;
    map['refreshToken'] = refreshToken;
    return map;
  }

}
// import 'dart:convert';
//
// import 'package:mh/app/models/api_errors.dart';
//
// class NewLoginResponseModel {
//   NewLoginResponseModel({
//     this.status,
//     this.statusCode,
//     this.message,
//     this.token,
//     this.errors,
//   });
//
//   final String? status;
//   final int? statusCode;
//   final String? message;
//   final String? token;
//   final List<ApiErrors>? errors;
//
//   factory NewLoginResponseModel.fromRawJson(String str) => NewLoginResponseModel.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory NewLoginResponseModel.fromJson(Map<String, dynamic> json) => NewLoginResponseModel(
//     status: json["status"],
//     statusCode: json["statusCode"],
//     message: json["message"],
//     token: json["token"],
//     errors: json["errors"] == null ? [] : List<ApiErrors>.from(json["errors"]!.map((x) => ApiErrors.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "status": status,
//     "statusCode": statusCode,
//     "message": message,
//     "token": token,
//     "errors": errors == null ? [] : List<dynamic>.from(errors!.map((x) => x.toJson())),
//   };
// }

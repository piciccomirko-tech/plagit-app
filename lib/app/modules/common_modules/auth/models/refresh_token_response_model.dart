import '../../../../models/api_errors.dart';

class RefreshTokenResponseModel {
  RefreshTokenResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.token,});

  RefreshTokenResponseModel.fromJson(dynamic json) {
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
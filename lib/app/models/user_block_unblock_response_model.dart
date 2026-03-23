import 'dart:convert';

class UserBlockUnblockResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;

  UserBlockUnblockResponseModel({
    this.status,
    this.statusCode,
    this.message,
  });

  factory UserBlockUnblockResponseModel.fromRawJson(String str) => UserBlockUnblockResponseModel.fromJson(json.decode(str));

  factory UserBlockUnblockResponseModel.fromJson(Map<String, dynamic> json) => UserBlockUnblockResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
  );
}

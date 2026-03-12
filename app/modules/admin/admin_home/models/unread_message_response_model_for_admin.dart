import 'dart:convert';

class UnreadMessageResponseModelForAdmin {
  final String? status;
  final int? statusCode;
  final String? message;
  final int? unreadMsg;

  UnreadMessageResponseModelForAdmin({
    this.status,
    this.statusCode,
    this.message,
    this.unreadMsg,
  });

  factory UnreadMessageResponseModelForAdmin.fromRawJson(String str) => UnreadMessageResponseModelForAdmin.fromJson(json.decode(str));

  factory UnreadMessageResponseModelForAdmin.fromJson(Map<String, dynamic> json) => UnreadMessageResponseModelForAdmin(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        unreadMsg: json["unreadMsg"],
      );
}

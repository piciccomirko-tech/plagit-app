// To parse this JSON data, do
//
//     final notificationUpdateResponseModel = notificationUpdateResponseModelFromJson(jsonString);

import 'dart:convert';

NotificationUpdateResponseModel notificationUpdateResponseModelFromJson(String str) => NotificationUpdateResponseModel.fromJson(json.decode(str));

class NotificationUpdateResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;

  NotificationUpdateResponseModel({
    this.status,
    this.statusCode,
    this.message,
  });

  factory NotificationUpdateResponseModel.fromJson(Map<String, dynamic> json) => NotificationUpdateResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
  );
}

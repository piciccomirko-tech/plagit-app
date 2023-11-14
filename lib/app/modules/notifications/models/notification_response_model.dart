// To parse this JSON data, do
//
//     final notificationResponseModel = notificationResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

NotificationResponseModel notificationResponseModelFromJson(String str) =>
    NotificationResponseModel.fromJson(json.decode(str));

class NotificationResponseModel {
  final String? status;
  final int? statusCode;
  final int? total;
  final int? count;
  final List<BookingDetailsModel>? notifications;

  NotificationResponseModel({
    this.status,
    this.statusCode,
    this.total,
    this.count,
    this.notifications,
  });

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) => NotificationResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        total: json["total"],
        count: json["count"],
        notifications: json["notifications"] == null
            ? []
            : List<BookingDetailsModel>.from(json["notifications"]!.map((x) => BookingDetailsModel.fromJson(x))),
      );
}

class BookingDetailsModel {
  final String? id;
  final String? notificationType;
  final String? text;
  final bool? employee;
  final bool? client;
  final bool? admin;
  final bool? readStatus;
  final bool? isClientHired;
  final bool? active;
  final String? userId;
  final String? clientId;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? hiredStatus;
  final String? hiredByLat;
  final String? hiredByLong;
  final DateTime? createdAt;
  final List<RequestDateModel>? requestDateList;

  BookingDetailsModel(
      {this.id,
      this.notificationType,
      this.text,
      this.employee,
      this.client,
      this.admin,
      this.readStatus,
      this.isClientHired,
      this.active,
      this.userId,
      this.clientId,
      this.restaurantName,
      this.restaurantAddress,
      this.hiredByLat,
      this.hiredByLong,
      this.hiredStatus,
      this.createdAt,
      this.requestDateList});

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) => BookingDetailsModel(
      id: json["_id"],
      notificationType: json["notificationType"],
      text: json["text"],
      employee: json["employee"],
      client: json["client"],
      admin: json["admin"],
      readStatus: json["readStatus"],
      isClientHired: json["isClientHired"],
      active: json["active"],
      userId: json["userId"],
      clientId: json["clientId"],
      restaurantName: json["restaurantName"],
      restaurantAddress: json["restaurantAddress"],
      hiredStatus: json["hiredStatus"],
      hiredByLat: json["hiredByLat"],
      hiredByLong: json["hiredByLong"],
      createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      requestDateList: json["requestDate"] == null
          ? []
          : List<RequestDateModel>.from(json["requestDate"].map((x) => RequestDateModel.fromJson(x))));
}

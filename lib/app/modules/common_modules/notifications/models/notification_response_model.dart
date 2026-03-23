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

  factory NotificationResponseModel.fromJson(Map<String, dynamic> json) =>
      NotificationResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        total: json["total"],
        count: json["count"],
        notifications: json["notifications"] == null
            ? []
            : List<BookingDetailsModel>.from(json["notifications"]!
                .map((x) => BookingDetailsModel.fromJson(x))),
      );
}

class BookingDetailsModel {
  final String? id;
  final String? text;
  final String? appRoute;
  final String? webRoute;
  final bool? readStatus;
  final String? restaurantAddress;
  final String? hiredByLat;
  final bool? uniformMandatory;
  final String? hiredByLong;
  final String? createdBy;
  final DateTime? createdAt;
  final List<RequestDateModel>? requestDateList;

  BookingDetailsModel(
      {this.id,
      this.text,
      this.appRoute,
      this.webRoute,
      this.readStatus,
      this.restaurantAddress,
      this.hiredByLat,
      this.hiredByLong,
      this.uniformMandatory,
      this.createdBy,
      this.createdAt,
      this.requestDateList});

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) =>
      BookingDetailsModel(
          id: json["_id"],
          text: json["text"],
          appRoute: json["appRoute"],
          webRoute: json["webRoute"],
          readStatus: json["readStatus"],
          restaurantAddress: json["restaurantAddress"],
          hiredByLat: json["hiredByLat"],
          hiredByLong: json["hiredByLong"],
          uniformMandatory: json["uniformMandatory"],
          createdBy: json["createdBy"],
          createdAt: json["createdAt"] == null
              ? null
              : DateTime.parse(json["createdAt"]).toLocal(),
          requestDateList: json["requestDate"] == null
              ? []
              : List<RequestDateModel>.from(json["requestDate"]
                  .map((x) => RequestDateModel.fromJson(x))));
}

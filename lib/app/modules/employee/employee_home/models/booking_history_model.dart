// To parse this JSON data, do
//
//     final singleNotificationModelForEmployee = singleNotificationModelForEmployeeFromJson(jsonString);

import 'dart:convert';

import 'package:mh/app/modules/notifications/models/notification_response_model.dart';

BookingHistoryModel singleNotificationModelForEmployeeFromJson(String str) =>
    BookingHistoryModel.fromJson(json.decode(str));

class BookingHistoryModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final List<BookingDetailsModel>? bookingDetailsList;

  BookingHistoryModel({
    this.status,
    this.statusCode,
    this.message,
    this.bookingDetailsList,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) => BookingHistoryModel(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        bookingDetailsList: json["details"] == null
            ? []
            : List<BookingDetailsModel>.from(json["details"].map((x) => BookingDetailsModel.fromJson(x))),
      );
}


import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
class SingleBookingDetailsModel {
  String? status;
  int? statusCode;
  String? message;
  BookingDetailsModel? bookingDetails;

  SingleBookingDetailsModel(
      {this.status, this.statusCode, this.message, this.bookingDetails});

  SingleBookingDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    bookingDetails =
    json['details'] != null ? BookingDetailsModel.fromJson(json['details']) : null;
  }
}

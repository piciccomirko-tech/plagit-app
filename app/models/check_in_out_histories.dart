import 'dart:convert';
import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';
import 'check_in_check_out_details.dart';
import 'employee_details.dart';

class CheckInCheckOutHistory {
  CheckInCheckOutHistory({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.checkInCheckOutHistory,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? total;
  final int? count;
  final List<CheckInCheckOutHistoryElement>? checkInCheckOutHistory;

  factory CheckInCheckOutHistory.fromRawJson(String str) => CheckInCheckOutHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckInCheckOutHistory.fromJson(Map<String, dynamic> json) => CheckInCheckOutHistory(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        total: json["total"],
        count: json["count"],
        checkInCheckOutHistory: json["result"] == null
            ? []
            : List<CheckInCheckOutHistoryElement>.from(
                json["result"]!.map((x) => CheckInCheckOutHistoryElement.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "total": total,
        "count": count,
        if (Get.isRegistered<ClientHomeController>() == true)
          "result":
              checkInCheckOutHistory == null ? [] : List<dynamic>.from(checkInCheckOutHistory!.map((x) => x.toJson()))
        else
          "checkInCheckOutHistory":
              checkInCheckOutHistory == null ? [] : List<dynamic>.from(checkInCheckOutHistory!.map((x) => x.toJson()))
      };
}

class CheckInCheckOutHistoryElement {
  CheckInCheckOutHistoryElement({
    this.id,
    this.bookingId,
    this.status,
    this.refundAmount,
    this.remark,
    this.employeeAmount,
    this.totalAmount,
    this.vat,
    this.vatAmount,
    this.platformFee,
    this.workedHour,
    this.employeeId,
    this.currentHiredEmployeeId,
    this.hiredBy,
    this.employeeDetails,
    this.restaurantDetails,
    this.checkInCheckOutDetails,
    this.fromDate,
    this.toDate,
    this.hiredDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.invoiceNumber,
    this.clientAmount,
    this.v,
  });

  final String? id;
  final String? bookingId;
  final String? employeeId;
  final String? status;
  final double? refundAmount;
  final String? remark;
  final double? employeeAmount;
  final double? clientAmount;
  final double? totalAmount;
  final double? vat;
  final double? vatAmount;
  final double? platformFee;
  final String? workedHour;
  final String? currentHiredEmployeeId;
  final String? hiredBy;
  final EmployeeDetails? employeeDetails;
  final RestaurantDetails? restaurantDetails;
  final CheckInCheckOutDetails? checkInCheckOutDetails;
  final DateTime? fromDate;
  final DateTime? toDate;
  final DateTime? hiredDate;
  final String? createdBy;
  final DateTime? createdAt;
  final String? invoiceNumber;
  final DateTime? updatedAt;
  final int? v;

  factory CheckInCheckOutHistoryElement.fromRawJson(String str) =>
      CheckInCheckOutHistoryElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckInCheckOutHistoryElement.fromJson(Map<String, dynamic> json) => CheckInCheckOutHistoryElement(
        id: json["_id"],
    bookingId: json["bookingId"],
        status: json["status"],
    remark: json["remark"],
    refundAmount: json["refundAmount"] == null ? 0.0 :double.parse(json["refundAmount"].toString()),
        invoiceNumber: json["invoiceNumber"],
        totalAmount: json["totalAmount"] == null ? 0.0 : double.parse(json["totalAmount"].toString()),
        employeeAmount: json["employeeAmount"] == null ? 0.0 : double.parse(json["employeeAmount"].toString()),
        clientAmount: json["clientAmount"] == null ? 0.0 : double.parse(json["clientAmount"].toString()),
        platformFee: json["platformFee"] == null ? 0.0 : double.parse(json["platformFee"].toString()),
        vatAmount: json["vatAmount"] == null ? 0.0 : double.parse(json["vatAmount"].toString()),
        vat: json["vat"] == null ? 0.0 : double.parse(json["vat"].toString()),
        workedHour: json["workedHour"],
        employeeId: json["employeeId"],
        currentHiredEmployeeId: json["currentHiredEmployeeId"],
        hiredBy: json["hiredBy"],
        employeeDetails: json["employeeDetails"] == null ? null : EmployeeDetails.fromJson(json["employeeDetails"]),
        restaurantDetails:
            json["restaurantDetails"] == null ? null : RestaurantDetails.fromJson(json["restaurantDetails"]),
        checkInCheckOutDetails: json["checkInCheckOutDetails"] == null
            ? null
            : CheckInCheckOutDetails.fromJson(json["checkInCheckOutDetails"]),
        fromDate: json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
        toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
        hiredDate: json["hiredDate"] == null ? null : DateTime.parse(json["hiredDate"]),
        createdBy: json["createdBy"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "bookingId": bookingId,
        "status": status,
        "refundAmount": refundAmount,
        "remark": remark,
        "invoiceNumber": invoiceNumber,
        "totalAmount": totalAmount,
        "employeeAmount": employeeAmount,
        "clientAmount": clientAmount,
        "vatAmount": vatAmount,
        "vat": vat,
        "platformFee": platformFee,
        "workedHour": workedHour,
        "employeeId": employeeId,
        "currentHiredEmployeeId": currentHiredEmployeeId,
        "hiredBy": hiredBy,
        "employeeDetails": employeeDetails?.toJson(),
        "restaurantDetails": restaurantDetails?.toJson(),
        "checkInCheckOutDetails": checkInCheckOutDetails?.toJson(),
        "fromDate": fromDate?.toIso8601String(),
        "toDate": toDate?.toIso8601String(),
        "hiredDate": hiredDate?.toIso8601String(),
        "createdBy": createdBy,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

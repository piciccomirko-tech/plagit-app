import 'dart:convert';
import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
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
        checkInCheckOutHistory: Get.isRegistered<EmployeeHomeController>() == true
            ? json["checkInCheckOutHistory"] == null
                ? []
                : List<CheckInCheckOutHistoryElement>.from(
                    json["checkInCheckOutHistory"]!.map((x) => CheckInCheckOutHistoryElement.fromJson(x)))
            : json["result"] == null
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
    this.v,
  });

  final String? id;
  final String? employeeId;
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
  final DateTime? updatedAt;
  final int? v;

  factory CheckInCheckOutHistoryElement.fromRawJson(String str) =>
      CheckInCheckOutHistoryElement.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckInCheckOutHistoryElement.fromJson(Map<String, dynamic> json) => CheckInCheckOutHistoryElement(
        id: json["_id"],
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

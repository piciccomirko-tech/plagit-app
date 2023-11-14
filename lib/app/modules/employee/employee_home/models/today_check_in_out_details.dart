import 'dart:convert';

import '../../../../models/check_in_check_out_details.dart';
import '../../../../models/employee_details.dart';

class TodayCheckInOutDetails {
  TodayCheckInOutDetails({
    this.status,
    this.statusCode,
    this.message,
    this.details,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final Details? details;

  factory TodayCheckInOutDetails.fromRawJson(String str) => TodayCheckInOutDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TodayCheckInOutDetails.fromJson(Map<String, dynamic> json) => TodayCheckInOutDetails(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    details: (json["details"] == null || json["details"]["_id"] == null) ? null : Details.fromJson(json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "details": details?.toJson(),
  };
}

class Details {
  Details({
    this.id,
    this.employeeId,
    this.hiredBy,
    this.employeeDetails,
    this.restaurantDetails,
    this.checkInCheckOutDetails,
    this.fromDate,
    this.toDate,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? id;
  final String? employeeId;
  final String? hiredBy;
  final EmployeeDetails? employeeDetails;
  final RestaurantDetails? restaurantDetails;
  final CheckInCheckOutDetails? checkInCheckOutDetails;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Details.fromRawJson(String str) => Details.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    id: json["_id"],
    employeeId: json["employeeId"],
    hiredBy: json["hiredBy"],
    employeeDetails: json["employeeDetails"] == null ? null : EmployeeDetails.fromJson(json["employeeDetails"]),
    restaurantDetails: json["restaurantDetails"] == null ? null : RestaurantDetails.fromJson(json["restaurantDetails"]),
    checkInCheckOutDetails: json["checkInCheckOutDetails"] == null ? null : CheckInCheckOutDetails.fromJson(json["checkInCheckOutDetails"]),
    fromDate: json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]),
    toDate: json["toDate"] == null ? null : DateTime.parse(json["toDate"]),
    createdBy: json["createdBy"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "employeeId": employeeId,
    "hiredBy": hiredBy,
    "employeeDetails": employeeDetails?.toJson(),
    "restaurantDetails": restaurantDetails?.toJson(),
    "checkInCheckOutDetails": checkInCheckOutDetails?.toJson(),
    "fromDate": fromDate?.toIso8601String(),
    "toDate": toDate?.toIso8601String(),
    "createdBy": createdBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class RestaurantDetails {
  RestaurantDetails({
    this.hiredBy,
    this.restaurantName,
    this.restaurantAddress,
    this.lat,
    this.long,
    this.id,
  });

  final String? hiredBy;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? lat;
  final String? long;
  final String? id;

  factory RestaurantDetails.fromRawJson(String str) => RestaurantDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) => RestaurantDetails(
    hiredBy: json["hiredBy"],
    restaurantName: json["restaurantName"],
    restaurantAddress: json["restaurantAddress"],
    lat: json["lat"],
    long: json["long"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "hiredBy": hiredBy,
    "restaurantName": restaurantName,
    "restaurantAddress": restaurantAddress,
    "lat": lat,
    "long": long,
    "_id": id,
  };
}

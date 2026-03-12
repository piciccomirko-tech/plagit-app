import 'dart:convert';
import 'package:mh/app/models/employees_by_id.dart';

class EmployeeFullDetails {
  final String? status;
  final int? statusCode;
  final String? message;
  final Employee? details;

  EmployeeFullDetails({
    this.status,
    this.statusCode,
    this.message,
    this.details,
  });

  factory EmployeeFullDetails.fromRawJson(String str) => EmployeeFullDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory EmployeeFullDetails.fromJson(Map<String, dynamic> json) => EmployeeFullDetails(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    details: json["details"] == null ? null : Employee.fromJson(json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "details": details?.toJson(),
  };
}


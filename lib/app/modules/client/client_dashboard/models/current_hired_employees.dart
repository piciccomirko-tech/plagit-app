import 'dart:convert';

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

import '../../../../models/employee_details.dart';

class HiredEmployeesByDate {
  HiredEmployeesByDate({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.next,
    this.hiredHistories,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? total;
  final int? count;
  final int? next;
  final List<HiredHistory>? hiredHistories;

  factory HiredEmployeesByDate.fromRawJson(String str) => HiredEmployeesByDate.fromJson(json.decode(str));

  factory HiredEmployeesByDate.fromJson(Map<String, dynamic> json) => HiredEmployeesByDate(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        total: json["total"],
        count: json["count"],
        next: json["next"],
        hiredHistories: json["hiredHistories"] == null
            ? []
            : List<HiredHistory>.from(json["hiredHistories"]!.map((x) => HiredHistory.fromJson(x))),
      );
}

class HiredHistory {
  HiredHistory(
      {this.id,
      this.employeeId,
      this.employeeDetails,
      this.feeAmount,
      this.active,
      this.hiredBy,
      this.hiredDate,
      this.v,
      this.requestDateList});

  final String? id;
  final String? employeeId;
  final EmployeeDetails? employeeDetails;
  final int? feeAmount;
  final bool? active;
  final String? hiredBy;
  final DateTime? hiredDate;
  final int? v;
  final List<RequestDateModel>? requestDateList;

  factory HiredHistory.fromRawJson(String str) => HiredHistory.fromJson(json.decode(str));

  factory HiredHistory.fromJson(Map<String, dynamic> json) => HiredHistory(
      id: json["_id"],
      employeeId: json["employeeId"],
      employeeDetails: json["employeeDetails"] == null ? null : EmployeeDetails.fromJson(json["employeeDetails"]),
      feeAmount: json["feeAmount"],
      active: json["active"],
      hiredBy: json["hiredBy"],
      hiredDate: json["hiredDate"] == null ? null : DateTime.parse(json["hiredDate"]),
      v: json["__v"],
      requestDateList: json["bookedDate"] == null
          ? []
          : List<RequestDateModel>.from(json["bookedDate"].map((x) => RequestDateModel.fromJson(x))));
}

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class EmployeeHiredHistoryModel {
  String? status;
  int? statusCode;
  String? message;
  List<HiredHistoryModel>? hiredHistory;

  EmployeeHiredHistoryModel({this.status, this.statusCode, this.message, this.hiredHistory});

  EmployeeHiredHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['bookedHistory'] != null) {
      hiredHistory = <HiredHistoryModel>[];
      json['bookedHistory'].forEach((v) {
        hiredHistory!.add(HiredHistoryModel.fromJson(v));
      });
    }
  }
}

class HiredHistoryModel {
  String? id;
  String? hiredBy;
  List<RequestDateModel>? bookedDate;
  RestaurantDetails? restaurantDetails;

  HiredHistoryModel({this.id, this.hiredBy, this.bookedDate, this.restaurantDetails});

  HiredHistoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hiredBy = json['hiredBy'];
    if (json['bookedDate'] != null) {
      bookedDate = <RequestDateModel>[];
      json['bookedDate'].forEach((v) {
        bookedDate!.add(RequestDateModel.fromJson(v));
      });
    }
    restaurantDetails =
        json['restaurantDetails'] != null ? RestaurantDetails.fromJson(json['restaurantDetails']) : null;
  }
}

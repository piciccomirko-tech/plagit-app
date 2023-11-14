import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class TodayWorkScheduleModel {
  String? status;
  int? statusCode;
  String? message;
  TodayWorkScheduleDetailsModel? todayWorkScheduleDetailsModel;

  TodayWorkScheduleModel(
      {this.status, this.statusCode, this.message, this.todayWorkScheduleDetailsModel});

  TodayWorkScheduleModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    todayWorkScheduleDetailsModel =
    json['result'] != null ? TodayWorkScheduleDetailsModel.fromJson(json['result']) : null;
  }

}

class TodayWorkScheduleDetailsModel {
  RestaurantDetails? restaurantDetails;
  String? startTime;
  String? endTime;

  TodayWorkScheduleDetailsModel({this.restaurantDetails, this.startTime, this.endTime});

  TodayWorkScheduleDetailsModel.fromJson(Map<String, dynamic> json) {
    restaurantDetails = json['restaurantDetails'] != null
        ? RestaurantDetails.fromJson(json['restaurantDetails'])
        : null;
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

}

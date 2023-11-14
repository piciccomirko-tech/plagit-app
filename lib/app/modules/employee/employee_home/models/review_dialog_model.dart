import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class ReviewDialogModel {
  String? status;
  int? statusCode;
  List<ReviewDialogDetailsModel>? reviewDialogDetailsModel;

  ReviewDialogModel({this.status, this.statusCode, this.reviewDialogDetailsModel});

  ReviewDialogModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    if (json['details'] != null) {
      reviewDialogDetailsModel = <ReviewDialogDetailsModel>[];
      json['details'].forEach((v) {
        reviewDialogDetailsModel!.add(ReviewDialogDetailsModel.fromJson(v));
      });
    }
  }
}

class ReviewDialogDetailsModel {
  String? id;
  EmployeeDetails? employeeDetails;
  RestaurantDetails? restaurantDetails;

  ReviewDialogDetailsModel({this.id, this.employeeDetails, this.restaurantDetails});

  ReviewDialogDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    employeeDetails = json['employeeDetails'] != null ? EmployeeDetails.fromJson(json['employeeDetails']) : null;
    restaurantDetails =
        json['restaurantDetails'] != null ? RestaurantDetails.fromJson(json['restaurantDetails']) : null;
  }
}

class EmployeeDetails {
  String? employeeId;
  String? name;
  String? profilePicture;

  EmployeeDetails({this.employeeId, this.name, this.profilePicture});

  EmployeeDetails.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    name = json['name'];
    profilePicture = json['profilePicture'];
  }
}

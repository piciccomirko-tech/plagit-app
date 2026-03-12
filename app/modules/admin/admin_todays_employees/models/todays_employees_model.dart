import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class TodaysEmployeesModel {
  String? status;
  int? statusCode;
  List<TodaysEmployeesDataModel>? data;

  TodaysEmployeesModel({this.status, this.statusCode, this.data});

  TodaysEmployeesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <TodaysEmployeesDataModel>[];
      json['data'].forEach((v) {
        data!.add(TodaysEmployeesDataModel.fromJson(v));
      });
    }
  }
}

class TodaysEmployeesDataModel {
  TodaysEmployeesDetailsModel? employeeDetails;
  RestaurantDetails? restaurantDetails;
  List<RequestDateModel>? bookedDate;

  TodaysEmployeesDataModel({this.employeeDetails, this.restaurantDetails, this.bookedDate});

  TodaysEmployeesDataModel.fromJson(Map<String, dynamic> json) {
    employeeDetails =
        json['employeeDetails'] != null ? TodaysEmployeesDetailsModel.fromJson(json['employeeDetails']) : null;
    restaurantDetails =
        json['restaurantDetails'] != null ? RestaurantDetails.fromJson(json['restaurantDetails']) : null;
    if (json['bookedDate'] != null) {
      bookedDate = <RequestDateModel>[];
      json['bookedDate'].forEach((v) {
        bookedDate!.add(RequestDateModel.fromJson(v));
      });
    }
  }
}

class TodaysEmployeesDetailsModel {
  String? sId;
  String? name;
  String? positionId;
  String? positionName;
  String? presentAddress;
  String? permanentAddress;
  String? employeeExperience;
  double? rating;
  String? totalWorkingHour;
  double? hourlyRate;
  String? profilePicture;
  double? contractorHourlyRate;
  String? countryName;
  String? nationality;

  TodaysEmployeesDetailsModel(
      {this.sId,
      this.name,
      this.positionId,
      this.positionName,
      this.presentAddress,
      this.permanentAddress,
      this.employeeExperience,
      this.rating,
      this.totalWorkingHour,
      this.hourlyRate,
      this.profilePicture,
      this.contractorHourlyRate,
      this.countryName,
      this.nationality});

  TodaysEmployeesDetailsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    presentAddress = json['presentAddress'];
    permanentAddress = json['permanentAddress'];
    employeeExperience = json['employeeExperience'];
    rating = json['rating'] == null ? 0.0 : double.parse(json['rating'].toString());
    totalWorkingHour = json['totalWorkingHour'];
    hourlyRate = json['hourlyRate'] == null ? 0.0 : double.parse(json['hourlyRate'].toString());
    profilePicture = json['profilePicture'];
    contractorHourlyRate = json['contractorHourlyRate'] == null ? 0.0 : double.parse(json['contractorHourlyRate'].toString());
    countryName = json['countryName'];
    nationality = json['nationality'];
  }
}

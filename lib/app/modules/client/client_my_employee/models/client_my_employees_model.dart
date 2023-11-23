import 'package:mh/app/models/employee_details.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class ClientMyEmployeesModel {
  String? status;
  int? statusCode;
  ClientMyEmployeeDetailsModel? details;

  ClientMyEmployeesModel({this.status, this.statusCode, this.details});

  ClientMyEmployeesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    details =
    json['details'] != null ? ClientMyEmployeeDetailsModel.fromJson(json['details']) : null;
  }

}

class ClientMyEmployeeDetailsModel {
  List<ClientMyEmployeeResult>? result;

  ClientMyEmployeeDetailsModel({this.result});

  ClientMyEmployeeDetailsModel.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <ClientMyEmployeeResult>[];
      json['result'].forEach((v) {
        result!.add(ClientMyEmployeeResult.fromJson(v));
      });
    }
  }

}

class ClientMyEmployeeResult {
  String? id;
  RestaurantDetails? restaurantDetails;
  List<EmployeeModel>? employee;

  ClientMyEmployeeResult({this.id, this.restaurantDetails, this.employee});

  ClientMyEmployeeResult.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restaurantDetails = json['restaurantDetails'] != null
        ? RestaurantDetails.fromJson(json['restaurantDetails'])
        : null;
    if (json['employee'] != null) {
      employee = <EmployeeModel>[];
      json['employee'].forEach((v) {
        employee!.add(EmployeeModel.fromJson(v));
      });
    }
  }
}

class EmployeeModel {
  String? employeeId;
  EmployeeDetails? employeeDetails;
  List<RequestDateModel>? bookedDate;

  EmployeeModel({this.employeeId, this.employeeDetails, this.bookedDate});

  EmployeeModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    employeeDetails = json['employeeDetails'] != null
        ? EmployeeDetails.fromJson(json['employeeDetails'])
        : null;
    if (json['bookedDate'] != null) {
      bookedDate = <RequestDateModel>[];
      json['bookedDate'].forEach((v) {
        bookedDate!.add(RequestDateModel.fromJson(v));
      });
    }
  }

}


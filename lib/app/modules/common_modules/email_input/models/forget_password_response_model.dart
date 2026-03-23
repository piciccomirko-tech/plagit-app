import '../../../employee/employee_home/models/common_response_model.dart';

class ForgetPasswordResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? user;
    List<Errors>? errors;

  ForgetPasswordResponseModel(
      {this.status, this.statusCode, this.message, this.user, this.errors});

  ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    user = json['user'];   if (json['errors'] != null) {
      errors = [];
      json['errors'].forEach((v) {
        errors?.add(Errors.fromJson(v));
      });
    }
  }
}

class EmployeeRegistrationResponseModel {
  String? status;
  int? statusCode;
  String? message;

  EmployeeRegistrationResponseModel(
      {this.status, this.statusCode, this.message});

  EmployeeRegistrationResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

}


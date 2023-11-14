class ForgetPasswordResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? user;

  ForgetPasswordResponseModel(
      {this.status, this.statusCode, this.message, this.user});

  ForgetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    user = json['user'];
  }
}

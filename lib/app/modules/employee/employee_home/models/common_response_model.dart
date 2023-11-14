class CommonResponseModel {
  String? status;
  int? statusCode;
  String? message;
  CommonResponseModel({this.status, this.statusCode, this.message});
  CommonResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
  }
}

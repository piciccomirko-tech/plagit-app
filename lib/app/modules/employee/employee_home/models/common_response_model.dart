class CommonResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? result;
  CommonResponseModel({this.status, this.statusCode, this.message, this.result});
  CommonResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'].toString();
  }
}

class LogoutResponseModel {
  LogoutResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.msg,});

  LogoutResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    msg = json['msg'];
  }
  String? status;
  num? statusCode;
  String? message;
  String? msg;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    map['msg'] = msg;
    return map;
  }

}
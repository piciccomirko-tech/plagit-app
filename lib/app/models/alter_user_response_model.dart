class AlterUserResponseModel {
  AlterUserResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.token,});

  AlterUserResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    token = json['token'];
  }
  String? status;
  num? statusCode;
  String? message;
  String? token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    map['token'] = token;
    return map;
  }

}
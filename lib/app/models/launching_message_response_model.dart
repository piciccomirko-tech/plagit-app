class LaunchingMessageResponseModel {
  LaunchingMessageResponseModel({
      this.status, 
      this.statusCode, 
      this.message,});

  LaunchingMessageResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
  }
  String? status;
  int? statusCode;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    return map;
  }

}
class SocialPostViewIncreaseResponseModel {
  SocialPostViewIncreaseResponseModel({
      this.status, 
      this.statusCode, 
      this.message,});

  SocialPostViewIncreaseResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
  }
  String? status;
  num? statusCode;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    return map;
  }

}
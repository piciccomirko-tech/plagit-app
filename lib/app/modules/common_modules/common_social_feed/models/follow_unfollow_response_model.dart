class FollowUnfollowResponseModel {
  FollowUnfollowResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.result,});

  FollowUnfollowResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'];
  }
  String? status;
  num? statusCode;
  String? message;
  String? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    map['result'] = result;
    return map;
  }

}
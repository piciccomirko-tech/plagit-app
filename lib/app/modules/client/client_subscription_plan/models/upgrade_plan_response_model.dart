class UpgradePlanResponseModel {
  UpgradePlanResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.details,});

  UpgradePlanResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    details = json['details'];
  }
  String? status;
  num? statusCode;
  String? message;
  String? details;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    map['details'] = details;
    return map;
  }

}
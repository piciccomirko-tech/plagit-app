class CommonResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? result;
  List<Errors>? errors;
  dynamic details; // To accommodate both String and Details

  CommonResponseModel({this.status, this.statusCode, this.message, this.result, this.details, this.errors});

  CommonResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'].toString();

    if (json['details'] != null) {
      if (json['details'] is String) {
        details = json['details'];  // Assign directly if it's a String
      } else if (json['details'] is Map<String, dynamic>) {
        details = Details.fromJson(json['details']);  // Parse as Details if it's a Map
      }
    }
    if (json['errors'] != null) {
      errors = [];
      json['errors'].forEach((v) {
        errors?.add(Errors.fromJson(v));
      });
    }
  }
}

class Details {
  String? id;
  String? skipDate;

  Details({this.id, this.skipDate});

  Details.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    skipDate = json['skipDate'];
  }
}

class Errors {
  Errors({
    this.value,
    this.msg,
    this.param,
    this.location,});

  Errors.fromJson(dynamic json) {
    value = json['value'];
    msg = json['msg'];
    param = json['param'];
    location = json['location'];
  }
  String? value;
  String? msg;
  String? param;
  String? location;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['value'] = value;
    map['msg'] = msg;
    map['param'] = param;
    map['location'] = location;
    return map;
  }

}
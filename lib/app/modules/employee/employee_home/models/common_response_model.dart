class CommonResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? result;
  Details? details;
  CommonResponseModel({this.status, this.statusCode, this.message, this.result});
  CommonResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'].toString();
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
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

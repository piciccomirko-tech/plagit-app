class StripeResponseModel {
  String? status;
  int? statusCode;
  String? message;
  StripeResponseDetailsModel? details;

  StripeResponseModel(
      {this.status, this.statusCode, this.message, this.details});

  StripeResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    details =
    json['details'] != null ? StripeResponseDetailsModel.fromJson(json['details']) : null;
  }
}

class StripeResponseDetailsModel {
  String? id;
  String? url;
  String? cancelUrl;
  String? successUrl;


  StripeResponseDetailsModel({this.id, this.url});

  StripeResponseDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    cancelUrl = json['cancel_url'];
    successUrl = json['success_url'];
  }
}

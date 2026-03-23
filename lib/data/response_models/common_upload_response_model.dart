class CommonUploadResponseModel {
  String? status;
  int? statusCode;
  String? message;
  String? fileUrl;

  CommonUploadResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.fileUrl,
  });

  CommonUploadResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    fileUrl = json['data']?['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (fileUrl != null) {
      data['data'] = {'file': fileUrl};
    }
    return data;
  }
}

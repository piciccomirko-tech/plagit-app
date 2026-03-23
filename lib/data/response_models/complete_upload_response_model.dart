class CompleteUploadResponseModel {
  CompleteUploadResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.fileUrl,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final String? fileUrl;

  factory CompleteUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return CompleteUploadResponseModel(
      status: json["status"],
      statusCode: json["statusCode"],
      message: json["message"],
      fileUrl: json["fileUrl"],
    );
  }
}

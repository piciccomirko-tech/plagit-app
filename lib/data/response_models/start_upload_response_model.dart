class StartUploadResponseModel {
  StartUploadResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.result,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final Result? result;

  factory StartUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return StartUploadResponseModel(
      status: json["status"],
      statusCode: json["statusCode"],
      message: json["message"],
      result: json["result"] == null ? null : Result.fromJson(json["result"]),
    );
  }
}

class Result {
  Result({
    required this.uploadId,
    required this.fileName,
    required this.type,
  });

  final String? uploadId;
  final String? fileName;
  final String? type;

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      uploadId: json["uploadId"],
      fileName: json["fileName"],
      type: json["type"],
    );
  }
}

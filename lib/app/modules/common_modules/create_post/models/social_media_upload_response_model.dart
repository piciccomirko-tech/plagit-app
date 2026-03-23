import 'dart:convert';

class SocialMediaUploadResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final Data? data;

  SocialMediaUploadResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.data,
  });

  factory SocialMediaUploadResponseModel.fromRawJson(String str) => SocialMediaUploadResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SocialMediaUploadResponseModel.fromJson(Map<String, dynamic> json) => SocialMediaUploadResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final String? file;

  Data({
    this.file,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    file: json["file"],
  );

  Map<String, dynamic> toJson() => {
    "file": file,
  };
}

import 'dart:convert';

class SessionIdResponseModel {
  final String? status;
  final int? statusCode;
  final Details? details;

  SessionIdResponseModel({
    this.status,
    this.statusCode,
    this.details,
  });

  factory SessionIdResponseModel.fromRawJson(String str) => SessionIdResponseModel.fromJson(json.decode(str));

  factory SessionIdResponseModel.fromJson(Map<String, dynamic> json) => SessionIdResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
  );

}

class Details {
  final String? id;
  final String? updateStatus;
  final String? version;

  Details({
    this.id,
    this.updateStatus,
    this.version,
  });

  factory Details.fromRawJson(String str) => Details.fromJson(json.decode(str));


  factory Details.fromJson(Map<String, dynamic> json) => Details(
    id: json["id"],
    updateStatus: json["updateStatus"],
    version: json["version"],
  );
}

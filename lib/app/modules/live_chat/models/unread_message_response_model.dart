import 'dart:convert';

class UnreadMessageResponseModel {
  final String? status;
  final int? statusCode;
  final Details? details;

  UnreadMessageResponseModel({
    this.status,
    this.statusCode,
    this.details,
  });

  factory UnreadMessageResponseModel.fromRawJson(String str) => UnreadMessageResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UnreadMessageResponseModel.fromJson(Map<String, dynamic> json) => UnreadMessageResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    details: json["details"] == null ? null : Details.fromJson(json["details"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "details": details?.toJson(),
  };
}

class Details {
  final int? count;

  Details({
    this.count,
  });

  factory Details.fromRawJson(String str) => Details.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Details.fromJson(Map<String, dynamic> json) => Details(
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "count": count,
  };
}

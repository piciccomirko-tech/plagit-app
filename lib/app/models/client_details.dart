import 'dart:convert';

import 'client.dart';

class ClientDetails {
  ClientDetails({
    this.status,
    this.statusCode,
    this.message,
    this.details,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final Client? details;

  factory ClientDetails.fromRawJson(String str) =>
      ClientDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ClientDetails.fromJson(Map<String, dynamic> json) => ClientDetails(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        details:
            json["details"] == null ? null : Client.fromJson(json["details"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "details": details?.toJson(),
      };
}

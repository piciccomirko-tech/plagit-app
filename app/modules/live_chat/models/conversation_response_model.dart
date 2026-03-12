import 'dart:convert';

class ConversationResponseModel {
  final String? status;
  final int? statusCode;
  final ConversationDetailsModel? details;

  ConversationResponseModel({
    this.status,
    this.statusCode,
    this.details,
  });

  factory ConversationResponseModel.fromRawJson(String str) => ConversationResponseModel.fromJson(json.decode(str));

  factory ConversationResponseModel.fromJson(Map<String, dynamic> json) => ConversationResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        details: json["details"] == null ? null : ConversationDetailsModel.fromJson(json["details"]),
      );
}

class ConversationDetailsModel {
  final String? id;
  final bool? active;
  final bool? isAdmin;
  final String? country;

  ConversationDetailsModel({
    this.id,
    this.active,
    this.isAdmin,
    this.country,
  });

  factory ConversationDetailsModel.fromRawJson(String str) => ConversationDetailsModel.fromJson(json.decode(str));

  factory ConversationDetailsModel.fromJson(Map<String, dynamic> json) => ConversationDetailsModel(
        id: json["_id"],
        active: json["active"],
        isAdmin: json["isAdmin"],
        country: json["country"],
      );
}

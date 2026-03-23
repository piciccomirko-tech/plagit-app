import 'dart:convert';
import 'package:mh/app/models/social_feed_response_model.dart';

class SocialFeedInfoResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final SocialPostModel? socialFeed;

  SocialFeedInfoResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.socialFeed,
  });

  factory SocialFeedInfoResponseModel.fromRawJson(String str) => SocialFeedInfoResponseModel.fromJson(json.decode(str));

  factory SocialFeedInfoResponseModel.fromJson(Map<String, dynamic> json) => SocialFeedInfoResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    socialFeed: json["socialFeed"] == null ? null : SocialPostModel.fromJson(json["socialFeed"]),
  );

}

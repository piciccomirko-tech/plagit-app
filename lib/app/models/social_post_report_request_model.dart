import 'dart:convert';

class SocialPostReportRequestModel {
  final String postId;
  final String reason;

  SocialPostReportRequestModel({
    required this.postId,
    required this.reason,
  });

  factory SocialPostReportRequestModel.fromRawJson(String str) => SocialPostReportRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SocialPostReportRequestModel.fromJson(Map<String, dynamic> json) => SocialPostReportRequestModel(
    postId: json["postId"],
    reason: json["reason"],
  );

  Map<String, dynamic> toJson() => {
    "postId": postId,
    "reason": reason,
  };
}

import 'dart:convert';

class SocialCommentRequestModel {
  final String text;
  final String postId;
  final String parentId;

  SocialCommentRequestModel({
    required this.text,
    required this.postId,
    required this.parentId,
  });

  factory SocialCommentRequestModel.fromRawJson(String str) =>
      SocialCommentRequestModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SocialCommentRequestModel.fromJson(Map<String, dynamic> json) =>
      SocialCommentRequestModel(
        text: json["text"],
        postId: json["postId"],
        parentId: json["parentId"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "postId": postId,
        if (parentId.isNotEmpty) "parentId": parentId,
      };
}

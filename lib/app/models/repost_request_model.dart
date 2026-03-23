import 'dart:convert';

class RepostRequestModel {
  final String content;
  final String postId;

  RepostRequestModel({
    required this.content,
    required this.postId,
  });


  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "content": content,
    "postId": postId,
  };
}

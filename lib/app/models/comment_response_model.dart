import 'dart:convert';

class CommentResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final CommentResponse? comment;

  CommentResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.comment,
  });

  factory CommentResponseModel.fromRawJson(String str) => CommentResponseModel.fromJson(json.decode(str));

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) => CommentResponseModel(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    comment: json["comment"] == null ? null : CommentResponse.fromJson(json["comment"]),
  );
}

class CommentResponse {
  final String? text;
  final String? user;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CommentResponse({
    this.text,
    this.user,
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory CommentResponse.fromRawJson(String str) => CommentResponse.fromJson(json.decode(str));

  factory CommentResponse.fromJson(Map<String, dynamic> json) => CommentResponse(
    text: json["text"],
    user: json["user"],
    id: json["_id"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

}

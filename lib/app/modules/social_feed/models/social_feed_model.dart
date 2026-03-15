import 'dart:convert';

class SocialFeedResponse {
  SocialFeedResponse({
    this.status,
    this.statusCode,
    this.message,
    this.posts,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final List<SocialPost>? posts;

  factory SocialFeedResponse.fromRawJson(String str) =>
      SocialFeedResponse.fromJson(json.decode(str));

  factory SocialFeedResponse.fromJson(Map<String, dynamic> json) {
    // Handle both array response and object response
    if (json["posts"] != null) {
      return SocialFeedResponse(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        posts: List<SocialPost>.from(
            json["posts"]!.map((x) => SocialPost.fromJson(x))),
      );
    } else if (json["data"] != null && json["data"] is List) {
      return SocialFeedResponse(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        posts: List<SocialPost>.from(
            json["data"]!.map((x) => SocialPost.fromJson(x))),
      );
    }
    return SocialFeedResponse(
      status: json["status"],
      statusCode: json["statusCode"],
      message: json["message"],
      posts: [],
    );
  }
}

class SocialPost {
  SocialPost({
    this.id,
    this.content,
    this.media,
    this.views,
    this.active,
    this.user,
    this.likes,
    this.comments,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String? content;
  final List<String>? media;
  final int? views;
  final bool? active;
  final SocialUser? user;
  final List<dynamic>? likes;
  final List<SocialComment>? comments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SocialPost.fromJson(Map<String, dynamic> json) => SocialPost(
        id: json["_id"],
        content: json["content"],
        media: json["media"] == null
            ? []
            : List<String>.from(json["media"]!.map((x) => x.toString())),
        views: json["views"] is int
            ? json["views"]
            : int.tryParse(json["views"]?.toString() ?? "0") ?? 0,
        active: json["active"],
        user: json["user"] == null
            ? null
            : (json["user"] is Map
                ? SocialUser.fromJson(json["user"])
                : null),
        likes: json["likes"] == null
            ? []
            : List<dynamic>.from(json["likes"]!),
        comments: json["comments"] == null
            ? []
            : List<SocialComment>.from(
                json["comments"]!.map((x) => SocialComment.fromJson(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"]),
      );

  int get likeCount => likes?.length ?? 0;
  int get commentCount => comments?.length ?? 0;
}

class SocialUser {
  SocialUser({
    this.id,
    this.name,
    this.email,
    this.profilePicture,
    this.role,
    this.positionName,
    this.countryName,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? profilePicture;
  final String? role;
  final String? positionName;
  final String? countryName;

  factory SocialUser.fromJson(Map<String, dynamic> json) => SocialUser(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        profilePicture: json["profilePicture"],
        role: json["role"],
        positionName: json["positionName"],
        countryName: json["countryName"],
      );
}

class SocialComment {
  SocialComment({
    this.id,
    this.user,
    this.text,
    this.createdAt,
  });

  final String? id;
  final SocialUser? user;
  final String? text;
  final DateTime? createdAt;

  factory SocialComment.fromJson(Map<String, dynamic> json) => SocialComment(
        id: json["_id"],
        user: json["user"] == null
            ? null
            : (json["user"] is Map
                ? SocialUser.fromJson(json["user"])
                : null),
        text: json["text"] ?? json["content"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"]),
      );
}

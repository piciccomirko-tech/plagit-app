class PostSaveModel {
  String? status;
  int? statusCode;
  String? message;
  Post? post;

  PostSaveModel({
    this.status,
    this.statusCode,
    this.message,
    this.post,
  });

  factory PostSaveModel.fromJson(Map<String, dynamic> json) => PostSaveModel(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        post: json["post"] == null ? null : Post.fromJson(json["post"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "post": post!.toJson(),
      };
}

class Post {
  String? user;
  String? post;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Post({
    this.user,
    this.post,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        user: json["user"],
        post: json["post"],
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "user": user,
        "post": post,
        "_id": id,
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "__v": v,
      };
}

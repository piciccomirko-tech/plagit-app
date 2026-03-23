import 'social_feed_response_model.dart';

class SavedPostModel {
  String? user;
  SocialPostModel? post;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  SavedPostModel({
    this.user,
    this.post,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) => SavedPostModel(
        user: json["user"],
        post: json["post"] != null
            ? SocialPostModel.fromJson(json["post"])
            : null,
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

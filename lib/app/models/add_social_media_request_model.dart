import 'dart:convert';

class AddSocialMediaRequestModel {
  final String content;
  final List<SocialMedia> media;

  AddSocialMediaRequestModel({
    required this.content,
    required this.media,
  });


  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "content": content,
    "media": List<dynamic>.from(media.map((x) => x.toJson())),
  };
}

class SocialMedia {
  final String url;
  final String type;

  SocialMedia({
    required this.url,
    required this.type,
  });


  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "url": url,
    "type": type,
  };
}

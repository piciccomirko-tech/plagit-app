import 'dart:convert';

class BioRequestModel {
  final String id;
  final String bio;

  BioRequestModel({
    required this.id,
    required this.bio,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "id": id,
        "bio": bio,
      };
}

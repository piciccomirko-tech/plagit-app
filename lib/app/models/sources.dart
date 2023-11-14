import 'dart:convert';

class Sources {
  Sources({
    this.status,
    this.statusCode,
    this.message,
    this.count,
    this.next,
    this.sources,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? count;
  final dynamic next;
  final List<Source>? sources;

  factory Sources.fromRawJson(String str) => Sources.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Sources.fromJson(Map<String, dynamic> json) => Sources(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    count: json["count"],
    next: json["next"],
    sources: json["sources"] == null ? [] : List<Source>.from(json["sources"]!.map((x) => Source.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "count": count,
    "next": next,
    "sources": sources == null ? [] : List<dynamic>.from(sources!.map((x) => x.toJson())),
  };
}

class Source {
  Source({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  factory Source.fromRawJson(String str) => Source.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Source.fromJson(Map<String, dynamic> json) => Source(
    id: json["_id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
  };
}

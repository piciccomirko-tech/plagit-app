import 'dart:convert';

class TermsConditionForHire {
  TermsConditionForHire({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.next,
    this.termsConditions,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? total;
  final int? count;
  final dynamic next;
  final List<TermsCondition>? termsConditions;

  factory TermsConditionForHire.fromRawJson(String str) => TermsConditionForHire.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TermsConditionForHire.fromJson(Map<String, dynamic> json) => TermsConditionForHire(
    status: json["status"],
    statusCode: json["statusCode"],
    message: json["message"],
    total: json["total"],
    count: json["count"],
    next: json["next"],
    termsConditions: json["termsConditions"] == null ? [] : List<TermsCondition>.from(json["termsConditions"]!.map((x) => TermsCondition.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "statusCode": statusCode,
    "message": message,
    "total": total,
    "count": count,
    "next": next,
    "termsConditions": termsConditions == null ? [] : List<dynamic>.from(termsConditions!.map((x) => x.toJson())),
  };
}

class TermsCondition {
  TermsCondition({
    this.id,
    this.description,
    this.active,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  final String? id;
  final String? description;
  final bool? active;
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory TermsCondition.fromRawJson(String str) => TermsCondition.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TermsCondition.fromJson(Map<String, dynamic> json) => TermsCondition(
    id: json["_id"],
    description: json["description"],
    active: json["active"],
    createdBy: json["createdBy"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "description": description,
    "active": active,
    "createdBy": createdBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}


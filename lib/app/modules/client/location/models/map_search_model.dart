class MapSearchResponseModel {
  String? status;
  int? statusCode;
  String? message;
  Details? details;

  MapSearchResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.details,
  });

  factory MapSearchResponseModel.fromJson(Map<String, dynamic> json) => MapSearchResponseModel(
        status: json["status"] ?? '',
        statusCode: json["statusCode"] ?? '',
        message: json["message"] ?? '',
        details:
            json["details"] != null ? Details.fromJson(json["details"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "details": details?.toJson(),
      };
}

class Details {
  String? address;
  double? lat;
  double? lng;
  int? totalCount;
  int? minHourlyRate;
  int? maxHourlyRate;
  double? radius;
  String? createdBy;
  String? position;
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Details({
    this.address,
    this.lat,
    this.lng,
    this.totalCount,
    this.minHourlyRate,
    this.maxHourlyRate,
    this.radius,
    this.createdBy,
    this.position,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Details.fromJson(Map<String, dynamic> json) => Details(
        address: json["address"] ?? '',
        lat: json["lat"]?.toDouble() ?? 0,
        lng: json["lng"]?.toDouble() ?? 0,
        totalCount: json["totalCount"] ?? 0,
        minHourlyRate: json["minHourlyRate"] ?? 0,
        maxHourlyRate: json["maxHourlyRate"] ?? 0,
        radius: json["radius"]?.toDouble() ?? 0,
        createdBy: json["createdBy"] ?? '',
        position: json["position"] ?? '',
        id: json["_id"] ?? '',
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : null,
        v: json["__v"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "lat": lat,
        "lng": lng,
        "totalCount": totalCount,
        "minHourlyRate": minHourlyRate,
        "maxHourlyRate": maxHourlyRate,
        "radius": radius,
        "createdBy": createdBy,
        "position": position,
        "_id": id,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };
}

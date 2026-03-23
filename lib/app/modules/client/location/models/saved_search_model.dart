class SavedSearchModel {
  String? id;
  String? address;
  double? lat;
  double? lng;
  int? totalCount;
  int? minHourlyRate;
  int? maxHourlyRate;
  double? radius;
  CreatedBy? createdBy;
  Position? position;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  SavedSearchModel({
    this.id,
    this.address,
    this.lat,
    this.lng,
    this.totalCount,
    this.minHourlyRate,
    this.maxHourlyRate,
    this.radius,
    this.createdBy,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SavedSearchModel.fromJson(Map<String, dynamic> json) =>
      SavedSearchModel(
        id: json["_id"] ?? '',
        address: json["address"] ?? '',
        lat: json["lat"]?.toDouble() ?? 0,
        lng: json["lng"]?.toDouble() ?? 0,
        totalCount: json["totalCount"] ?? 0,
        minHourlyRate: json["minHourlyRate"] ?? 0,
        maxHourlyRate: json["maxHourlyRate"] ?? 0,
        radius: json["radius"]?.toDouble() ?? 0,
        createdBy: json["createdBy"] != null
            ? CreatedBy.fromJson(json["createdBy"])
            : null,
        position: json["position"] != null
            ? Position.fromJson(json["position"])
            : null,
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "address": address,
        "lat": lat,
        "lng": lng,
        "totalCount": totalCount,
        "minHourlyRate": minHourlyRate,
        "maxHourlyRate": maxHourlyRate,
        "radius": radius,
        "createdBy": createdBy!.toJson(),
        "position": position!.toJson(),
        "createdAt": createdAt!.toIso8601String(),
        "updatedAt": updatedAt!.toIso8601String(),
        "__v": v,
      };
}

class CreatedBy {
  String? id;
  String? restaurantName;
  String? role;
  String? profilePicture;
  String? countryName;

  CreatedBy({
    this.id,
    this.restaurantName,
    this.role,
    this.profilePicture,
    this.countryName,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["_id"] ?? '',
        restaurantName: json["restaurantName"] ?? '',
        role: json["role"] ?? '',
        profilePicture: json["profilePicture"] ?? '',
        countryName: json["countryName"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "restaurantName": restaurantName,
        "role": role,
        "profilePicture": profilePicture,
        "countryName": countryName,
      };
}

class Position {
  String? id;
  String? name;

  Position({
    this.id,
    this.name,
  });

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        id: json["_id"] ?? '',
        name: json["name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
      };
}

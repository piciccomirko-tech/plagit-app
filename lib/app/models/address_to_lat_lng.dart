import 'dart:convert';

class AddressToLatLng {
  AddressToLatLng({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    this.boundingbox,
    this.lat,
    this.lon,
    this.displayName,
    this.placeRank,
    this.category,
    this.type,
    this.importance,
    this.icon,
  });

  final int? placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final List<String>? boundingbox;
  final String? lat;
  final String? lon;
  final String? displayName;
  final int? placeRank;
  final String? category;
  final String? type;
  final double? importance;
  final String? icon;

  factory AddressToLatLng.fromRawJson(String str) => AddressToLatLng.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AddressToLatLng.fromJson(Map<String, dynamic> json) => AddressToLatLng(
    placeId: json["place_id"],
    licence: json["licence"],
    osmType: json["osm_type"],
    osmId: json["osm_id"],
    boundingbox: json["boundingbox"] == null ? [] : List<String>.from(json["boundingbox"]!.map((x) => x)),
    lat: json["lat"],
    lon: json["lon"],
    displayName: json["display_name"],
    placeRank: json["place_rank"],
    category: json["category"],
    type: json["type"],
    importance: json["importance"]?.toDouble(),
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "place_id": placeId,
    "licence": licence,
    "osm_type": osmType,
    "osm_id": osmId,
    "boundingbox": boundingbox == null ? [] : List<dynamic>.from(boundingbox!.map((x) => x)),
    "lat": lat,
    "lon": lon,
    "display_name": displayName,
    "place_rank": placeRank,
    "category": category,
    "type": type,
    "importance": importance,
    "icon": icon,
  };
}

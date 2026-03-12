import 'dart:convert';

class LatLngToAddress {
  LatLngToAddress({
    this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    this.lat,
    this.lon,
    this.placeRank,
    this.category,
    this.type,
    this.importance,
    this.addresstype,
    this.name,
    this.displayName,
    this.address,
    this.boundingbox,
  });

  final int? placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final String? lat;
  final String? lon;
  final int? placeRank;
  final String? category;
  final String? type;
  final double? importance;
  final String? addresstype;
  final String? name;
  final String? displayName;
  final Address? address;
  final List<String>? boundingbox;

  factory LatLngToAddress.fromRawJson(String str) => LatLngToAddress.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LatLngToAddress.fromJson(Map<String, dynamic> json) => LatLngToAddress(
    placeId: json["place_id"],
    licence: json["licence"],
    osmType: json["osm_type"],
    osmId: json["osm_id"],
    lat: json["lat"],
    lon: json["lon"],
    placeRank: json["place_rank"],
    category: json["category"],
    type: json["type"],
    importance: json["importance"]?.toDouble(),
    addresstype: json["addresstype"],
    name: json["name"],
    displayName: json["display_name"],
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    boundingbox: json["boundingbox"] == null ? [] : List<String>.from(json["boundingbox"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "place_id": placeId,
    "licence": licence,
    "osm_type": osmType,
    "osm_id": osmId,
    "lat": lat,
    "lon": lon,
    "place_rank": placeRank,
    "category": category,
    "type": type,
    "importance": importance,
    "addresstype": addresstype,
    "name": name,
    "display_name": displayName,
    "address": address?.toJson(),
    "boundingbox": boundingbox == null ? [] : List<dynamic>.from(boundingbox!.map((x) => x)),
  };
}

class Address {
  Address({
    this.amenity,
    this.road,
    this.quarter,
    this.suburb,
    this.city,
    this.municipality,
    this.stateDistrict,
    this.iso31662Lvl5,
    this.state,
    this.iso31662Lvl4,
    this.postcode,
    this.country,
    this.countryCode,
  });

  final String? amenity;
  final String? road;
  final String? quarter;
  final String? suburb;
  final String? city;
  final String? municipality;
  final String? stateDistrict;
  final String? iso31662Lvl5;
  final String? state;
  final String? iso31662Lvl4;
  final String? postcode;
  final String? country;
  final String? countryCode;

  factory Address.fromRawJson(String str) => Address.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    amenity: json["amenity"],
    road: json["road"],
    quarter: json["quarter"],
    suburb: json["suburb"],
    city: json["city"],
    municipality: json["municipality"],
    stateDistrict: json["state_district"],
    iso31662Lvl5: json["ISO3166-2-lvl5"],
    state: json["state"],
    iso31662Lvl4: json["ISO3166-2-lvl4"],
    postcode: json["postcode"],
    country: json["country"],
    countryCode: json["country_code"],
  );

  Map<String, dynamic> toJson() => {
    "amenity": amenity,
    "road": road,
    "quarter": quarter,
    "suburb": suburb,
    "city": city,
    "municipality": municipality,
    "state_district": stateDistrict,
    "ISO3166-2-lvl5": iso31662Lvl5,
    "state": state,
    "ISO3166-2-lvl4": iso31662Lvl4,
    "postcode": postcode,
    "country": country,
    "country_code": countryCode,
  };
}

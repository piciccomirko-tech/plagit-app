import 'dart:convert';

class Client {
  Client({
    this.id,
    this.email,
    this.userIdNumber,
    this.phoneNumber,
    this.role,
    this.verified,
    this.active,
    this.client,
    this.sourceId,
    this.restaurantName,
    this.restaurantAddress,
    this.countryName,
    this.rating,
    this.isReferPerson,
    this.iat,
    this.exp,
    this.clientDiscount,
    this.lat,
    this.long,
  });

  final String? id;
  final String? email;
  final String? userIdNumber;
  final String? phoneNumber;
  final String? role;
  final bool? verified;
  final bool? active;
  final bool? client;
  final String? sourceId;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? countryName;
  final double? rating;
  final bool? isReferPerson;
  final int? iat;
  final int? exp;
  final double? clientDiscount;
  final String? lat;
  final String? long;

  factory Client.fromRawJson(String str) => Client.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: json["_id"],
    email: json["email"],
    userIdNumber: json["userIdNumber"],
    phoneNumber: json["phoneNumber"],
    role: json["role"],
    verified: json["verified"],
    active: json["active"],
    client: json["client"],
    sourceId: json["sourceId"],
    restaurantName: json["restaurantName"],
    restaurantAddress: json["restaurantAddress"],
    countryName: json["countryName"],
    rating: json["rating"] == null ? 0.0 : double.parse(json["rating"].toString()),
    isReferPerson: json["isReferPerson"],
    iat: json["iat"],
    exp: json["exp"],
    clientDiscount: double.parse(json["clientDiscount"].toString()),
    lat: json["lat"],
    long: json["long"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "userIdNumber": userIdNumber,
    "phoneNumber": phoneNumber,
    "role": role,
    "verified": verified,
    "active": active,
    "client": client,
    "sourceFrom": sourceId,
    "restaurantName": restaurantName,
    "restaurantAddress": restaurantAddress,
    "countryName": countryName,
    "rating": rating,
    "isReferPerson": isReferPerson,
    "iat": iat,
    "exp": exp,
    "clientDiscount": clientDiscount,
    "lat": lat,
    "long": long,
  };
}

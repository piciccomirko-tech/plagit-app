import 'dart:convert';

class CheckInCheckOutDetails {
  CheckInCheckOutDetails({
    this.hiredBy,
    this.checkInDistance,
    this.checkOutDistance,
    this.breakTime,
    this.checkIn,
    this.checkOut,
    this.checkInTime,
    this.checkOutTime,
    this.emmergencyCheckIn,
    this.emmergencyCheckOut,
    this.checkInLat,
    this.checkInLong,
    this.checkOutLat,
    this.checkOutLong,
    this.id,
    this.clientCheckInTime,
    this.clientCheckOutTime,
    this.clientComment,
    this.clientBreakTime,
  });

  final String? hiredBy;
  final double? checkInDistance;
  final double? checkOutDistance;
  final int? breakTime;
  final bool? checkIn;
  final bool? checkOut;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final bool? emmergencyCheckIn;
  final bool? emmergencyCheckOut;
  final String? checkInLat;
  final String? checkInLong;
  final String? checkOutLat;
  final String? checkOutLong;
  final String? id;
  final DateTime? clientCheckInTime;
  final DateTime? clientCheckOutTime;
  final String? clientComment;
  final int? clientBreakTime;

  factory CheckInCheckOutDetails.fromRawJson(String str) => CheckInCheckOutDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckInCheckOutDetails.fromJson(Map<String, dynamic> json) => CheckInCheckOutDetails(
    hiredBy: json["hiredBy"],
    checkInDistance: double.parse(json["checkInDistance"].toString()),
    checkOutDistance: double.parse(json["checkOutDistance"].toString()),
    breakTime: json["breakTime"],
    checkIn: json["checkIn"],
    checkOut: json["checkOut"],
    checkInTime: json["checkInTime"] == null ? null : DateTime.parse(json["checkInTime"]),
    checkOutTime: json["checkOutTime"] == null ? null : DateTime.parse(json["checkOutTime"]),
    emmergencyCheckIn: json["emmergencyCheckIn"],
    emmergencyCheckOut: json["emmergencyCheckOut"],
    checkInLat: json["checkInLat"],
    checkInLong: json["checkInLong"],
    checkOutLat: json["checkOutLat"],
    checkOutLong: json["checkOutLong"],
    id: json["_id"],
    clientCheckInTime: json["clientCheckInTime"] == null ? null : DateTime.parse(json["clientCheckInTime"]),
    clientCheckOutTime: json["clientCheckOutTime"] == null ? null : DateTime.parse(json["clientCheckOutTime"]),
    clientComment: json["clientComment"],
    clientBreakTime: json["clientBreakTime"],
  );

  Map<String, dynamic> toJson() => {
    "hiredBy": hiredBy,
    "checkInDistance": checkInDistance,
    "checkOutDistance": checkOutDistance,
    "breakTime": breakTime,
    "checkIn": checkIn,
    "checkOut": checkOut,
    "checkInTime": checkInTime?.toIso8601String(),
    "checkOutTime": checkOutTime?.toIso8601String(),
    "emmergencyCheckIn": emmergencyCheckIn,
    "emmergencyCheckOut": emmergencyCheckOut,
    "checkInLat": checkInLat,
    "checkInLong": checkInLong,
    "checkOutLat": checkOutLat,
    "checkOutLong": checkOutLong,
    "_id": id,
    "clientCheckInTime": checkInTime?.toIso8601String(),
    "clientCheckOutTime": checkInTime?.toIso8601String(),
    "clientComment": clientComment,
    "clientBreakTime": clientBreakTime,
  };
}
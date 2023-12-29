import 'dart:convert';

class EmployeeLocationUpdateRequestModel {
  final String id;
  final String lat;
  final String long;

  EmployeeLocationUpdateRequestModel({
    required this.id,
    required this.lat,
    required this.long,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "id": id,
        "lat": lat,
        "long": long,
      };
}

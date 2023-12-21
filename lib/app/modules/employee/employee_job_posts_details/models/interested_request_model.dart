import 'dart:convert';

class InterestedRequestModel {
  final String id;
  final String employeeId;

  InterestedRequestModel({
    required this.id,
    required this.employeeId,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "id": id,
        "employeeId": employeeId,
      };
}

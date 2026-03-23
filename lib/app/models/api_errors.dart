import 'dart:convert';

class ApiErrors {
  ApiErrors({
    this.value,
    this.msg,
    this.param,
    this.location,
  });

  final String? value;
  final String? msg;
  final String? param;
  final String? location;

  factory ApiErrors.fromRawJson(String str) =>
      ApiErrors.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ApiErrors.fromJson(Map<String, dynamic> json) => ApiErrors(
        value: json["value"],
        msg: json["msg"],
        param: json["param"],
        location: json["location"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "msg": msg,
        "param": param,
        "location": location,
      };
}

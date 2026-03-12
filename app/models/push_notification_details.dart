import 'dart:convert';

class PushNotificationDetails {
  final String? uuid;
  final String? fcmToken;
  final String? platform;
  final String? id;

  PushNotificationDetails({
    this.uuid,
    this.fcmToken,
    this.platform,
    this.id,
  });

  factory PushNotificationDetails.fromRawJson(String str) => PushNotificationDetails.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PushNotificationDetails.fromJson(Map<String, dynamic> json) => PushNotificationDetails(
    uuid: json["uuid"],
    fcmToken: json["fcmToken"],
    platform: json["platform"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "fcmToken": fcmToken,
    "platform": platform,
    "_id": id,
  };
}
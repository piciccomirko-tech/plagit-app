import 'dart:convert';

class AppVersion {
  AppVersion({
    this.active,
    this.id,
    this.appVersion,
    this.updateRequired,
    this.showUpdateDialog,
    this.updatedAt,
    this.appStoreLink,
    this.playStoreLink,
    this.serverMaintenance,
    this.serverMaintenanceMsg,
    this.stripePublisherKey,
    this.stripeSecret,
  });

  final bool? active;
  final String? id;
  final String? appVersion;
  final bool? updateRequired;
  final bool? showUpdateDialog;
  final DateTime? updatedAt;
  final String? appStoreLink;
  final String? playStoreLink;
  final bool? serverMaintenance;
  final String? serverMaintenanceMsg;
  final String? stripePublisherKey;
  final String? stripeSecret;

  factory AppVersion.fromRawJson(String str) => AppVersion.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    active: json["active"],
    id: json["_id"],
    appVersion: json["appVersion"],
    updateRequired: json["updateRequired"],
    showUpdateDialog: json["showUpdateDialog"],
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    appStoreLink: json["appStoreLink"],
    playStoreLink: json["playStoreLink"],
    serverMaintenance: json["serverMaintenance"],
    serverMaintenanceMsg: json["serverMaintenanceMsg"],
    stripePublisherKey: json["stripePublisherKey"],
    stripeSecret: json["stripeSecret"],
  );

  Map<String, dynamic> toJson() => {
    "active": active,
    "_id": id,
    "appVersion": appVersion,
    "updateRequired": updateRequired,
    "showUpdateDialog": showUpdateDialog,
    "updatedAt": updatedAt?.toIso8601String(),
    "appStoreLink": appStoreLink,
    "playStoreLink": playStoreLink,
    "serverMaintenance": serverMaintenance,
    "serverMaintenanceMsg": serverMaintenanceMsg,
    "stripePublisherKey": stripePublisherKey,
    "stripeSecret": stripeSecret,
  };
}
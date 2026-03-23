import 'dart:convert';

class SubscriptionPlanResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final List<SubscriptionPlanModel>? result;

  SubscriptionPlanResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.result,
  });

  factory SubscriptionPlanResponseModel.fromRawJson(String str) =>
      SubscriptionPlanResponseModel.fromJson(json.decode(str));

  factory SubscriptionPlanResponseModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlanResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<SubscriptionPlanModel>.from(
                json["result"]!.map((x) => SubscriptionPlanModel.fromJson(x))),
      );
}

class SubscriptionPlanModel {
  final String? id;
  final String? name;
  final String? role;
  final List<String>? keys;
  final List<String>? features;
  final double? yearlyCharge;
  final double? yearlyChargeInPound;
  final double? yearlyChargeInDirham;
  final double? yearlyChargeInEuro;
  final double? monthlyCharge;
  final double? monthlyChargeInPound;
  final double? monthlyChargeInDirham;
  final double? monthlyChargeInEuro;
  final String? currency;
  final String? discountType;
  final double? discount;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;
  final bool? hasDiscount;
  final bool? active;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  SubscriptionPlanModel({
    this.id,
    this.name,
    this.role,
    this.keys,
    this.features,
    this.yearlyCharge,
    this.yearlyChargeInPound,
    this.yearlyChargeInDirham,
    this.yearlyChargeInEuro,
    this.monthlyCharge,
    this.monthlyChargeInPound,
    this.monthlyChargeInDirham,
    this.monthlyChargeInEuro,
    this.currency,
    this.discountType,
    this.discount,
    this.discountStartDate,
    this.discountEndDate,
    this.hasDiscount,
    this.active,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory SubscriptionPlanModel.fromRawJson(String str) =>
      SubscriptionPlanModel.fromJson(json.decode(str));

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionPlanModel(
        id: json["_id"],
        name: json["name"],
        role: json["role"],
        keys: json["keys"] == null
            ? []
            : List<String>.from(json["keys"]!.map((x) => x)),
        features: json["features"] == null
            ? []
            : List<String>.from(json["features"]!.map((x) => x)),
        yearlyCharge: json["yearlyCharge"] == null
            ? 0.0
            : double.parse(json["yearlyCharge"].toString()),
        yearlyChargeInPound: json["yearlyChargeinPound"] == null
            ? 0.0
            : double.parse(json["yearlyChargeinPound"].toString()),
        yearlyChargeInDirham: json["yearlyChargeinDerham"] == null
            ? 0.0
            : double.parse(json["yearlyChargeinDerham"].toString()),
        yearlyChargeInEuro: json["yearlyChargeinEuro"] == null
            ? 0.0
            : double.parse(json["yearlyChargeinEuro"].toString()),
        monthlyCharge: json["monthlyCharge"] == null
            ? 0.0
            : double.parse(json["monthlyCharge"].toString()),
        monthlyChargeInPound: json["monthlyChargeinPound"] == null
            ? 0.0
            : double.parse(json["monthlyChargeinPound"].toString()),
        monthlyChargeInDirham: json["monthlyChargeinDerham"] == null
            ? 0.0
            : double.parse(json["monthlyChargeinDerham"].toString()),
        monthlyChargeInEuro: json["monthlyChargeinEuro"] == null
            ? 0.0
            : double.parse(json["monthlyChargeinEuro"].toString()),
        currency: json["currency"],
        discountType: json["discountType"],
        discount: json["discount"] == null
            ? 0.0
            : double.parse(json["discount"].toString()),
        discountStartDate: json["discountStartDate"] == null
            ? null
            : DateTime.parse(json["discountStartDate"]),
        discountEndDate: json["discountEndDate"] == null
            ? null
            : DateTime.parse(json["discountEndDate"]),
        hasDiscount: json["hasDiscount"],
        active: json["active"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );
}

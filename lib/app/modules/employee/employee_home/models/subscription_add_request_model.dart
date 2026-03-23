import 'dart:convert';

class SubscriptionAddRequestModel {
  final String plan;
  final String currency;
  final double yearlyCharge;
  final double monthlyCharge;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime paymentDate;
  final DateTime nextPaymentDate;

  SubscriptionAddRequestModel({
    required this.plan,
    required this.currency,
    required this.yearlyCharge,
    required this.monthlyCharge,
    required this.startDate,
    required this.endDate,
    required this.paymentDate,
    required this.nextPaymentDate,
  });


  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "plan": plan,
    "currency": currency,
    "yearlyCharge": yearlyCharge,
    "monthlyCharge": monthlyCharge,
    "startDate": "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
    "endDate": "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}",
    "paymentDate": "${paymentDate.year.toString().padLeft(4, '0')}-${paymentDate.month.toString().padLeft(2, '0')}-${paymentDate.day.toString().padLeft(2, '0')}",
    "nextPaymentDate": "${nextPaymentDate.year.toString().padLeft(4, '0')}-${nextPaymentDate.month.toString().padLeft(2, '0')}-${nextPaymentDate.day.toString().padLeft(2, '0')}",
  };
}

import 'dart:convert';

class UpdateRefundModel {
  final String id;
  final double refundAmount;
  final String remark;

  UpdateRefundModel({
    required this.id,
    required this.refundAmount,
    required this.remark,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "id": id,
    "refundAmount": refundAmount,
    "remark": remark,
  };
}

class StripeRequestModel {
  final double amount;
  final String invoiceId;
  final String currency;

  StripeRequestModel({required this.amount, required this.invoiceId, required this.currency});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['invoiceId'] = invoiceId;
    data['currency'] = currency;
    return data;
  }
}

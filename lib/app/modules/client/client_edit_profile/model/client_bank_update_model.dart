class ClientBankDetailsModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final String routingNumber;
  final String? dressSize;
  final String? additionalOne;
  final String? additionalTwo;
  // final String companyName;
  // final String vatNumber;
  // final String companyRegisterNumber;

  ClientBankDetailsModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.routingNumber,
     this.dressSize,
     this.additionalOne,
     this.additionalTwo,
    // required this.companyName,
    // required this.vatNumber,
    // required this.companyRegisterNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "bankName": bankName,
      "accountNumber": accountNumber,
      "routingNumber": routingNumber,
      // "dressSize": dressSize,
      "additionalOne": additionalOne,
      "additionalTwo": additionalTwo,
      // "companyName": companyName,
      // "vatNumber": vatNumber,
      // "companyRegisterNumber": companyRegisterNumber,
    };
  }
}

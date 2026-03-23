class ClientBankInfoModel {
  String? status;
  int? statusCode;
  ClientBankInfoDetailsModel? details;

  ClientBankInfoModel({this.status, this.statusCode, this.details});

  ClientBankInfoModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    details = json['details'] != null ? ClientBankInfoDetailsModel.fromJson(json['details']) : null;
  }
}

class ClientBankInfoDetailsModel {
  String? id;
  String? bankName;
  String? accountNumber;
  String? routingNumber;
  String? additionalOne;
  String? additionalTwo;
  String? companyName;

  ClientBankInfoDetailsModel(
      {this.id,
      this.bankName,
      this.accountNumber,
      this.routingNumber,
      this.additionalOne,
      this.additionalTwo,
      this.companyName});

  ClientBankInfoDetailsModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    bankName = json['bankName'];
    accountNumber = json['accountNumber'];
    routingNumber = json['routingNumber'];
    additionalOne = json['additionalOne'];
    additionalTwo = json['additionalTwo'];
    companyName = json['companyName'];
  }
}

class EmployeePaymentHistory {
  String? status;
  int? statusCode;
  List<EmployeePaymentHistoryModel>? employeePaymentHistoryList;

  EmployeePaymentHistory({this.status, this.statusCode, this.employeePaymentHistoryList});

  EmployeePaymentHistory.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    if (json['invoices'] != null) {
      employeePaymentHistoryList = <EmployeePaymentHistoryModel>[];
      json['invoices'].forEach((v) {
        employeePaymentHistoryList!.add(EmployeePaymentHistoryModel.fromJson(v));
      });
    }
  }
}

class EmployeePaymentHistoryModel {
  String? sId;
  double? totalHours;
  double? amount;
  double? employeeAmount;
  double? contractorHourlyRate;
  double? hourlyRate;
  DateTime? fromDate;
  DateTime? toDate;
  String? restaurantName;
  String? employeeName;
  String? positionName;
  String? status;

  EmployeePaymentHistoryModel(
      {this.sId,
      this.totalHours = 0.0,
      this.amount = 0.0,
      this.employeeAmount = 0.0,
      this.contractorHourlyRate = 0.0,
      this.hourlyRate = 0.0,
      this.fromDate,
      this.toDate,
      this.restaurantName,
      this.employeeName,
      this.positionName,
      this.status});

  EmployeePaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    totalHours = json['totalHours'] == null ? 0.0 : double.parse(json['totalHours'].toString());
    amount = json['amount'] == null ? 0.0 : double.parse(json['amount'].toString());
    employeeAmount = json['employeeAmount'] == null ? 0.0 : double.parse(json['employeeAmount'].toString());
    contractorHourlyRate =
        json['contractorHourlyRate'] == null ? 0.0 : double.parse(json['contractorHourlyRate'].toString());
    hourlyRate = json['hourlyRate'] == null ? 0.0 : double.parse(json['hourlyRate'].toString());
    fromDate = json['fromDate'] == null ? null : DateTime.parse(json['fromDate']);
    toDate = json['toDate'] == null ? null : DateTime.parse(json['toDate']);
    restaurantName = json['restaurantName'];
    employeeName = json['employeeName'];
    positionName = json['positionName'];
    status = json['status'];
  }
}

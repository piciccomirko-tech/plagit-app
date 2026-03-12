class HourlyRateModel {
  String? status;
  HourlyRateDetailsModel? result;

  HourlyRateModel({this.status, this.result});

  HourlyRateModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    result = json['result'] != null ? HourlyRateDetailsModel.fromJson(json['result']) : null;
  }
}

class HourlyRateDetailsModel {
  String? min;
  String? max;

  HourlyRateDetailsModel({this.min, this.max});

  HourlyRateDetailsModel.fromJson(Map<String, dynamic> json) {
    min = json['min'].toString();
    max = json['max'].toString();
  }
}

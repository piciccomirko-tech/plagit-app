class CalenderModel {
  String? status;
  int? statusCode;
  String? message;
  DateListModel? dateList;

  CalenderModel({this.status, this.statusCode, this.message, this.dateList});

  CalenderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    dateList = json['result'] != null ? DateListModel.fromJson(json['result']) : null;
  }
}

class DateListModel {
  List<CalenderDataModel>? bookedDates;
  List<CalenderDataModel>? pendingDates;
  List<CalenderDataModel>? unavailableDates;

  DateListModel({this.bookedDates, this.pendingDates, this.unavailableDates});

  DateListModel.fromJson(Map<String, dynamic> json) {
    if (json['bookedDates'] != null) {
      bookedDates = <CalenderDataModel>[];
      json['bookedDates'].forEach((v) {
        bookedDates!.add(CalenderDataModel.fromJson(v));
      });
    }
    if (json['pendingDates'] != null) {
      pendingDates = <CalenderDataModel>[];
      json['pendingDates'].forEach((v) {
        pendingDates!.add(CalenderDataModel.fromJson(v));
      });
    }
    if (json['unavailableDates'] != null) {
      unavailableDates = <CalenderDataModel>[];
      json['unavailableDates'].forEach((v) {
        unavailableDates!.add(CalenderDataModel.fromJson(v));
      });
    }
  }
}

class CalenderDataModel {
  String? startDate;
  String? endDate;

  CalenderDataModel({this.startDate, this.endDate});

  CalenderDataModel.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
  }
}


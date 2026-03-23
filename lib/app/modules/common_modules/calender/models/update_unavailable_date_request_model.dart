class UpdateUnavailableDateRequestModel {
  List<Dates> unavailableDateList;

  UpdateUnavailableDateRequestModel({required this.unavailableDateList});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dates'] = unavailableDateList.map((v) => v.toJson()).toList();
    return data;
  }
}

class Dates {
  String startDate;
  String endDate;

  Dates({required this.startDate, required this.endDate});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    return data;
  }
}

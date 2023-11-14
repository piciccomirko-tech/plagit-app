class EmployeeCheckOutRequestModel {
  final String id;
  final bool checkOut;
  final String lat;
  final String long;
  final int breakTime;
  final double totalWorkingHour;
  final double checkOutDistance;
  final String checkOutTime;

  EmployeeCheckOutRequestModel(
      {required this.id,
      required this.checkOut,
      required this.lat,
      required this.long,
      required this.breakTime,
      required this.totalWorkingHour,
      required this.checkOutDistance,
      required this.checkOutTime});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['checkOut'] = checkOut;
    data['lat'] = lat;
    data['long'] = long;
    data['breakTime'] = breakTime;
    data['totalWorkingHour'] = totalWorkingHour;
    data['checkOutDistance'] = checkOutDistance;
    data['checkOutTime'] = checkOutTime;
    return data;
  }
}

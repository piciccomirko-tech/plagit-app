class EmployeeCheckInRequestModel {
 final String employeeId;
 final String hiredBy;
 final bool? checkIn;
 final String lat;
 final String long;
 final double checkInDistance;
 final String checkInTime;

  EmployeeCheckInRequestModel(
      {required this.employeeId,
      required this.hiredBy,
      required this.checkIn,
      required this.lat,
      required this.long,
      required this.checkInDistance,
      required this.checkInTime
      });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['hiredBy'] = hiredBy;
    data['checkIn'] = checkIn;
    data['lat'] = lat;
    data['long'] = long;
    data['checkInDistance'] = checkInDistance;
    data['checkInTime'] = checkInTime;
    return data;
  }
}

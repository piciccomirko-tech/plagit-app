class UserDailyStatistics {
  String date;
  String restaurantName;
  String employeeName;
  String position;
  String displayCheckInTime;
  String displayCheckOutTime;
  String displayBreakTime;
  String clientCheckInTime;
  String clientCheckOutTime;
  String clientBreakTime;
  String employeeCheckInTime;
  String employeeCheckOutTime;
  String employeeBreakTime;
  String workingHour;
  String amount;
  String complain;
  int totalWorkingTimeInMinute = 0;

  UserDailyStatistics({
    required this.date,
    required this.restaurantName,
    required this.employeeName,
    required this.position,
    required this.displayCheckInTime,
    required this.displayCheckOutTime,
    required this.displayBreakTime,
    required this.clientCheckInTime,
    required this.clientCheckOutTime,
    required this.clientBreakTime,
    required this.employeeCheckInTime,
    required this.employeeCheckOutTime,
    required this.employeeBreakTime,
    required this.workingHour,
    required this.amount,
    required this.complain,
    required this.totalWorkingTimeInMinute,
  });
}

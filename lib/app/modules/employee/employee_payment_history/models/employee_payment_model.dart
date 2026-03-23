class EmployeePaymentModel {
  String day;
  String restaurantName;
  String position;
  double contractorPerHoursRate;
  double? travelCost;
  double? tips;
  String totalHours;
  double employeeAmount;
  String status;

  EmployeePaymentModel({
    required this.day,
    required this.restaurantName,
    required this.position,
    required this.contractorPerHoursRate,
     this.travelCost,
     this.tips,
    required this.totalHours,
    required this.employeeAmount,
    required this.status,
  });
}

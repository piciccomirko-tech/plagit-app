import 'dart:convert';

// Root model for today's check-in and check-out details
class TodayCheckInOutDetailsForClient {
  String? status;
  int? statusCode;
  String? message;
  List<Employee>? result;

  TodayCheckInOutDetailsForClient({
    this.status,
    this.statusCode,
    this.message,
    this.result,
  });

  // Factory constructor for creating an instance from JSON
  factory TodayCheckInOutDetailsForClient.fromJson(Map<String, dynamic> json) {
    return TodayCheckInOutDetailsForClient(
      status: json["status"],
      statusCode: json["statusCode"],
      message: json["message"],
      result: json["result"] == null
          ? []
          : List<Employee>.from(
              json["result"].map((employeeJson) => Employee.fromJson(employeeJson)),
            ),
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "statusCode": statusCode,
      "message": message,
      "result": result?.map((employee) => employee.toJson()).toList(),
    };
  }
}

// Model for each employee in the "result" list
class Employee {
  String? id;
  String? currentHiredEmployeeId;
  String? name;
  String? profilePicture;

  Employee({
    this.id,
    this.currentHiredEmployeeId,
    this.name,
    this.profilePicture,
  });

  // Factory constructor for creating an instance from JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json["id"],
      currentHiredEmployeeId: json["currentHiredEmployeeId"],
      name: json["name"],
      profilePicture: json["profilePicture"],
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "currentHiredEmployeeId": currentHiredEmployeeId,
      "name": name,
      "profilePicture": profilePicture,
    };
  }
}

// For testing purposes, you can parse JSON like this
TodayCheckInOutDetailsForClient parseTodayCheckInOutDetails(String jsonStr) {
  final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
  return TodayCheckInOutDetailsForClient.fromJson(jsonData);
}

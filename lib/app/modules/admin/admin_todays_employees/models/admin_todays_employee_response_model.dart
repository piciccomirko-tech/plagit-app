class AdminTodaysEmployeeResponseModel {
  AdminTodaysEmployeeResponseModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.details,});

  AdminTodaysEmployeeResponseModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
  }
  String? status;
  num? statusCode;
  String? message;
  Details? details;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (details != null) {
      map['details'] = details?.toJson();
    }
    return map;
  }

}

class Details {
  Details({
      this.result,});

  Details.fromJson(dynamic json) {
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  Result? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (result != null) {
      map['result'] = result?.toJson();
    }
    return map;
  }

}

class Result {
  Result({
      this.hiredBy, 
      this.restaurantDetails, 
      this.employee,});

  Result.fromJson(dynamic json) {
    hiredBy = json['hiredBy'];
    restaurantDetails = json['restaurantDetails'] != null ? RestaurantDetails.fromJson(json['restaurantDetails']) : null;
    if (json['employee'] != null) {
      employee = [];
      json['employee'].forEach((v) {
        employee?.add(Employee.fromJson(v));
      });
    }
  }
  String? hiredBy;
  RestaurantDetails? restaurantDetails;
  List<Employee>? employee;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hiredBy'] = hiredBy;
    if (restaurantDetails != null) {
      map['restaurantDetails'] = restaurantDetails?.toJson();
    }
    if (employee != null) {
      map['employee'] = employee?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class Employee {
  Employee({
      this.id, 
      this.employeeId, 
      this.employeeDetails, 
      this.bookedDate, 
      this.unreadMessage,});

  Employee.fromJson(dynamic json) {
    id = json['_id'];
    employeeId = json['employeeId'];
    employeeDetails = json['employeeDetails'] != null ? EmployeeDetails.fromJson(json['employeeDetails']) : null;
    if (json['bookedDate'] != null) {
      bookedDate = [];
      json['bookedDate'].forEach((v) {
        bookedDate?.add(BookedDate.fromJson(v));
      });
    }
    unreadMessage = json['unreadMessage'];
  }
  String? id;
  String? employeeId;
  EmployeeDetails? employeeDetails;
  List<BookedDate>? bookedDate;
  num? unreadMessage;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['employeeId'] = employeeId;
    if (employeeDetails != null) {
      map['employeeDetails'] = employeeDetails?.toJson();
    }
    if (bookedDate != null) {
      map['bookedDate'] = bookedDate?.map((v) => v.toJson()).toList();
    }
    map['unreadMessage'] = unreadMessage;
    return map;
  }

}

class BookedDate {
  BookedDate({
      this.startDate, 
      this.endDate, 
      this.startTime, 
      this.endTime,});

  BookedDate.fromJson(dynamic json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
  }
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['startDate'] = startDate;
    map['endDate'] = endDate;
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    return map;
  }

}

class EmployeeDetails {
  EmployeeDetails({
      this.id, 
      this.name, 
      this.positionId, 
      this.positionName, 
      this.presentAddress, 
      this.employeeExperience, 
      this.rating, 
      this.totalWorkingHour, 
      this.hourlyRate, 
      this.profilePicture, 
      this.contractorHourlyRate, 
      this.countryName, 
      this.nationality, 
      this.lat, 
      this.long,});

  EmployeeDetails.fromJson(dynamic json) {
    id = json['_id'];
    name = json['name'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    presentAddress = json['presentAddress'];
    employeeExperience = json['employeeExperience'];
    rating = json['rating'];
    totalWorkingHour = json['totalWorkingHour'];
    hourlyRate = json['hourlyRate'];
    profilePicture = json['profilePicture'];
    contractorHourlyRate = json['contractorHourlyRate'];
    countryName = json['countryName'];
    nationality = json['nationality'];
    lat = json['lat'];
    long = json['long'];
  }
  String? id;
  String? name;
  String? positionId;
  String? positionName;
  String? presentAddress;
  String? employeeExperience;
  num? rating;
  String? totalWorkingHour;
  num? hourlyRate;
  String? profilePicture;
  num? contractorHourlyRate;
  String? countryName;
  String? nationality;
  String? lat;
  String? long;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['name'] = name;
    map['positionId'] = positionId;
    map['positionName'] = positionName;
    map['presentAddress'] = presentAddress;
    map['employeeExperience'] = employeeExperience;
    map['rating'] = rating;
    map['totalWorkingHour'] = totalWorkingHour;
    map['hourlyRate'] = hourlyRate;
    map['profilePicture'] = profilePicture;
    map['contractorHourlyRate'] = contractorHourlyRate;
    map['countryName'] = countryName;
    map['nationality'] = nationality;
    map['lat'] = lat;
    map['long'] = long;
    return map;
  }

}

class RestaurantDetails {
  RestaurantDetails({
      this.id, 
      this.restaurantName, 
      this.restaurantAddress, 
      this.lat, 
      this.long, 
      this.countryName, 
      this.profilePicture, 
      this.hiredBy,});

  RestaurantDetails.fromJson(dynamic json) {
    id = json['_id'];
    restaurantName = json['restaurantName'];
    restaurantAddress = json['restaurantAddress'];
    lat = json['lat'];
    long = json['long'];
    countryName = json['countryName'];
    profilePicture = json['profilePicture'];
    hiredBy = json['hiredBy'];
  }
  String? id;
  String? restaurantName;
  String? restaurantAddress;
  String? lat;
  String? long;
  String? countryName;
  String? profilePicture;
  String? hiredBy;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['restaurantName'] = restaurantName;
    map['restaurantAddress'] = restaurantAddress;
    map['lat'] = lat;
    map['long'] = long;
    map['countryName'] = countryName;
    map['profilePicture'] = profilePicture;
    map['hiredBy'] = hiredBy;
    return map;
  }

}
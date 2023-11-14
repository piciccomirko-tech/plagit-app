class EmployeeDetails {
  String? employeeId;
  String? name;
  String? positionId;
  String? positionName;
  String? presentAddress;
  String? permanentAddress;
  dynamic employeeExperience;
  double? rating;
  double? totalWorkingHour;
  double? hourlyRate;
  double? contractorHourlyRate;
  String? sId;
  String? profilePicture;
  String? restaurantName;
  String? restaurantAddress;

  // for ShortlistedEmployees
  DateTime? fromDate;
  DateTime? toDate;

  bool? certified;

  bool? hasUniform;

  EmployeeDetails({
    this.employeeId,
    this.name,
    this.positionId,
    this.positionName,
    this.presentAddress,
    this.permanentAddress,
    this.employeeExperience,
    this.rating,
    this.totalWorkingHour,
    this.hourlyRate,
    this.contractorHourlyRate,
    this.sId,
    this.profilePicture,
    this.restaurantName,
    this.restaurantAddress,
    this.fromDate,
    this.toDate,
    this.certified,
    this.hasUniform
  });

  EmployeeDetails.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    name = json['name'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    presentAddress = json['presentAddress'];
    permanentAddress = json['permanentAddress'];
    employeeExperience = json['employeeExperience'];
    rating = json['rating'] == null ? 0.0 : double.parse(json['rating'].toString());
    totalWorkingHour = json['totalWorkingHour'] == null ? 0.0 : double.parse(json['totalWorkingHour'].toString());
    hourlyRate = json['hourlyRate'] == null ? 0.0 : double.parse(json['hourlyRate'].toString());
    contractorHourlyRate =
        json['contractorHourlyRate'] == null ? 0.0 : double.parse(json['contractorHourlyRate'].toString());
    sId = json['_id'];
    profilePicture = json['profilePicture'];
    restaurantName = json['restaurantName'];
    restaurantAddress = json['restaurantAddress'];
    fromDate = json["fromDate"] == null ? null : DateTime.parse(json["fromDate"]);
    toDate = json["toDate"] == null ? null : DateTime.parse(json["toDate"]);
    certified = json["certified"];
    hasUniform = json["hasUniform"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employeeId'] = employeeId;
    data['name'] = name;
    data['positionId'] = positionId;
    data['positionName'] = positionName;
    data['presentAddress'] = presentAddress;
    data['permanentAddress'] = permanentAddress;
    data['employeeExperience'] = employeeExperience;
    data['rating'] = rating;
    data['totalWorkingHour'] = totalWorkingHour;
    data['hourlyRate'] = hourlyRate;
    data['contractorHourlyRate'] = contractorHourlyRate;
    data['_id'] = sId;
    data['profilePicture'] = profilePicture;
    data['restaurantName'] = restaurantName;
    data['restaurantAddress'] = restaurantAddress;
    data['certified'] = certified;
    data['hasUniform'] = hasUniform;
    data['fromDate'] = fromDate?.toIso8601String();
    data['toDate'] = fromDate?.toIso8601String();
    return data;
  }
}

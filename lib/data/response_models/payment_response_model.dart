class PaymentResponseModel {
  String? status;
  int? statusCode;
  String? message;
  int? total;
  int? count;
  Null next;
  List<Result>? result;

  PaymentResponseModel(
      {this.status,
      this.statusCode,
      this.message,
      this.total,
      this.count,
      this.next,
      this.result});

  PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    total = json['total'];
    count = json['count'];
    next = json['next'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    data['total'] = total;
    data['count'] = count;
    data['next'] = next;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  String? sId;
  String? employeeId;
  String? hiredBy;
  EmployeeDetails? employeeDetails;
  RestaurantDetails? restaurantDetails;
  String? invoiceUrl;
  List<BookedDate>? bookedDate;
  String? endHiredDate;
  bool? uniformMandatory;
  bool? clientReview;
  bool? employeeReview;
  String? paymentResponse;
  String? paymentStatus;
  double? totalPlatformFee;
  bool? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.sId,
    this.employeeId,
    this.hiredBy,
    this.employeeDetails,
    this.restaurantDetails,
    this.invoiceUrl,
    this.bookedDate,
    this.endHiredDate,
    this.uniformMandatory,
    this.clientReview,
    this.employeeReview,
    this.paymentResponse,
    this.paymentStatus,
    this.totalPlatformFee,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Result.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    employeeId = json['employeeId'];
    hiredBy = json['hiredBy'];
    employeeDetails = json['employeeDetails'] != null
        ? EmployeeDetails.fromJson(json['employeeDetails'])
        : null;
    restaurantDetails = json['restaurantDetails'] != null
        ? RestaurantDetails.fromJson(json['restaurantDetails'])
        : null;
    invoiceUrl = json['invoiceUrl'];
    if (json['bookedDate'] != null) {
      bookedDate = <BookedDate>[];
      json['bookedDate'].forEach((v) {
        bookedDate!.add(BookedDate.fromJson(v));
      });
    }
    endHiredDate = json['endHiredDate'];
    uniformMandatory = json['uniformMandatory'];
    clientReview = json['clientReview'];
    employeeReview = json['employeeReview'];
    paymentResponse = json['paymentResponse'];
    paymentStatus = json['paymentStatus'];
    totalPlatformFee = (json['totalPlatformFee'] as num?)?.toDouble();
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['_id'] = sId;
    data['employeeId'] = employeeId;
    data['hiredBy'] = hiredBy;
    if (employeeDetails != null) {
      data['employeeDetails'] = employeeDetails!.toJson();
    }
    if (restaurantDetails != null) {
      data['restaurantDetails'] = restaurantDetails!.toJson();
    }
    data['invoiceUrl'] = invoiceUrl;
    if (bookedDate != null) {
      data['bookedDate'] = bookedDate!.map((v) => v.toJson()).toList();
    }
    data['endHiredDate'] = endHiredDate;
    data['uniformMandatory'] = uniformMandatory;
    data['clientReview'] = clientReview;
    data['employeeReview'] = employeeReview;
    data['paymentResponse'] = paymentResponse;
    data['paymentStatus'] = paymentStatus;
    data['totalPlatformFee'] = totalPlatformFee;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;

    return data;
  }
}

class EmployeeDetails {
  String? employeeId;
  String? name;
  String? positionId;
  String? positionName;
  String? presentAddress;
  String? permanentAddress;
  String? employeeExperience;
  String? totalWorkingHour;
  double? hourlyRate;
  double? contractorHourlyRate;
  String? profilePicture;
  String? countryName;
  bool? certified;
  String? sId;
  String? lat;
  String? long;

  EmployeeDetails({
    this.employeeId,
    this.name,
    this.positionId,
    this.positionName,
    this.presentAddress,
    this.permanentAddress,
    this.employeeExperience,
    this.totalWorkingHour,
    this.hourlyRate,
    this.contractorHourlyRate,
    this.profilePicture,
    this.countryName,
    this.certified,
    this.sId,
    this.lat,
    this.long,
  });

  EmployeeDetails.fromJson(Map<String, dynamic> json) {
    employeeId = json['employeeId'];
    name = json['name'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    presentAddress = json['presentAddress'];
    permanentAddress = json['permanentAddress'];
    employeeExperience = json['employeeExperience'];
    totalWorkingHour = json['totalWorkingHour'];
    hourlyRate = (json['hourlyRate'] as num?)?.toDouble() ?? 0.0;
    contractorHourlyRate = (json['contractorHourlyRate'] as num?)?.toDouble() ?? 0.0;
    profilePicture = json['profilePicture'];
    countryName = json['countryName'];
    certified = json['certified'];
    sId = json['_id'];
    lat = json['lat'];
    long = json['long'];
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
    data['totalWorkingHour'] = totalWorkingHour;
    data['hourlyRate'] = hourlyRate;
    data['contractorHourlyRate'] = contractorHourlyRate;
    data['profilePicture'] = profilePicture;
    data['countryName'] = countryName;
    data['certified'] = certified;
    data['_id'] = sId;
    data['lat'] = lat;
    data['long'] = long;
    return data;
  }
}

class RestaurantDetails {
  String? hiredBy;
  String? restaurantName;
  String? restaurantAddress;
  String? lat;
  String? long;
  String? countryName;
  String? profilePicture;
  String? sId;

  RestaurantDetails(
      {this.hiredBy,
      this.restaurantName,
      this.restaurantAddress,
      this.lat,
      this.long,
      this.countryName,
      this.profilePicture,
      this.sId});

  RestaurantDetails.fromJson(Map<String, dynamic> json) {
    hiredBy = json['hiredBy'];
    restaurantName = json['restaurantName'];
    restaurantAddress = json['restaurantAddress'];
    lat = json['lat'];
    long = json['long'];
    countryName = json['countryName'];
    profilePicture = json['profilePicture'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hiredBy'] = hiredBy;
    data['restaurantName'] = restaurantName;
    data['restaurantAddress'] = restaurantAddress;
    data['lat'] = lat;
    data['long'] = long;
    data['countryName'] = countryName;
    data['profilePicture'] = profilePicture;
    data['_id'] = sId;
    return data;
  }
}

class BookedDate {
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  double? perDayPlatformFee;
  double? totalPlatformFee;
  String? totalHours;
  double? amount;

  BookedDate({
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.perDayPlatformFee,
    this.totalPlatformFee,
    this.totalHours,
    this.amount,
  });

  BookedDate.fromJson(Map<String, dynamic> json) {
    startDate = json['startDate'];
    endDate = json['endDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    perDayPlatformFee = (json['perDayPlatformFee'] as num?)?.toDouble();
    totalPlatformFee = (json['totalPlatformFee'] as num?)?.toDouble();
    totalHours = json['totalHours'];
    amount = (json['amount'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['perDayPlatformFee'] = perDayPlatformFee;
    data['totalPlatformFee'] = totalPlatformFee;
    data['totalHours'] = totalHours;
    data['amount'] = amount;
    return data;
  }
}

class CheckInCheckOutHistoryModel {
  CheckInCheckOutHistoryModel({
      this.status, 
      this.statusCode, 
      this.message, 
      this.result,});

  CheckInCheckOutHistoryModel.fromJson(dynamic json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    result = json['result'] != null ? Result.fromJson(json['result']) : null;
  }
  String? status;
  num? statusCode;
  String? message;
  Result? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = status;
    map['statusCode'] = statusCode;
    map['message'] = message;
    if (result != null) {
      map['result'] = result?.toJson();
    }
    return map;
  }

}

class Result {
  Result({
      this.total, 
      this.count, 
      this.next, 
      this.result,});

  Result.fromJson(dynamic json) {
    total = json['total'];
    count = json['count'];
    next = json['next'];
    if (json['result'] != null) {
      result = [];
      json['result'].forEach((v) {
        result?.add(FinalResult.fromJson(v));
      });
    }
  }
  num? total;
  num? count;
  dynamic next;
  List<FinalResult>? result;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total'] = total;
    map['count'] = count;
    map['next'] = next;
    if (result != null) {
      map['result'] = result?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class FinalResult {
  FinalResult({
      this.id, 
      this.employeeId, 
      this.currentHiredEmployeeId, 
      this.hiredBy, 
      this.employeeDetails, 
      this.restaurantDetails, 
      this.checkInCheckOutDetails, 
      this.status, 
      this.employeePaymentStatus, 
      this.invoiceNumber, 
      this.paid, 
      this.employeeAmount, 
      this.clientAmount, 
      this.travelCost, 
      this.hasReview, 
      this.tips, 
      this.workedHour, 
      this.totalAmount, 
      this.convertedTotalAmount, 
      this.convertedHourlyRate, 
      this.convertedClientAmount, 
      this.convertedVatAmount, 
      this.convertedTravelCost, 
      this.convertedTips, 
      this.convertedPlatformFee, 
      this.vat, 
      this.vatAmount, 
      this.platformFee, 
      this.refundAmount, 
      this.invoice, 
      this.createdAt, 
      this.updatedAt, 
      this.v,});

  FinalResult.fromJson(dynamic json) {
    id = json['_id'];
    employeeId = json['employeeId'];
    currentHiredEmployeeId = json['currentHiredEmployeeId'];
    hiredBy = json['hiredBy'];
    employeeDetails = json['employeeDetails'] != null ? EmployeeDetails.fromJson(json['employeeDetails']) : null;
    restaurantDetails = json['restaurantDetails'] != null ? RestaurantDetails.fromJson(json['restaurantDetails']) : null;
    checkInCheckOutDetails = json['checkInCheckOutDetails'] != null ? CheckInCheckOutDetails.fromJson(json['checkInCheckOutDetails']) : null;
    status = json['status'];
    employeePaymentStatus = json['employeePaymentStatus'];
    invoiceNumber = json['invoiceNumber'];
    paid = json['paid'];
    employeeAmount = json['employeeAmount'];
    clientAmount = json['clientAmount'];
    travelCost = json['travel_cost'];
    hasReview = json['hasReview'];
    tips = json['tips'];
    workedHour = json['workedHour'];
    totalAmount = json['totalAmount'];
    convertedTotalAmount = json['convertedTotalAmount'];
    convertedHourlyRate = json['convertedHourlyRate'];
    convertedClientAmount = json['convertedClientAmount'];
    convertedVatAmount = json['convertedVatAmount'];
    convertedTravelCost = json['convertedTravelCost'];
    convertedTips = json['convertedTips'];
    convertedPlatformFee = json['convertedPlatformFee'];
    vat = json['vat'];
    vatAmount = json['vatAmount'];
    platformFee = json['platformFee'];
    refundAmount = json['refundAmount'];
    invoice = json['invoice'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }
  String? id;
  String? employeeId;
  String? currentHiredEmployeeId;
  String? hiredBy;
  EmployeeDetails? employeeDetails;
  RestaurantDetails? restaurantDetails;
  CheckInCheckOutDetails? checkInCheckOutDetails;
  String? status;
  bool? employeePaymentStatus;
  String? invoiceNumber;
  num? paid;
  num? employeeAmount;
  num? clientAmount;
  num? travelCost;
  bool? hasReview;
  num? tips;
  String? workedHour;
  num? totalAmount;
  num? convertedTotalAmount;
  num? convertedHourlyRate;
  num? convertedClientAmount;
  num? convertedVatAmount;
  num? convertedTravelCost;
  num? convertedTips;
  num? convertedPlatformFee;
  num? vat;
  num? vatAmount;
  num? platformFee;
  num? refundAmount;
  String? invoice;
  String? createdAt;
  String? updatedAt;
  num? v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['_id'] = id;
    map['employeeId'] = employeeId;
    map['currentHiredEmployeeId'] = currentHiredEmployeeId;
    map['hiredBy'] = hiredBy;
    if (employeeDetails != null) {
      map['employeeDetails'] = employeeDetails?.toJson();
    }
    if (restaurantDetails != null) {
      map['restaurantDetails'] = restaurantDetails?.toJson();
    }
    if (checkInCheckOutDetails != null) {
      map['checkInCheckOutDetails'] = checkInCheckOutDetails?.toJson();
    }
    map['status'] = status;
    map['employeePaymentStatus'] = employeePaymentStatus;
    map['invoiceNumber'] = invoiceNumber;
    map['paid'] = paid;
    map['employeeAmount'] = employeeAmount;
    map['clientAmount'] = clientAmount;
    map['travel_cost'] = travelCost;
    map['hasReview'] = hasReview;
    map['tips'] = tips;
    map['workedHour'] = workedHour;
    map['totalAmount'] = totalAmount;
    map['convertedTotalAmount'] = convertedTotalAmount;
    map['convertedHourlyRate'] = convertedHourlyRate;
    map['convertedClientAmount'] = convertedClientAmount;
    map['convertedVatAmount'] = convertedVatAmount;
    map['convertedTravelCost'] = convertedTravelCost;
    map['convertedTips'] = convertedTips;
    map['convertedPlatformFee'] = convertedPlatformFee;
    map['vat'] = vat;
    map['vatAmount'] = vatAmount;
    map['platformFee'] = platformFee;
    map['refundAmount'] = refundAmount;
    map['invoice'] = invoice;
    map['createdAt'] = createdAt;
    map['updatedAt'] = updatedAt;
    map['__v'] = v;
    return map;
  }

}

class CheckInCheckOutDetails {
  CheckInCheckOutDetails({
      this.checkInDistance, 
      this.checkOutDistance, 
      this.checkIn, 
      this.checkOut, 
      this.checkInTime, 
      this.checkOutTime, 
      this.breakTime, 
      this.emmergencyCheckIn, 
      this.emmergencyCheckOut, 
      this.clientCheckInTime, 
      this.clientCheckOutTime, 
      this.clientComment, 
      this.clientBreakTime, 
      this.serverAutoCheckOut, 
      this.checkInLat, 
      this.checkInLong, 
      this.checkOutLat, 
      this.checkOutLong, 
      this.id,});

  CheckInCheckOutDetails.fromJson(dynamic json) {
    checkInDistance = json['checkInDistance'];
    checkOutDistance = json['checkOutDistance'];
    checkIn = json['checkIn'];
    checkOut = json['checkOut'];
    checkInTime = json['checkInTime'];
    checkOutTime = json['checkOutTime'];
    breakTime = json['breakTime'];
    emmergencyCheckIn = json['emmergencyCheckIn'];
    emmergencyCheckOut = json['emmergencyCheckOut'];
    clientCheckInTime = json['clientCheckInTime'];
    clientCheckOutTime = json['clientCheckOutTime'];
    clientComment = json['clientComment'];
    clientBreakTime = json['clientBreakTime'];
    serverAutoCheckOut = json['serverAutoCheckOut'];
    checkInLat = json['checkInLat'];
    checkInLong = json['checkInLong'];
    checkOutLat = json['checkOutLat'];
    checkOutLong = json['checkOutLong'];
    id = json['_id'];
  }
  num? checkInDistance;
  num? checkOutDistance;
  bool? checkIn;
  bool? checkOut;
  String? checkInTime;
  String? checkOutTime;
  num? breakTime;
  bool? emmergencyCheckIn;
  bool? emmergencyCheckOut;
  String? clientCheckInTime;
  String? clientCheckOutTime;
  String? clientComment;
  num? clientBreakTime;
  bool? serverAutoCheckOut;
  String? checkInLat;
  String? checkInLong;
  String? checkOutLat;
  String? checkOutLong;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['checkInDistance'] = checkInDistance;
    map['checkOutDistance'] = checkOutDistance;
    map['checkIn'] = checkIn;
    map['checkOut'] = checkOut;
    map['checkInTime'] = checkInTime;
    map['checkOutTime'] = checkOutTime;
    map['breakTime'] = breakTime;
    map['emmergencyCheckIn'] = emmergencyCheckIn;
    map['emmergencyCheckOut'] = emmergencyCheckOut;
    map['clientCheckInTime'] = clientCheckInTime;
    map['clientCheckOutTime'] = clientCheckOutTime;
    map['clientComment'] = clientComment;
    map['clientBreakTime'] = clientBreakTime;
    map['serverAutoCheckOut'] = serverAutoCheckOut;
    map['checkInLat'] = checkInLat;
    map['checkInLong'] = checkInLong;
    map['checkOutLat'] = checkOutLat;
    map['checkOutLong'] = checkOutLong;
    map['_id'] = id;
    return map;
  }

}

class RestaurantDetails {
  RestaurantDetails({
      this.hiredBy, 
      this.restaurantName, 
      this.email, 
      this.restaurantAddress, 
      this.lat, 
      this.long, 
      this.profilePicture, 
      this.countryName, 
      this.id,});

  RestaurantDetails.fromJson(dynamic json) {
    hiredBy = json['hiredBy'];
    restaurantName = json['restaurantName'];
    email = json['email'];
    restaurantAddress = json['restaurantAddress'];
    lat = json['lat'];
    long = json['long'];
    profilePicture = json['profilePicture'];
    countryName = json['countryName'];
    id = json['_id'];
  }
  String? hiredBy;
  String? restaurantName;
  String? email;
  String? restaurantAddress;
  String? lat;
  String? long;
  String? profilePicture;
  String? countryName;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['hiredBy'] = hiredBy;
    map['restaurantName'] = restaurantName;
    map['email'] = email;
    map['restaurantAddress'] = restaurantAddress;
    map['lat'] = lat;
    map['long'] = long;
    map['profilePicture'] = profilePicture;
    map['countryName'] = countryName;
    map['_id'] = id;
    return map;
  }

}

class EmployeeDetails {
  EmployeeDetails({
      this.employeeId, 
      this.name, 
      this.email, 
      this.positionId, 
      this.positionName, 
      this.presentAddress, 
      this.employeeExperience, 
      this.rating, 
      this.totalWorkingHour, 
      this.hourlyRate, 
      this.contractorHourlyRate, 
      this.profilePicture, 
      this.countryName, 
      this.id,});

  EmployeeDetails.fromJson(dynamic json) {
    employeeId = json['employeeId'];
    name = json['name'];
    email = json['email'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    presentAddress = json['presentAddress'];
    employeeExperience = json['employeeExperience'];
    rating = json['rating'];
    totalWorkingHour = json['totalWorkingHour'];
    hourlyRate = json['hourlyRate'];
    contractorHourlyRate = json['contractorHourlyRate'];
    profilePicture = json['profilePicture'];
    countryName = json['countryName'];
    id = json['_id'];
  }
  String? employeeId;
  String? name;
  String? email;
  String? positionId;
  String? positionName;
  String? presentAddress;
  String? employeeExperience;
  num? rating;
  String? totalWorkingHour;
  num? hourlyRate;
  num? contractorHourlyRate;
  String? profilePicture;
  String? countryName;
  String? id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employeeId'] = employeeId;
    map['name'] = name;
    map['email'] = email;
    map['positionId'] = positionId;
    map['positionName'] = positionName;
    map['presentAddress'] = presentAddress;
    map['employeeExperience'] = employeeExperience;
    map['rating'] = rating;
    map['totalWorkingHour'] = totalWorkingHour;
    map['hourlyRate'] = hourlyRate;
    map['contractorHourlyRate'] = contractorHourlyRate;
    map['profilePicture'] = profilePicture;
    map['countryName'] = countryName;
    map['_id'] = id;
    return map;
  }

}
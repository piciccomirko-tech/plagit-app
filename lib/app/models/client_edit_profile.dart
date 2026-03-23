import 'push_notification_details.dart';

class ClientEditProfileModel {
  String? status;
  int? statusCode;
  String? message;

  UserDetails? details;

  ClientEditProfileModel({this.status, this.statusCode, this.message, this.details});

  // Factory method to create an instance from JSON
  factory ClientEditProfileModel.fromJson(Map<String, dynamic> json) {
    return ClientEditProfileModel(
      status: json['status'],
      statusCode: json['statusCode'],
      message: json['message'],
 
      details: json['details'] != null
          ? UserDetails.fromJson(json['details'])
          : null,
    );
  }

  // Method to convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'statusCode': statusCode,
      'message': message,
 
      'details': details?.toJson(),
    };
  }
}

class UserDetails {
  String? sId;
  String? firstName;
  String? lastName;
  String? restaurantName;
  String? restaurantAddress;
  String? name;
  String? positionId;
  String? positionName;
  String? userIdNumber;
  String? email;
  String? phoneNumber;
  String? bankName;
  String? accountNumber;
  String? routingNumber;
  String? additionalOne;
  String? additionalTwo;
  String? dressSize;
  String? countryName;
  String? companyName;
  String? additionalEmailAddress;
  String? emergencyContactNumber;
  bool? employee;
  bool? client;
  bool? admin;
  int? profileCompleted;
  bool? hr;
  bool? marketing;
  String? role;
  bool? isReferPerson;
  bool? isMhEmployee;
  bool? isHired;
  DateTime? hiredFromDate;
  DateTime? hiredToDate;
  String? hiredFromTime;
  String? hiredToTime;
  String? hiredBy;
  String? hiredByLat;
  String? hiredByLong;
  String? hiredByRestaurantName;
  String? hiredByRestaurantAddress;
  String? profilePicture;
  String? cv;
  bool? verified;
  bool? active;
  double? rating;
  String? totalWorkingHour;
  double? hourlyRate;
  double? clientDiscount;
  PushNotificationDetails? pushNotificationDetails;
  double? contractorHourlyRate;
  String? presentAddress;
  String? companyRegisterNumber;
  String? vatNumber;
  String? sourceOfFunds;

  UserDetails({
    this.sId,
    this.firstName,
    this.lastName,
    this.restaurantName,
    this.restaurantAddress,
    this.name,
    this.positionId,
    this.positionName,
    this.userIdNumber,
    this.email,
    this.phoneNumber,
    this.bankName,
    this.accountNumber,
    this.routingNumber,
     this.additionalOne,
    this.additionalTwo,
      this.additionalEmailAddress,
  this.emergencyContactNumber,
    this.dressSize,
    this.countryName,
    this.companyName,
    this.employee,
    this.client,
    this.admin,
    this.hr,
    this.marketing,
    this.role,
    this.isReferPerson,
    this.isMhEmployee,
    this.isHired,
    this.hiredFromDate,
    this.hiredToDate,
    this.hiredFromTime,
    this.hiredToTime,
    this.hiredBy,
    this.hiredByLat,
    this.hiredByLong,
    this.hiredByRestaurantName,
    this.hiredByRestaurantAddress,
    this.profilePicture,
    this.cv,
    this.verified,
    this.active,
    this.rating,
    this.profileCompleted,
    this.totalWorkingHour,
    this.hourlyRate,
    this.clientDiscount,
    this.pushNotificationDetails,
    this.contractorHourlyRate,
    this.presentAddress,
    this.companyRegisterNumber,
    this.vatNumber,
    this.sourceOfFunds,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      sId: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      restaurantName: json['restaurantName'],
      restaurantAddress: json['restaurantAddress'],
      name: json['name'],
      positionId: json['positionId'],
      positionName: json['positionName'],
      userIdNumber: json['userIdNumber'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      bankName: json['bankName'],
      accountNumber: json['accountNumber'],
      routingNumber: json['routingNumber'],
      additionalOne: json['additionalOne'],
      additionalTwo: json['additionalTwo'],
     
      additionalEmailAddress: json['additionalEmailAddress'],
      emergencyContactNumber: json['emergencyContactNumber'],
      dressSize: json['dressSize'],
      countryName: json['countryName'],
      companyName: json['companyName'],
      employee: json['employee'],
      client: json['client'],
      admin: json['admin'],
      hr: json['hr'],
      marketing: json['marketing'],
      role: json['role'],
      isReferPerson: json['isReferPerson'],
      isMhEmployee: json['isMhEmployee'],
      isHired: json['isHired'],
      hiredFromDate: json['hiredFromDate'] != null ? DateTime.parse(json['hiredFromDate']) : null,
      hiredToDate: json['hiredToDate'] != null ? DateTime.parse(json['hiredToDate']) : null,
      hiredFromTime: json['hiredFromTime'],
      hiredToTime: json['hiredToTime'],
      hiredBy: json['hiredBy'],
      hiredByLat: json['hiredByLat'],
      hiredByLong: json['hiredByLong'],
      hiredByRestaurantName: json['hiredByRestaurantName'],
      hiredByRestaurantAddress: json['hiredByRestaurantAddress'],
      profilePicture: json['profilePicture'],
      cv: json['cv'],
      verified: json['verified'],
      active: json['active'],
      profileCompleted: json['profileCompleted'],
      rating: json['rating'] != null ? double.parse(json['rating'].toString()) : 0.0,
      totalWorkingHour: json['totalWorkingHour'].toString(),
      hourlyRate: json['hourlyRate'] != null ? double.parse(json['hourlyRate'].toString()) : 0.0,
      clientDiscount: json['clientDiscount'] != null ? double.parse(json['clientDiscount'].toString()) : 0.0,
      pushNotificationDetails: json['pushNotificationDetails'] != null
          ? PushNotificationDetails.fromJson(json['pushNotificationDetails'])
          : null,
      contractorHourlyRate: json['contractorHourlyRate'] != null
          ? double.parse(json['contractorHourlyRate'].toString())
          : 0.0,
      presentAddress: json['presentAddress'] ?? '',
      companyRegisterNumber: json['companyRegisterNumber'] ?? '',
      vatNumber: json['vatNumber'] ?? '',
      sourceOfFunds: json['sourceOfFunds'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'firstName': firstName,
      'lastName': lastName,
      'restaurantName': restaurantName,
      'restaurantAddress': restaurantAddress,
      'name': name,
      'positionId': positionId,
      'positionName': positionName,
      'userIdNumber': userIdNumber,
      'email': email,
      'phoneNumber': phoneNumber,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'dressSize': dressSize,

      'additionalEmailAddress': additionalEmailAddress,
      'emergencyContactNumber': emergencyContactNumber,
      'countryName': countryName,
      'employee': employee,
      'client': client,
      'admin': admin,
      'hr': hr,
      'marketing': marketing,
      'role': role,
      'isReferPerson': isReferPerson,
      'isMhEmployee': isMhEmployee,
      'isHired': isHired,
      'hiredFromDate': hiredFromDate?.toIso8601String(),
      'hiredToDate': hiredToDate?.toIso8601String(),
      'hiredFromTime': hiredFromTime,
      'hiredToTime': hiredToTime,
      'hiredBy': hiredBy,
      'hiredByLat': hiredByLat,
      'hiredByLong': hiredByLong,
      'hiredByRestaurantName': hiredByRestaurantName,
      'hiredByRestaurantAddress': hiredByRestaurantAddress,
      'profilePicture': profilePicture,
      'cv': cv,
      'verified': verified,
      'active': active,
      'rating': rating,
      'profileCompleted': profileCompleted,
      'totalWorkingHour': totalWorkingHour,
      'hourlyRate': hourlyRate,
      'clientDiscount': clientDiscount,
      'pushNotificationDetails': pushNotificationDetails?.toJson(),
      'contractorHourlyRate': contractorHourlyRate,
      'presentAddress': presentAddress,
      'sourceOfFunds': sourceOfFunds,
    };
  }
}

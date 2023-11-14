import 'push_notification_details.dart';

class UserInfo {
  String? status;
  int? statusCode;
  String? message;
  Details? details;

  UserInfo({this.status, this.statusCode, this.message, this.details});

  UserInfo.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    details =
    json['details'] != null ? Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    return data;
  }
}

class Details {
  String? sId;
  String? firstName;
  String? lastName;
  String? name;
  String? positionId;
  String? positionName;
  String? userIdNumber;
  String? email;
  String? phoneNumber;
  String? bankName;
  String? accountNumber;
  String? routingNumber;
  String? dressSize;
  //List<String>? languages;
 // List<String>? certificates;
  String? countryName;
  bool? employee;
  bool? client;
  bool? admin;
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
  double? totalWorkingHour;
  double? hourlyRate;
  double? clientDiscount;
  PushNotificationDetails? pushNotificationDetails;
 // List<String>? skills;
  double? contractorHourlyRate;
  //List<String>? menuPermission;

  Details(
      {this.sId,
        this.firstName,
        this.lastName,
        this.name,
        this.positionId,
        this.positionName,
        this.userIdNumber,
        this.email,
        this.phoneNumber,
        this.bankName,
        this.accountNumber,
        this.routingNumber,
        this.dressSize,
        //this.languages,
       // this.certificates,
        this.countryName,
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
        this.totalWorkingHour,
        this.hourlyRate,
        this.clientDiscount,
        this.pushNotificationDetails,
       // this.skills,
        this.contractorHourlyRate,
        //this.menuPermission
      });

  Details.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    name = json['name'];
    positionId = json['positionId'];
    positionName = json['positionName'];
    userIdNumber = json['userIdNumber'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    bankName = json['bankName'];
    accountNumber = json['accountNumber'];
    routingNumber = json['routingNumber'];
    dressSize = json['dressSize'];
   /* if (json['languages'] != null) {
      languages = <String>[];
      json['languages'].forEach((v) {
        languages!.add(v);
      });
    }*/
    /*
    if (json['certificates'] != null) {
      certificates = <String>[];
      json['certificates'].forEach((v) {
        certificates!.add(v);
      });
    }*/
    countryName = json['countryName'];
    employee = json['employee'];
    client = json['client'];
    admin = json['admin'];
    hr = json['hr'];
    marketing = json['marketing'];
    role = json['role'];
    isReferPerson = json['isReferPerson'];
    isMhEmployee = json['isMhEmployee'];
    isHired = json['isHired'];
    hiredFromDate = json["hiredFromDate"] == null ? null : DateTime.parse(json["hiredFromDate"]);
    hiredToDate = json["hiredToDate"] == null ? null : DateTime.parse(json["hiredToDate"]);
    hiredFromTime = json['hiredFromTime'];
    hiredToTime = json['hiredToTime'];
    hiredBy = json['hiredBy'];
    hiredByLat = json['hiredByLat'];
    hiredByLong = json['hiredByLong'];
    hiredByRestaurantName = json['hiredByRestaurantName'];
    hiredByRestaurantAddress = json['hiredByRestaurantAddress'];
    profilePicture = json['profilePicture'];
    cv = json['cv'];
    verified = json['verified'];
    active = json['active'];
    rating = json['rating'] == null ? 0.0 : double.parse(json['rating'].toString());
    totalWorkingHour = json['totalWorkingHour'] == null ? 0.0 : double.parse(json['totalWorkingHour'].toString());
    hourlyRate = json['hourlyRate'] == null ? 0.0 : double.parse(json['hourlyRate'].toString());
    clientDiscount = json['clientDiscount'] == null ? 0.0 : double.parse(json['clientDiscount'].toString());
    pushNotificationDetails = json['pushNotificationDetails'] != null
        ? PushNotificationDetails.fromJson(json['pushNotificationDetails'])
        : null;
   /* if (json['skills'] != null) {
      skills = <String>[];
      json['skills'].forEach((v) {
        skills!.add(v);
      });
    }*/
    contractorHourlyRate = json['contractorHourlyRate'] == null ?0.0: double.parse(json['contractorHourlyRate'].toString());
    /*if (json['menuPermission'] != null) {
      menuPermission = <String>[];
      json['menuPermission'].forEach((v) {
        menuPermission!.add(v);
      });
    }*/
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['name'] = name;
    data['positionId'] = positionId;
    data['positionName'] = positionName;
    data['userIdNumber'] = userIdNumber;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['bankName'] = bankName;
    data['accountNumber'] = accountNumber;
    data['routingNumber'] = routingNumber;
    data['dressSize'] = dressSize;
   /* if (languages != null) {
      data['languages'] = languages!.map((v) => v).toList();
    }
    if (certificates != null) {
      data['certificates'] = certificates!.map((v) => v).toList();
    }*/
    data['countryName'] = countryName;
    data['employee'] = employee;
    data['client'] = client;
    data['admin'] = admin;
    data['hr'] = hr;
    data['marketing'] = marketing;
    data['role'] = role;
    data['isReferPerson'] = isReferPerson;
    data['isMhEmployee'] = isMhEmployee;
    data['isHired'] = isHired;
    data['hiredFromDate'] = hiredFromDate?.toIso8601String();
    data['hiredToDate'] = hiredToDate?.toIso8601String();
    data['hiredFromTime'] = hiredFromTime;
    data['hiredToTime'] = hiredToTime;
    data['hiredBy'] = hiredBy;
    data['hiredByLat'] = hiredByLat;
    data['hiredByLong'] = hiredByLong;
    data['hiredByRestaurantName'] = hiredByRestaurantName;
    data['hiredByRestaurantAddress'] = hiredByRestaurantAddress;
    data['profilePicture'] = profilePicture;
    data['cv'] = cv;
    data['verified'] = verified;
    data['active'] = active;
    data['rating'] = rating;
    data['totalWorkingHour'] = totalWorkingHour;
    data['hourlyRate'] = hourlyRate;
    data['clientDiscount'] = clientDiscount;
    if (pushNotificationDetails != null) {
      data['pushNotificationDetails'] = pushNotificationDetails!.toJson();
    }
   /* if (skills != null) {
      data['skills'] = skills!.map((v) => v).toList();
    }*/
    data['contractorHourlyRate'] = contractorHourlyRate;
   /* if (menuPermission != null) {
      data['menuPermission'] =
          menuPermission!.map((v) => v).toList();
    }*/
    return data;
  }
}
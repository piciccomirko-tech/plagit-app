import 'push_notification_details.dart';

class AllAdmins {
  String? status;
  int? statusCode;
  String? message;
  int? total;
  int? count;
  int? next;
  List<Users>? users;

  AllAdmins({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.next,
    this.users,
  });

  AllAdmins.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['statusCode'];
    message = json['message'];
    total = json['total'];
    count = json['count'];
    next = json['next'];
    if (json['users'] != null) {
      users = <Users>[];
      json['users'].forEach((v) {
        users!.add(Users.fromJson(v));
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
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Users {
  String? sId;
  String? name;
  String? userIdNumber;
  String? email;
  String? phoneNumber;
  List<String>? languages;
  String? password;
  String? plainPassword;
  bool? emailVerified;
  bool? phoneNumberVerified;
  bool? employee;
  bool? client;
  bool? admin;
  bool? hr;
  bool? marketing;
  String? role;
  bool? active;
  bool? isReferPerson;
  bool? isMhEmployee;
  bool? isHired;
  bool? verified;
  int? noOfEmployee;
  double? rating;
  double? totalWorkingHour;
  double? hourlyRate;
  int? clientDiscount;
  MenuPermission? menuPermission;
  List<String>? certificates;
  List<String>? skills;
  String? createdAt;
  String? updatedAt;
  int? iV;
  PushNotificationDetails? pushNotificationDetails;
  String? employeeExperience;

  Users({
    this.sId,
    this.name,
    this.userIdNumber,
    this.email,
    this.phoneNumber,
    this.languages,
    this.password,
    this.plainPassword,
    this.emailVerified,
    this.phoneNumberVerified,
    this.employee,
    this.client,
    this.admin,
    this.hr,
    this.marketing,
    this.role,
    this.active,
    this.isReferPerson,
    this.isMhEmployee,
    this.isHired,
    this.verified,
    this.noOfEmployee,
    this.rating,
    this.totalWorkingHour,
    this.hourlyRate,
    this.clientDiscount,
    this.menuPermission,
    this.certificates,
    this.skills,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.pushNotificationDetails,
    this.employeeExperience,
  });

  Users.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    userIdNumber = json['userIdNumber'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    if (json['languages'] != null) {
      languages = <String>[];
      json['languages'].forEach((v) {
        languages!.add(v);
      });
    }
    password = json['password'];
    plainPassword = json['plainPassword'];
    emailVerified = json['emailVerified'];
    phoneNumberVerified = json['phoneNumberVerified'];
    employee = json['employee'];
    client = json['client'];
    admin = json['admin'];
    hr = json['hr'];
    marketing = json['marketing'];
    role = json['role'];
    active = json['active'];
    isReferPerson = json['isReferPerson'];
    isMhEmployee = json['isMhEmployee'];
    isHired = json['isHired'];
    verified = json['verified'];
    noOfEmployee = json['noOfEmployee'];
    rating = json['rating'] == null ? 0.0 : double.parse(json['rating'].toString());
    totalWorkingHour = json['totalWorkingHour'] ==  null ? 0.0 : double.parse(json['totalWorkingHour'].toString());
    hourlyRate = double.parse(json['hourlyRate'].toString());
    clientDiscount = json['clientDiscount'];
    menuPermission = json['menuPermission'] != null
        ? MenuPermission.fromJson(json['menuPermission'])
        : null;
    if (json['certificates'] != null) {
      certificates = <String>[];
      json['certificates'].forEach((v) {
        certificates!.add(v);
      });
    }
    if (json['skills'] != null) {
      skills = <String>[];
      json['skills'].forEach((v) {
        skills!.add(v);
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    pushNotificationDetails = json['pushNotificationDetails'] != null
        ? PushNotificationDetails.fromJson(json['pushNotificationDetails'])
        : null;
    employeeExperience = json['employeeExperience'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['userIdNumber'] = userIdNumber;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    if (languages != null) {
      data['languages'] = languages!.map((v) => v).toList();
    }
    data['password'] = password;
    data['plainPassword'] = plainPassword;
    data['emailVerified'] = emailVerified;
    data['phoneNumberVerified'] = phoneNumberVerified;
    data['employee'] = employee;
    data['client'] = client;
    data['admin'] = admin;
    data['hr'] = hr;
    data['marketing'] = marketing;
    data['role'] = role;
    data['active'] = active;
    data['isReferPerson'] = isReferPerson;
    data['isMhEmployee'] = isMhEmployee;
    data['isHired'] = isHired;
    data['verified'] = verified;
    data['noOfEmployee'] = noOfEmployee;
    data['rating'] = rating;
    data['totalWorkingHour'] = totalWorkingHour;
    data['hourlyRate'] = hourlyRate;
    data['clientDiscount'] = clientDiscount;
    if (menuPermission != null) {
      data['menuPermission'] = menuPermission!.toJson();
    }
    if (certificates != null) {
      data['certificates'] = certificates!.map((v) => v).toList();
    }
    if (skills != null) {
      data['skills'] = skills!.map((v) =>v).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (pushNotificationDetails != null) {
      data['pushNotificationDetails'] = pushNotificationDetails!.toJson();
    }
    data['employeeExperience'] = employeeExperience;
    return data;
  }
}

class MenuPermission {
  bool? position;
  bool? skill;
  bool? source;
  bool? employeeList;
  bool? clientList;
  bool? clientEmployeeList;
  bool? mhEmployeeList;
  bool? addMhEmployee;
  String? sId;

  MenuPermission(
      {this.position,
        this.skill,
        this.source,
        this.employeeList,
        this.clientList,
        this.clientEmployeeList,
        this.mhEmployeeList,
        this.addMhEmployee,
        this.sId});

  MenuPermission.fromJson(Map<String, dynamic> json) {
    position = json['position'];
    skill = json['skill'];
    source = json['source'];
    employeeList = json['employeeList'];
    clientList = json['clientList'];
    clientEmployeeList = json['clientEmployeeList'];
    mhEmployeeList = json['mhEmployeeList'];
    addMhEmployee = json['addMhEmployee'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['position'] = position;
    data['skill'] = skill;
    data['source'] = source;
    data['employeeList'] = employeeList;
    data['clientList'] = clientList;
    data['clientEmployeeList'] = clientEmployeeList;
    data['mhEmployeeList'] = mhEmployeeList;
    data['addMhEmployee'] = addMhEmployee;
    data['_id'] = sId;
    return data;
  }
}
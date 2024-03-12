import 'dart:convert';

import 'package:mh/app/modules/calender/models/calender_model.dart';

import 'push_notification_details.dart';

class Employees {
  Employees({
    this.status,
    this.statusCode,
    this.message,
    this.total,
    this.count,
    this.next,
    this.users,
  });

  final String? status;
  final int? statusCode;
  final String? message;
  final int? total;
  final int? count;
  final int? next;
  final List<Employee>? users;

  factory Employees.fromRawJson(String str) => Employees.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employees.fromJson(Map<String, dynamic> json) => Employees(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        total: json["total"],
        count: json["count"],
        next: json["next"],
        users: json["users"] == null ? [] : List<Employee>.from(json["users"]!.map((x) => Employee.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "total": total,
        "count": count,
        "next": next,
        "users": users == null ? [] : List<dynamic>.from(users!.map((x) => x.toJson())),
      };
}

class Employee {
  Employee(
      {this.id,
      this.firstName,
      this.lastName,
      this.positionId,
      this.positionName,
      this.gender,
      this.dateOfBirth,
      this.userIdNumber,
      this.email,
      this.phoneNumber,
      this.presentAddress,
      this.permanentAddress,
      this.languages,
      this.higherEducation,
      this.licensesNo,
      this.emmergencyContact,
      this.skills,
      this.countryName,
      this.sourceId,
      this.sourceName,
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
      this.employeeExperience,
      this.rating = 0.0,
      this.totalRating = 0,
      this.totalWorkingHour = "00:00",
      this.hourlyRate,
      this.contractorHourlyRate,
      this.certificates,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.cv,
      this.profilePicture,
      this.restaurantName,
      this.restaurantAddress,
      this.clientDiscount,
      this.lat,
      this.long,
      this.vlogs,
      this.pushNotificationDetails,
      this.isSuggested,
      this.available,
      this.unAvailableDateList,
      this.currentOrganisation,
      this.nationality,
      this.height,
      this.weight,
        this.sourceOfFunds,
      this.certified,
      this.dressSize,
      this.hasUniform});

  final String? id;

  final bool? certified;
  final String? firstName;
  final String? lastName;
  final String? positionId;
  final String? positionName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? userIdNumber;
  final String? email;
  final String? sourceOfFunds;
  final String? phoneNumber;
  final String? presentAddress;
  final String? permanentAddress;
  final List<String>? languages;
  final String? higherEducation;
  final String? licensesNo;
  final String? emmergencyContact;
  final List<Skill>? skills;
  final String? countryName;
  final String? sourceId;
  final String? sourceName;
  final bool? emailVerified;
  final bool? phoneNumberVerified;
  final bool? employee;
  final bool? client;
  final bool? admin;
  final bool? hr;
  final bool? marketing;
  final String? role;
  final double? contractorHourlyRate;
  final bool? active;
  final bool? isReferPerson;
  final bool? isMhEmployee;
  final bool? isHired;
  final bool? verified;
  final int? noOfEmployee;
  final dynamic employeeExperience;
  final double? rating;
  final int? totalRating;
  final String? totalWorkingHour;
  final double? hourlyRate;
  final List<dynamic>? certificates;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final String? cv;
  final String? profilePicture;
  final String? restaurantName;
  final String? restaurantAddress;
  final int? clientDiscount;
  final String? lat;
  final String? long;
  final PushNotificationDetails? pushNotificationDetails;
  final bool? isSuggested;
  final List<CalenderDataModel>? unAvailableDateList;
  final String? available;
  final String? currentOrganisation;
  final String? dressSize;
  final String? height;
  final String? weight;
  final String? nationality;
  final bool? hasUniform;
  final List<VlogModel>? vlogs;

  factory Employee.fromRawJson(String str) => Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json["_id"],
        certified: json["certified"],
        available: json["available"],
        unAvailableDateList: json["unavailableDate"] == null
            ? []
            : List<CalenderDataModel>.from(json["unavailableDate"]!.map((x) => CalenderDataModel.fromJson(x))),
        firstName: json["firstName"],
        lastName: json["lastName"],
        positionId: json["positionId"],
    sourceOfFunds: json["sourceOfFunds"],
        positionName: json["positionName"],
        gender: json["gender"],
        dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
        userIdNumber: json["userIdNumber"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        presentAddress: json["presentAddress"],
        permanentAddress: json["permanentAddress"],
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        higherEducation: json["higherEducation"],
        licensesNo: json["licensesNo"],
        emmergencyContact: json["emmergencyContact"],
        skills: json["skills"] == null ? [] : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
        countryName: json["countryName"],
        sourceId: json["sourceId"],
        sourceName: json["sourceName"],
        emailVerified: json["emailVerified"],
        phoneNumberVerified: json["phoneNumberVerified"],
        employee: json["employee"],
        client: json["client"],
        admin: json["admin"],
        hr: json["hr"],
        marketing: json["marketing"],
        role: json["role"],
        active: json["active"],
        isReferPerson: json["isReferPerson"],
        isMhEmployee: json["isMhEmployee"],
        isHired: json["isHired"],
        verified: json["verified"],
        contractorHourlyRate:
            json["contractorHourlyRate"] == null ? 0.0 : double.parse(json["contractorHourlyRate"].toString()),
        noOfEmployee: json["noOfEmployee"],
        employeeExperience: json["employeeExperience"],
        rating: json["rating"] == null ? 0.0 : double.parse(json["rating"].toString()),
        totalRating: json["totalRating"],
        totalWorkingHour: json["totalWorkingHour"].toString(),
        hourlyRate: json["hourlyRate"] == null ? 0.0 : double.parse(json["hourlyRate"].toString()),
        certificates: json["certificates"] == null ? [] : List<dynamic>.from(json["certificates"]!.map((x) => x)),
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        cv: json["cv"],
        profilePicture: json["profilePicture"],
        restaurantName: json["restaurantName"],
        restaurantAddress: json["restaurantAddress"],
        clientDiscount: json["clientDiscount"],
        lat: json["lat"],
        long: json["long"],
        currentOrganisation: json["currentOrganisation"],
        nationality: json["nationality"],
        height: json["height"].toString(),
        weight: json["weight"].toString(),
        dressSize: json["dressSize"],
        hasUniform: json["hasUniform"],
        pushNotificationDetails: json["pushNotificationDetails"] == null
            ? null
            : PushNotificationDetails.fromJson(json["pushNotificationDetails"]),
        isSuggested: json['isSuggested'],
        vlogs: json["vlogs"] == null ? [] : List<VlogModel>.from(json["vlogs"].map((x) => VlogModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "certified": certified,
        "firstName": firstName,
        "lastName": lastName,
        "sourceOfFunds": sourceOfFunds,
        "positionId": positionId,
        "positionName": positionName,
        "gender": gender,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
        "userIdNumber": userIdNumber,
        "email": email,
        "phoneNumber": phoneNumber,
        "presentAddress": presentAddress,
        "permanentAddress": permanentAddress,
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
        "higherEducation": higherEducation,
        "licensesNo": licensesNo,
        "emmergencyContact": emmergencyContact,
        "skills": skills == null ? [] : List<dynamic>.from(skills!.map((x) => x.toJson())),
        "countryName": countryName,
        "sourceId": sourceId,
        "sourceName": sourceName,
        "emailVerified": emailVerified,
        "phoneNumberVerified": phoneNumberVerified,
        "employee": employee,
        "client": client,
        "admin": admin,
        "hr": hr,
        "marketing": marketing,
        "contractorHourlyRate": contractorHourlyRate,
        "role": role,
        "active": active,
        "isReferPerson": isReferPerson,
        "isMhEmployee": isMhEmployee,
        "isHired": isHired,
        "verified": verified,
        "noOfEmployee": noOfEmployee,
        "employeeExperience": employeeExperience,
        "rating": rating,
        "totalRating": totalRating,
        "totalWorkingHour": totalWorkingHour,
        "hourlyRate": hourlyRate,
        "certificates": certificates == null ? [] : List<dynamic>.from(certificates!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "cv": cv,
        "profilePicture": profilePicture,
        "restaurantName": restaurantName,
        "restaurantAddress": restaurantAddress,
        "clientDiscount": clientDiscount,
        "lat": lat,
        "long": long,
        "pushNotificationDetails": pushNotificationDetails?.toJson(),
        "isSuggested": isSuggested,
        "currentOrganisation": currentOrganisation,
        "nationality": nationality,
        "height": height,
        "weight": weight,
        "dressSize": dressSize,
        "hasUniform": hasUniform,
        "vlogs": vlogs == null ? [] : List<dynamic>.from(vlogs!.map((x) => x.toJson())),
      };
}

class Skill {
  Skill({
    this.skillId,
    this.skillName,
    this.id,
  });

  final String? skillId;
  final String? skillName;
  final String? id;

  factory Skill.fromRawJson(String str) => Skill.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        skillId: json["skillId"],
        skillName: json["skillName"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "skillId": skillId,
        "skillName": skillName,
        "_id": id,
      };
}

class VlogModel {
  final String? id;
  final String? title;
  final String? link;
  final String? type;
  final String? user;

  VlogModel({
    this.id,
    this.title,
    this.link,
    this.type,
    this.user
  });

  factory VlogModel.fromRawJson(String str) => VlogModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VlogModel.fromJson(Map<String, dynamic> json) => VlogModel(
        id: json["_id"],
        title: json["title"],
        link: json["link"],
        type: json["type"],
        user: json["user"]
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "link": link,
        "type": type,
        "user": user
      };
}

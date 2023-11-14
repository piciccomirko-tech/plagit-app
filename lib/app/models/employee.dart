import 'dart:convert';

import 'package:mh/app/models/user_info.dart';

class Employee {
  Employee({
    this.id,
    this.name,
    this.email,
    this.userIdNumber,
    this.phoneNumber,
    this.role,
    this.profilePicture,
    this.cv,
    this.verified,
    this.active,
    this.employee,
    this.gender,
    this.dateOfBirth,
    this.presentAddress,
    this.permanentAddress,
    this.higherEducation,
    this.licensesNo,
    this.emmergencyContact,
    this.countryName,
    this.sourceFrom,
    this.employeeExperience,
    this.rating,
    this.totalWorkingHour,
    this.hourlyRate,
    this.isReferPerson,
    this.isHired,
    this.hiredByRestaurantName,
    this.hiredByRestaurantAddress,
    this.hiredFromDate,
    this.hiredToDate,
    this.hiredFromTime,
    this.hiredToTime,
    this.hiredBy,
    this.isMhEmployee,
    this.languages,
    this.clientDiscount,
    this.hiredByLat,
    this.hiredByLong,
    this.iat,
    this.exp,
    this.certified
  });

  final String? id;
  final String? name;
  final String? email;
  final String? userIdNumber;
  final String? phoneNumber;
  final String? role;
  final String? profilePicture;
  final String? cv;
  final bool? verified;
  final bool? active;
  final bool? employee;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? presentAddress;
  final String? permanentAddress;
  final String? higherEducation;
  final String? licensesNo;
  final String? emmergencyContact;
  final String? countryName;
  final String? employeeExperience;
  final double? rating;
  final double? totalWorkingHour;
  final double? hourlyRate;
  final bool? isReferPerson;
  final bool? isHired;
  final DateTime? hiredFromDate;
  final DateTime? hiredToDate;
  final String? hiredFromTime;
  final String? hiredToTime;
  final String? hiredBy;
  final String? hiredByRestaurantName;
  final String? hiredByRestaurantAddress;
  final bool? isMhEmployee;

  final bool? certified;
  final List<String>? languages;
  final double? clientDiscount;
  final String? hiredByLat;
  final String? hiredByLong;
  final int? iat;
  final int? exp;
  final String? sourceFrom;


  factory Employee.fromRawJson(String str) => Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
    id: json["_id"],
    certified: json["certified"],
    name: json["name"],
    email: json["email"],
    userIdNumber: json["userIdNumber"],
    phoneNumber: json["phoneNumber"],
    role: json["role"],
    profilePicture: json["profilePicture"],
    cv: json["cv"],
    verified: json["verified"],
    active: json["active"],
    employee: json["employee"],
    gender: json["gender"],
    dateOfBirth: json["dateOfBirth"] == null ? null : DateTime.parse(json["dateOfBirth"]),
    presentAddress: json["presentAddress"],
    permanentAddress: json["permanentAddress"],
    higherEducation: json["higherEducation"],
    licensesNo: json["licensesNo"],
    emmergencyContact: json["emmergencyContact"],
    countryName: json["countryName"],
    sourceFrom: json["sourceFrom"],
    employeeExperience: json["employeeExperience"].toString(),
    hourlyRate: json["hourlyRate"] == null ? 0.0 : double.parse(json["hourlyRate"].toString()),
    rating: json["rating"] == null ? 0.0 : double.parse(json["rating"].toString()),
    totalWorkingHour: json["totalWorkingHour"] == null ? 0.0 : double.parse(json["totalWorkingHour"].toString()),
    isReferPerson: json["isReferPerson"],
    isHired: json["isHired"],
    hiredFromDate: json["hiredFromDate"] == null ? null : DateTime.parse(json["hiredFromDate"]),
    hiredToDate: json["hiredToDate"] == null ? null : DateTime.parse(json["hiredToDate"]),
    hiredFromTime: json["hiredFromTime"],
    hiredToTime: json["hiredToTime"],
    hiredBy: json["hiredBy"],
    hiredByRestaurantName: json["hiredByRestaurantName"],
    hiredByRestaurantAddress: json["hiredByRestaurantAddress"],
    isMhEmployee: json["isMhEmployee"],
    languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
    clientDiscount: json["clientDiscount"] == null ? 0.0 : double.parse(json['clientDiscount'].toString()),
    hiredByLat: json["hiredByLat"],
    hiredByLong: json["hiredByLong"],
    iat: json["iat"],
    exp: json["exp"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "certified": certified,
    "name": name,
    "email": email,
    "userIdNumber": userIdNumber,
    "phoneNumber": phoneNumber,
    "role": role,
    "profilePicture": profilePicture,
    "cv": cv,
    "verified": verified,
    "active": active,
    "employee": employee,
    "gender": gender,
    "hourlyRate": hourlyRate,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "presentAddress": presentAddress,
    "permanentAddress": permanentAddress,
    "higherEducation": higherEducation,
    "licensesNo": licensesNo,
    "emmergencyContact": emmergencyContact,
    "countryName": countryName,
    "sourceFrom": sourceFrom,
    "employeeExperience": employeeExperience,
    "rating": rating,
    "totalWorkingHour": totalWorkingHour,
    "isReferPerson": isReferPerson,
    "isHired": isHired,
    "hiredByRestaurantName": hiredByRestaurantName,
    "hiredByRestaurantAddress": hiredByRestaurantAddress,
    "hiredFromDate": hiredFromDate?.toIso8601String(),
    "hiredToDate": hiredToDate?.toIso8601String(),
    "hiredBy": hiredBy,
    "hiredFromTime": hiredFromTime,
    "hiredToTime": hiredToTime,
    "isMhEmployee": isMhEmployee,
    "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
    "clientDiscount": clientDiscount,
    "hiredByLat": hiredByLat,
    "hiredByLong": hiredByLong,
    "iat": iat,
    "exp": exp,
  };

  Employee copyWith(UserInfo userInfo) => Employee(
    id: userInfo.details?.sId ?? id,
    name: userInfo.details?.name ?? name,
    email: userInfo.details?.email ?? email,
    userIdNumber: userInfo.details?.userIdNumber ?? userIdNumber,
    phoneNumber: userInfo.details?.phoneNumber ?? phoneNumber,
    role: userInfo.details?.role ?? role,
    profilePicture: userInfo.details?.profilePicture ?? profilePicture,
    cv: userInfo.details?.cv ?? cv,
    verified: userInfo.details?.verified ?? verified,
    active: userInfo.details?.active ?? active,
    employee: userInfo.details?.employee ?? employee,
    gender: gender,
    dateOfBirth: dateOfBirth,
    presentAddress: presentAddress,
    permanentAddress: permanentAddress,
    higherEducation: higherEducation,
    licensesNo: licensesNo,
    emmergencyContact: emmergencyContact,
    countryName: userInfo.details?.countryName ?? countryName,
    sourceFrom: sourceFrom,
    employeeExperience: employeeExperience,
    rating: userInfo.details?.rating ?? rating,
    totalWorkingHour: userInfo.details?.totalWorkingHour ?? totalWorkingHour,
    isReferPerson: userInfo.details?.isReferPerson ?? isReferPerson,
    isHired: userInfo.details?.isHired ?? isHired,
    hiredFromDate: userInfo.details?.hiredFromDate ?? hiredFromDate,
    hiredToDate: userInfo.details?.hiredToDate ?? hiredToDate,
    hiredFromTime: userInfo.details?.hiredFromTime ?? hiredFromTime,
    hiredToTime: userInfo.details?.hiredToTime ?? hiredToTime,
    hiredBy: userInfo.details?.hiredBy ?? hiredBy,
    hiredByRestaurantName: userInfo.details?.hiredByRestaurantName ?? hiredByRestaurantName,
    hiredByRestaurantAddress: userInfo.details?.hiredByRestaurantAddress ?? hiredByRestaurantAddress,
    isMhEmployee: userInfo.details?.isMhEmployee ?? isMhEmployee,
    languages: languages,
    clientDiscount: userInfo.details?.clientDiscount ?? clientDiscount,
    hiredByLat: userInfo.details?.hiredByLat ?? hiredByLat,
    hiredByLong: userInfo.details?.hiredByLong ?? hiredByLong,
    iat: iat,
    exp: exp,
    certified: certified,
  );
}

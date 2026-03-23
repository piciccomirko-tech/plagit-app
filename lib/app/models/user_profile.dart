import '../modules/client/client_subscription_plan/models/client_subscription_plan_details.dart';
import '../modules/common_modules/calender/models/calender_model.dart';
import 'employees_by_id.dart';

class UserProfileModel {
  String? status;
  int? statusCode;
  String? message;

  UserModel? details;

  UserProfileModel({this.status, this.statusCode, this.message, this.details});

  // Factory method to create an instance from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      status: json['status'],
      statusCode: json['statusCode'],
      message: json['message'],
      details:
          json['details'] != null ? UserModel.fromJson(json['details']) : null,
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

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? bio;
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
  String? presentAddress;
  String? permanentAddress;
  String? postCode;
  String? gender;
  DateTime? dateOfBirth;
  List<String>? languages;
  String? higherEducation;
  String? licensesNo;
  List<Skill>? skills;
  String? sourceId;
  String? sourceName;
  bool? emailVerified;
  bool? phoneNumberVerified;
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
  int? noOfEmployee;
  bool? active;
  double? rating;
  int? totalRating;
  int? profileCompleted;
  dynamic employeeExperience;
  String? totalWorkingHour;
  double? hourlyRate;
  double? clientDiscount;
  double? contractorHourlyRate;
  String? companyRegisterNumber;
  String? vatNumber;
  String? sourceOfFunds;
  String? lat;
  String? long;
  bool? certified;
  String? currentOrganisation;
  String? nationality;
  String? height;
  String? weight;
  bool? hasUniform;
  List<dynamic>? certificates;
  List<CalenderDataModel>? unAvailableDateList;
  String? available;
  bool? isSuggested;
  List<VlogModel>? vlogs;
  List<BlockUsersModel>? blockUsers;
  PushNotificationDetails? pushNotificationDetails;
  DateTime? createdAt;
  DateTime? updatedAt;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.bio,
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
    this.dressSize,
    this.countryName,
    this.companyName,
    this.additionalEmailAddress,
    this.emergencyContactNumber,
    this.presentAddress,
    this.permanentAddress,
    this.postCode,
    this.gender,
    this.dateOfBirth,
    this.languages,
    this.higherEducation,
    this.licensesNo,
    this.skills,
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
    this.noOfEmployee,
    this.active,
    this.rating,
    this.totalRating,
    this.profileCompleted,
    this.employeeExperience,
    this.totalWorkingHour,
    this.hourlyRate,
    this.clientDiscount,
    this.contractorHourlyRate,
    this.companyRegisterNumber,
    this.vatNumber,
    this.sourceOfFunds,
    this.lat,
    this.long,
    this.certified,
    this.currentOrganisation,
    this.nationality,
    this.height,
    this.weight,
    this.hasUniform,
    this.certificates,
    this.unAvailableDateList,
    this.available,
    this.isSuggested,
    this.vlogs,
    this.blockUsers,
    this.pushNotificationDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["_id"],
        firstName: json["firstName"] ?? "",
        lastName: json["lastName"] ?? "",
        bio: json["bio"],
        restaurantName: json["restaurantName"],
        restaurantAddress: json["restaurantAddress"],
        name: json["name"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        userIdNumber: json["userIdNumber"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        bankName: json["bankName"],
        accountNumber: json["accountNumber"],
        routingNumber: json["routingNumber"],
        additionalOne: json["additionalOne"],
        additionalTwo: json["additionalTwo"],
        dressSize: json["dressSize"],
        countryName: json["countryName"],
        companyName: json["companyName"],
        additionalEmailAddress: json["additionalEmailAddress"],
        emergencyContactNumber: json["emergencyContactNumber"],
        presentAddress: json["presentAddress"],
        permanentAddress: json["permanentAddress"],
        postCode: json["postCode"],
        gender: json["gender"],
        dateOfBirth: json["dateOfBirth"] == null
            ? null
            : DateTime.parse(json["dateOfBirth"]),
        languages: json["languages"] == null
            ? []
            : List<String>.from(json["languages"]!.map((x) => x)),
        higherEducation: json["higherEducation"],
        licensesNo: json["licensesNo"],
        skills: json["skills"] == null
            ? []
            : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
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
        isReferPerson: json["isReferPerson"],
        isMhEmployee: json["isMhEmployee"],
        isHired: json["isHired"],
        hiredFromDate: json["hiredFromDate"] == null
            ? null
            : DateTime.parse(json["hiredFromDate"]),
        hiredToDate: json["hiredToDate"] == null
            ? null
            : DateTime.parse(json["hiredToDate"]),
        hiredFromTime: json["hiredFromTime"],
        hiredToTime: json["hiredToTime"],
        hiredBy: json["hiredBy"],
        hiredByLat: json["hiredByLat"],
        hiredByLong: json["hiredByLong"],
        hiredByRestaurantName: json["hiredByRestaurantName"],
        hiredByRestaurantAddress: json["hiredByRestaurantAddress"],
        profilePicture: json["profilePicture"]?.toString() == "undefined"
            ? ""
            : json["profilePicture"],
        cv: json["cv"],
        verified: json["verified"],
        noOfEmployee: json["noOfEmployee"],
        active: json["active"],
        rating: json["rating"] == null
            ? 0.0
            : double.parse(json["rating"].toString()),
        totalRating: json["totalRating"],
        profileCompleted: json["profileCompleted"],
        employeeExperience: json["employeeExperience"],
        totalWorkingHour: json["totalWorkingHour"]?.toString(),
        hourlyRate: json["hourlyRate"] == null
            ? 0.0
            : double.parse(json["hourlyRate"].toString()),
        clientDiscount: json["clientDiscount"] == null
            ? 0.0
            : double.parse(json["clientDiscount"].toString()),
        contractorHourlyRate: json["contractorHourlyRate"] == null
            ? 0.0
            : double.parse(json["contractorHourlyRate"].toString()),
        companyRegisterNumber: json["companyRegisterNumber"],
        vatNumber: json["vatNumber"],
        sourceOfFunds: json["sourceOfFunds"],
        lat: json["lat"],
        long: json["long"],
        certified: json["certified"],
        currentOrganisation: json["currentOrganisation"],
        nationality: json["nationality"],
        height: json["height"]?.toString(),
        weight: json["weight"]?.toString(),
        hasUniform: json["hasUniform"],
        certificates: json["certificates"],
        unAvailableDateList: json["unavailableDate"] == null
            ? []
            : List<CalenderDataModel>.from(json["unavailableDate"]!
                .map((x) => CalenderDataModel.fromJson(x))),
        available: json["available"],
        isSuggested: json["isSuggested"],
        vlogs: json["vlogs"] == null
            ? []
            : List<VlogModel>.from(
                json["vlogs"].map((x) => VlogModel.fromJson(x))),
        blockUsers: json["blockUsers"] == null
            ? []
            : (json["blockUsers"] as List).isNotEmpty &&
                    json["blockUsers"][0] is Map<String, dynamic>
                ? List<BlockUsersModel>.from(
                    json["blockUsers"].map((x) => BlockUsersModel.fromJson(x)))
                : [],
        pushNotificationDetails: json["pushNotificationDetails"] == null
            ? null
            : PushNotificationDetails.fromJson(json["pushNotificationDetails"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "restaurantName": restaurantName,
        "restaurantAddress": restaurantAddress,
        "name": name,
        "positionId": positionId,
        "positionName": positionName,
        "userIdNumber": userIdNumber,
        "email": email,
        "phoneNumber": phoneNumber,
        "bankName": bankName,
        "accountNumber": accountNumber,
        "routingNumber": routingNumber,
        "additionalOne": additionalOne,
        "additionalTwo": additionalTwo,
        "dressSize": dressSize,
        "countryName": countryName,
        "companyName": companyName,
        "additionalEmailAddress": additionalEmailAddress,
        "emergencyContactNumber": emergencyContactNumber,
        "presentAddress": presentAddress,
        "permanentAddress": permanentAddress,
        "postCode": postCode,
        "gender": gender,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
        "languages": languages,
        "higherEducation": higherEducation,
        "licensesNo": licensesNo,
        "skills": skills?.map((x) => x.toJson()).toList(),
        "sourceId": sourceId,
        "sourceName": sourceName,
        "emailVerified": emailVerified,
        "phoneNumberVerified": phoneNumberVerified,
        "employee": employee,
        "client": client,
        "admin": admin,
        "hr": hr,
        "marketing": marketing,
        "role": role,
        "isReferPerson": isReferPerson,
        "isMhEmployee": isMhEmployee,
        "isHired": isHired,
        "hiredFromDate": hiredFromDate?.toIso8601String(),
        "hiredToDate": hiredToDate?.toIso8601String(),
        "hiredFromTime": hiredFromTime,
        "hiredToTime": hiredToTime,
        "hiredBy": hiredBy,
        "hiredByLat": hiredByLat,
        "hiredByLong": hiredByLong,
        "hiredByRestaurantName": hiredByRestaurantName,
        "hiredByRestaurantAddress": hiredByRestaurantAddress,
        "profilePicture": profilePicture,
        "cv": cv,
        "verified": verified,
        "noOfEmployee": noOfEmployee,
        "active": active,
        "rating": rating,
        "totalRating": totalRating,
        "profileCompleted": profileCompleted,
        "employeeExperience": employeeExperience,
        "totalWorkingHour": totalWorkingHour,
        "hourlyRate": hourlyRate,
        "clientDiscount": clientDiscount,
        "contractorHourlyRate": contractorHourlyRate,
        "companyRegisterNumber": companyRegisterNumber,
        "vatNumber": vatNumber,
        "sourceOfFunds": sourceOfFunds,
        "lat": lat,
        "long": long,
        "certified": certified,
        "currentOrganisation": currentOrganisation,
        "nationality": nationality,
        "height": height,
        "weight": weight,
        "hasUniform": hasUniform,
        "certificates": certificates,
        // "unavailableDate": unAvailableDateList?.map((x) => x.toJson()).toList(),
        "available": available,
        "isSuggested": isSuggested,
        "vlogs": vlogs?.map((x) => x.toJson()).toList(),
        "blockUsers": blockUsers?.map((x) => x.toJson()).toList(),
        "pushNotificationDetails": pushNotificationDetails?.toJson(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

import 'dart:convert';

class Admin {
  Admin({
    this.id,
    this.name,
    this.countryName,
    this.email,
    this.userIdNumber,
    this.phoneNumber,
    this.role,
    this.verified,
    this.active,
    this.employee,
    this.client,
    this.admin,
    this.hr,
    this.employeeExperience,
    this.rating,
    this.totalWorkingHour,
    this.isReferPerson,
    this.isHired,
    this.menuPermission,
    this.isMhEmployee,
    this.languages,
    this.clientDiscount,
    this.iat,
    this.exp,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? countryName;
  final String? userIdNumber;
  final String? phoneNumber;
  final String? role;
  final bool? verified;
  final bool? active;
  final bool? employee;
  final bool? client;
  final bool? admin;
  final bool? hr;
  final String? employeeExperience;
  final double? rating;
  final double? totalWorkingHour;
  final bool? isReferPerson;
  final bool? isHired;
  final MenuPermission? menuPermission;
  final bool? isMhEmployee;
  final List<dynamic>? languages;
  final int? clientDiscount;
  final int? iat;
  final int? exp;

  factory Admin.fromRawJson(String str) => Admin.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Admin.fromJson(Map<String, dynamic> json) => Admin(
        id: json["_id"],
        name: json["name"],
        email: json["email"],
        countryName: json["countryName"],
        userIdNumber: json["userIdNumber"],
        phoneNumber: json["phoneNumber"],
        role: json["role"],
        verified: json["verified"],
        active: json["active"],
        employee: json["employee"],
        client: json["client"],
        admin: json["admin"],
        hr: json["hr"],
        employeeExperience: json["employeeExperience"],
        rating: json["rating"] == null ? 0.0 : double.parse(json["rating"].toString()),
        totalWorkingHour: json["totalWorkingHour"] == null ? 0.0 : double.parse(json["totalWorkingHour"].toString()),
        isReferPerson: json["isReferPerson"],
        isHired: json["isHired"],
        menuPermission: json["menuPermission"] == null ? null : MenuPermission.fromJson(json["menuPermission"]),
        isMhEmployee: json["isMhEmployee"],
        languages: json["languages"] == null ? [] : List<dynamic>.from(json["languages"]!.map((x) => x)),
        clientDiscount: json["clientDiscount"],
        iat: json["iat"],
        exp: json["exp"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "email": email,
        "userIdNumber": userIdNumber,
        "countryName": countryName,
        "phoneNumber": phoneNumber,
        "role": role,
        "verified": verified,
        "active": active,
        "employee": employee,
        "client": client,
        "admin": admin,
        "hr": hr,
        "employeeExperience": employeeExperience,
        "rating": rating,
        "totalWorkingHour": totalWorkingHour,
        "isReferPerson": isReferPerson,
        "isHired": isHired,
        "menuPermission": menuPermission?.toJson(),
        "isMhEmployee": isMhEmployee,
        "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
        "clientDiscount": clientDiscount,
        "iat": iat,
        "exp": exp,
      };
}

class MenuPermission {
  MenuPermission({
    this.position,
    this.skill,
    this.source,
    this.employeeList,
    this.clientList,
    this.clientEmployeeList,
    this.mhEmployeeList,
    this.addMhEmployee,
    this.id,
  });

  final bool? position;
  final bool? skill;
  final bool? source;
  final bool? employeeList;
  final bool? clientList;
  final bool? clientEmployeeList;
  final bool? mhEmployeeList;
  final bool? addMhEmployee;
  final String? id;

  factory MenuPermission.fromRawJson(String str) => MenuPermission.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory MenuPermission.fromJson(Map<String, dynamic> json) => MenuPermission(
        position: json["position"],
        skill: json["skill"],
        source: json["source"],
        employeeList: json["employeeList"],
        clientList: json["clientList"],
        clientEmployeeList: json["clientEmployeeList"],
        mhEmployeeList: json["mhEmployeeList"],
        addMhEmployee: json["addMhEmployee"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "position": position,
        "skill": skill,
        "source": source,
        "employeeList": employeeList,
        "clientList": clientList,
        "clientEmployeeList": clientEmployeeList,
        "mhEmployeeList": mhEmployeeList,
        "addMhEmployee": addMhEmployee,
        "_id": id,
      };
}

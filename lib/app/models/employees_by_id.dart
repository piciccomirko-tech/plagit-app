import 'dart:async';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/modules/common_modules/calender/models/calender_model.dart';

import 'push_notification_details.dart' show PushNotificationDetails;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui' as ui;

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

  factory Employees.fromRawJson(String str) =>
      Employees.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employees.fromJson(Map<String, dynamic> json) => Employees(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        total: json["total"],
        count: json["count"],
        next: json["next"],
        users: json["users"] == null
            ? []
            : List<Employee>.from(
                json["users"]!.map((x) => Employee.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "statusCode": statusCode,
        "message": message,
        "total": total,
        "count": count,
        "next": next,
        "users": users == null
            ? []
            : List<dynamic>.from(users!.map((x) => x.toJson())),
      };
}

class Employee {
  Employee({
    this.id,
    this.firstName,
    this.bio,
    this.lastName,
    this.positionId,
    this.positionName,
    this.gender,
    this.dateOfBirth,
    this.userIdNumber,
    this.email,
    this.phoneNumber,
    this.postCode,
    this.presentAddress,
    this.permanentAddress,
    this.languages,
    this.higherEducation,
    this.licensesNo,
    this.emergencyContact,
    this.skills,
    this.countryName,
    this.bankName,
    this.accountNumber,
    this.routingNumber,
    this.additionalOne,
    this.additionalTwo,
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
    this.profileCompleted,
    this.hasUniform,
    this.blockUsers,
    this.markerIcon,
  });

  final String? id;

  final bool? certified;
  final String? firstName;
  final String? bio;
  final String? lastName;
  final String? positionId;
  final String? bankName;
  final String? accountNumber;
  final String? routingNumber;
  final String? additionalOne;
  final String? additionalTwo;
  final String? positionName;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? userIdNumber;
  final String? email;
  final String? sourceOfFunds;
  final String? phoneNumber;
  final String? postCode;
  final String? presentAddress;
  final String? permanentAddress;
  final List<String>? languages;
  final String? higherEducation;
  final String? licensesNo;
  final String? emergencyContact;
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
  final int? profileCompleted;
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
  final List<BlockUsersModel>? blockUsers;

  BitmapDescriptor? markerIcon;

  factory Employee.fromRawJson(String str) =>
      Employee.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json["_id"],
        certified: json["certified"],
        available: json["available"],
        unAvailableDateList: json["unavailableDate"] == null
            ? []
            : List<CalenderDataModel>.from(json["unavailableDate"]!
                .map((x) => CalenderDataModel.fromJson(x))),
        firstName: json["firstName"]??"",
        bio: json["bio"],
        lastName: json["lastName"]??"",
        positionId: json["positionId"],
        sourceOfFunds: json["sourceOfFunds"],
        positionName: json["positionName"],
        bankName: json["bankName"],
        accountNumber: json["accountNumber"],
        routingNumber: json["routingNumber"],
        additionalTwo: json["additionalTwo"],
        gender: json["gender"],
        dateOfBirth: json["dateOfBirth"] == null
            ? null
            : DateTime.parse(json["dateOfBirth"]),
        userIdNumber: json["userIdNumber"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        postCode: json["postCode"],
        profileCompleted: json["profileCompleted"],
        presentAddress: json["presentAddress"],
        permanentAddress: json["permanentAddress"],
        languages: json["languages"] == null
            ? []
            : List<String>.from(json["languages"]!.map((x) => x)),
        higherEducation: json["higherEducation"],
        licensesNo: json["licensesNo"],
        emergencyContact: json["emergencyContact"],
        skills: json["skills"] == null
            ? []
            : List<Skill>.from(json["skills"]!.map((x) => Skill.fromJson(x))),
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
        contractorHourlyRate: json["contractorHourlyRate"] == null
            ? 0.0
            : double.parse(json["contractorHourlyRate"].toString()),
        noOfEmployee: json["noOfEmployee"],
        employeeExperience: json["employeeExperience"],
        rating: json["rating"] == null
            ? 0.0
            : double.parse(json["rating"].toString()),
        totalRating: json["totalRating"],
        totalWorkingHour: json["totalWorkingHour"].toString(),
        hourlyRate: json["hourlyRate"] == null
            ? 0.0
            : double.parse(json["hourlyRate"].toString()),
        certificates: json["certificates"] == null
            ? []
            : List<dynamic>.from(json["certificates"]!.map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        cv: json["cv"],
        profilePicture: json["profilePicture"].toString() == "undefined"
            ? ""
            : json["profilePicture"],
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
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "certified": certified,
        "firstName": firstName,
        "bio": bio,
        "lastName": lastName,
        "sourceOfFunds": sourceOfFunds,
        "positionId": positionId,
        "positionName": positionName,
        "bankName": bankName,
        "accountNumber": accountNumber,
        "routingNumber": routingNumber,
        "additionalOne": additionalOne,
        "additionalTwo": additionalTwo,
        "gender": gender,
        "dateOfBirth": dateOfBirth?.toIso8601String(),
        "userIdNumber": userIdNumber,
        "email": email,
        "phoneNumber": phoneNumber,
        "postCode": postCode,
        "profileCompleted": profileCompleted,
        "presentAddress": presentAddress,
        "permanentAddress": permanentAddress,
        "languages": languages == null
            ? []
            : List<dynamic>.from(languages!.map((x) => x)),
        "higherEducation": higherEducation,
        "licensesNo": licensesNo,
        "emergencyContact": emergencyContact,
        "skills": skills == null
            ? []
            : List<dynamic>.from(skills!.map((x) => x.toJson())),
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
        "certificates": certificates == null
            ? []
            : List<dynamic>.from(certificates!.map((x) => x)),
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
        "vlogs": vlogs == null
            ? []
            : List<dynamic>.from(vlogs!.map((x) => x.toJson())),
      };

  Future<void> loadMarkerIcon() async {
    markerIcon = await _createCustomMarkerFromUrl(profilePicture ?? "");
  }

  Future<BitmapDescriptor> _createCustomMarkerFromUrl(String imageUrl) async {
    try {
      // Use CachedNetworkImageProvider to load and cache the image
      final imageProvider = CachedNetworkImageProvider(imageUrl.imageUrl);

      // Obtain the image stream
      final imageStream = imageProvider.resolve(ImageConfiguration());

      // Wait until the image is loaded
      final completer = Completer<ui.Image>();
      imageStream.addListener(
          ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
        completer.complete(imageInfo.image); // Extract ui.Image from ImageInfo
      }));

      final image = await completer.future; // This will be the ui.Image

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(120, 180);
      const circleRadius = 35.0;
      final centerX = size.width / 2;
      const centerY = 50.0;
      const tailHeight = 30.0;
      const tailWidth = 25.0;
      const tailY = centerY + circleRadius;

      // Draw marker background
      final markerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(centerX, centerY), circleRadius, markerPaint);

      // Draw border
      final borderPaint = Paint()
        ..color = const Color(0xFF4FD2C2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10;
      canvas.drawCircle(Offset(centerX, centerY), circleRadius, borderPaint);

      // Draw pointer tail
      final tailPath = Path()
        ..moveTo(centerX - tailWidth / 2, tailY)
        ..lineTo(centerX, tailY + tailHeight)
        ..lineTo(centerX + tailWidth / 2, tailY)
        ..close();
      final tailPaint = Paint()
        ..color = const Color(0xFF4FD2C2)
        ..style = PaintingStyle.fill;
      canvas.drawPath(tailPath, tailPaint);

      // Draw profile image
      final clipPath = Path()
        ..addOval(Rect.fromCircle(
            center: Offset(centerX, centerY), radius: circleRadius));
      canvas.clipPath(clipPath);
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCircle(center: Offset(centerX, centerY), radius: circleRadius),
        Paint(),
      );

      final picture = recorder.endRecording();
      final img =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final data = await img.toByteData(format: ui.ImageByteFormat.png);

      if (data == null) throw Exception('Failed to create marker image');
      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }
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

  VlogModel({this.id, this.title, this.link, this.type, this.user});

  factory VlogModel.fromRawJson(String str) =>
      VlogModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VlogModel.fromJson(Map<String, dynamic> json) => VlogModel(
      id: json["_id"],
      title: json["title"],
      link: json["link"],
      type: json["type"],
      user: json["user"]);

  Map<String, dynamic> toJson() =>
      {"_id": id, "title": title, "link": link, "type": type, "user": user};
}

class BlockUsersModel {
  final String? id;
  final String? email;
  final String? name;
  final String? restaurantName;
  final String? positionName;
  final String? role;
  final String? profilePicture;
  final String? countryName;

  BlockUsersModel(
      {this.id,
      this.email,
      this.name,
      this.restaurantName,
      this.positionName,
      this.role,
      this.profilePicture,
      this.countryName});

  factory BlockUsersModel.fromRawJson(String str) =>
      BlockUsersModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BlockUsersModel.fromJson(Map<String, dynamic> json) =>
      BlockUsersModel(
          id: json["_id"],
          email: json["email"],
          name: json["name"],
          restaurantName: json["restaurantName"],
          positionName: json["positionName"],
          role: json["role"],
          profilePicture: json["profilePicture"],
          countryName: json["countryName"]);

  Map<String, dynamic> toJson() => {
        "_id": id,
        "email": email,
        "name": name,
        "restaurantName": restaurantName,
        "positionName": positionName,
        "role": role,
        "profilePicture": profilePicture,
        "countryName": countryName
      };
}

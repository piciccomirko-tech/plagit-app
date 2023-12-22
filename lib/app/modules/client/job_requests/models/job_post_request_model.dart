import 'dart:convert';

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class JobPostRequestModel {
  final String? status;
  final int? statusCode;
  final List<Job>? jobs;

  JobPostRequestModel({
    this.status,
    this.statusCode,
    this.jobs,
  });

  factory JobPostRequestModel.fromRawJson(String str) => JobPostRequestModel.fromJson(json.decode(str));

  factory JobPostRequestModel.fromJson(Map<String, dynamic> json) => JobPostRequestModel(
        status: json["status"],
        statusCode: json["statusCode"],
        jobs: json["jobs"] == null ? [] : List<Job>.from(json["jobs"]!.map((x) => Job.fromJson(x))),
      );
}

class Job {
  final String? id;
  final PositionId? positionId;
  final ClientId? clientId;
  final double? minRatePerHour;
  final double? maxRatePerHour;
  final int? vacancy;
  final List<RequestDateModel>? dates;
  final List<String>? nationalities;
  final List<String>? skills;
  final int? minExperience;
  final int? maxExperience;
  final int? minAge;
  final int? maxAge;
  final List<String>? languages;
  final String? description;
  final String? country;
  final List<User>? users;
  final DateTime? publishedDate;
  final DateTime? endDate;
  final bool? isAutoPublish;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Job({
    this.id,
    this.positionId,
    this.clientId,
    this.minRatePerHour,
    this.maxRatePerHour,
    this.vacancy,
    this.dates,
    this.nationalities,
    this.skills,
    this.minExperience,
    this.maxExperience,
    this.minAge,
    this.maxAge,
    this.languages,
    this.description,
    this.country,
    this.users,
    this.publishedDate,
    this.endDate,
    this.isAutoPublish,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Job.fromRawJson(String str) => Job.fromJson(json.decode(str));

  factory Job.fromJson(Map<String, dynamic> json) => Job(
        id: json["_id"],
        positionId: json["positionId"] == null ? null : PositionId.fromJson(json["positionId"]),
        clientId: json["clientId"] == null ? null : ClientId.fromJson(json["clientId"]),
        minRatePerHour: json["minRatePerHour"] == null ? 0.0 : double.parse(json["minRatePerHour"].toString()),
        maxRatePerHour: json["maxRatePerHour"] == null ? 0.0 : double.parse(json["maxRatePerHour"].toString()),
        vacancy: json["vacancy"],
        dates: json["dates"] == null
            ? []
            : List<RequestDateModel>.from(json["dates"]!.map((x) => RequestDateModel.fromJson(x))),
        nationalities: json["nationalities"] == null ? [] : List<String>.from(json["nationalities"]!.map((x) => x)),
        skills: json["skills"] == null ? [] : List<String>.from(json["skills"]!.map((x) => x)),
        minExperience: json["minExperience"],
        maxExperience: json["maxExperience"],
        minAge: json["minAge"],
        maxAge: json["maxAge"],
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        description: json["description"],
        country: json["country"],
        users: json["users"] == null ? [] : List<User>.from(json["users"]!.map((x) => User.fromJson(x))),
        publishedDate: json["publishedDate"] == null ? null : DateTime.parse(json["publishedDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        isAutoPublish: json["isAutoPublish"],
        status: json["status"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );
}

class ClientId {
  final String? id;
  final String? email;
  final String? phoneNumber;
  final String? countryName;
  final String? restaurantName;
  final String? restaurantAddress;
  final String? lat;
  final String? long;

  ClientId({
    this.id,
    this.email,
    this.phoneNumber,
    this.countryName,
    this.restaurantName,
    this.restaurantAddress,
    this.lat,
    this.long,
  });

  factory ClientId.fromRawJson(String str) => ClientId.fromJson(json.decode(str));

  factory ClientId.fromJson(Map<String, dynamic> json) => ClientId(
        id: json["_id"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        countryName: json["countryName"],
        restaurantName: json["restaurantName"],
        restaurantAddress: json["restaurantAddress"],
        lat: json["lat"],
        long: json["long"],
      );
}

class PositionId {
  final String? id;
  final String? name;
  final List<String>? images;
  final String? logo;

  PositionId({
    this.id,
    this.name,
    this.images,
    this.logo,
  });

  factory PositionId.fromRawJson(String str) => PositionId.fromJson(json.decode(str));

  factory PositionId.fromJson(Map<String, dynamic> json) => PositionId(
        id: json["_id"],
        name: json["name"],
        images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
        logo: json["logo"],
      );
}

class User {
  final String? id;
  final String? name;
  final String? positionId;
  final String? positionName;
  final String? email;
  final String? phoneNumber;
  final List<String>? languages;
  final String? countryName;
  final bool? verified;
  final double? rating;
  final String? totalWorkingHour;
  final double? hourlyRate;
  final double? contractorHourlyRate;
  final String? employeeExperience;
  final String? nationality;
  final String? profilePicture;
  final int? totalRating;

  User({
    this.id,
    this.name,
    this.positionId,
    this.positionName,
    this.email,
    this.phoneNumber,
    this.languages,
    this.countryName,
    this.verified,
    this.rating,
    this.totalWorkingHour,
    this.hourlyRate,
    this.contractorHourlyRate,
    this.employeeExperience,
    this.nationality,
    this.profilePicture,
    this.totalRating,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        name: json["name"],
        positionId: json["positionId"],
        positionName: json["positionName"],
        email: json["email"],
        phoneNumber: json["phoneNumber"],
        languages: json["languages"] == null ? [] : List<String>.from(json["languages"]!.map((x) => x)),
        countryName: json["countryName"],
        verified: json["verified"],
        rating: json["rating"] == null ? 0.0 : double.parse(json["rating"].toString()),
        totalWorkingHour: json["totalWorkingHour"],
        hourlyRate: json["hourlyRate"] == null ? 0.0 : double.parse(json["hourlyRate"].toString()),
        contractorHourlyRate:
            json["contractorHourlyRate"] == null ? 0.0 : double.parse(json["contractorHourlyRate"].toString()),
        employeeExperience: json["employeeExperience"],
        nationality: json["nationality"],
        profilePicture: json["profilePicture"],
        totalRating: json["totalRating"],
      );
}

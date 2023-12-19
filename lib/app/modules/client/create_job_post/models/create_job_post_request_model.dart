import 'dart:convert';

class CreateJobPostRequestModel {
  final String? positionId;
  final String? clientId;
  final int? minRatePerHour;
  final int? maxRatePerHour;
  final int? vacancy;
  final List<Date>? dates;
  final List<String>? nationalities;
  final List<String>? skills;
  final int? minExperience;
  final int? maxExperience;
  final List<String>? languages;
  final String? description;
  final DateTime? publishedDate;
  final DateTime? endDate;
  final int? minAge;
  final int? maxAge;

  CreateJobPostRequestModel({
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
    this.languages,
    this.description,
    this.publishedDate,
    this.endDate,
    this.minAge,
    this.maxAge,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "positionId": positionId,
    "clientId": clientId,
    "minRatePerHour": minRatePerHour,
    "maxRatePerHour": maxRatePerHour,
    "vacancy": vacancy,
    "dates": dates == null ? [] : List<dynamic>.from(dates!.map((x) => x.toJson())),
    "nationalities": nationalities == null ? [] : List<dynamic>.from(nationalities!.map((x) => x)),
    "skills": skills == null ? [] : List<dynamic>.from(skills!.map((x) => x)),
    "minExperience": minExperience,
    "maxExperience": maxExperience,
    "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x)),
    "description": description,
    "publishedDate": "${publishedDate!.year.toString().padLeft(4, '0')}-${publishedDate!.month.toString().padLeft(2, '0')}-${publishedDate!.day.toString().padLeft(2, '0')}",
    "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "minAge": minAge,
    "maxAge": maxAge,
  };
}

class Date {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startTime;
  final String? endTime;

  Date({
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "startTime": startTime,
    "endTime": endTime,
  };
}

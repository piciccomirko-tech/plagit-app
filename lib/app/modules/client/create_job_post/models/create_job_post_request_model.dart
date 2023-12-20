import 'dart:convert';

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class CreateJobPostRequestModel {
  String? positionId;
  String? clientId;
  double? minRatePerHour;
  double? maxRatePerHour;
  int? vacancy;
  List<RequestDateModel>? dates;
  List<String>? nationalities;
  List<String>? skills;
  int? minExperience;
  int? maxExperience;
  List<String>? languages;
  String? description;
  DateTime? publishedDate;
  DateTime? endDate;
  int? minAge;
  int? maxAge;

  CreateJobPostRequestModel({
    this.positionId,
    this.clientId,
    this.minRatePerHour = 5.0,
    this.maxRatePerHour = 10.0,
    this.vacancy,
    this.dates,
    this.nationalities,
    this.skills,
    this.minExperience = 0,
    this.maxExperience = 20,
    this.languages,
    this.description,
    this.publishedDate,
    this.endDate,
    this.minAge = 18,
    this.maxAge = 60,
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
        "publishedDate":
            "${publishedDate!.year.toString().padLeft(4, '0')}-${publishedDate!.month.toString().padLeft(2, '0')}-${publishedDate!.day.toString().padLeft(2, '0')}",
        "endDate":
            "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "minAge": minAge,
        "maxAge": maxAge,
      };
}

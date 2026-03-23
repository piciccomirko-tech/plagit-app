import 'dart:convert';

import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class CreateJobPostRequestModel {
  String? id;
  String? positionId;
  String? clientId;
  String? minRatePerHour;
  String? maxRatePerHour;
  int? vacancy;
  List<RequestDateModel>? dates;
  List<String>? nationalities;
  List<String>? skills;
  String? minExperience;
  String? maxExperience;
  String? salary;
  String? age;
  String? experience;
  List<String>? languages;
  String? description;
  DateTime? publishedDate;
  DateTime? endDate;
  String? minAge;
  String? maxAge;


  CreateJobPostRequestModel({
    this.id,
    this.positionId,
    this.clientId,
    this.minRatePerHour = '',
    this.maxRatePerHour = '',
    this.vacancy,
    this.dates,
    this.nationalities,
    this.skills = const [],
    this.minExperience = '',
    this.maxExperience = '',
    this.salary = '',
    this.age = '',
    this.experience = '',
    this.languages,
    this.description,
    this.publishedDate,
    this.endDate,
    this.minAge = '',
    this.maxAge = '',
   
  });
  CreateJobPostRequestModel copy() {
    return CreateJobPostRequestModel(
      positionId: this.positionId,
      clientId: this.clientId,
      minRatePerHour: this.minRatePerHour,
      maxRatePerHour: this.maxRatePerHour,
      minExperience: this.minExperience,
      maxExperience: this.maxExperience,
      minAge: this.minAge,
      maxAge: this.maxAge,
      age: this.age,
      salary: this.salary,
      experience: this.experience,
      skills: List<String>.from(this.skills ?? []),
      nationalities: List<String>.from(this.nationalities ?? []),
      languages: List<String>.from(this.languages ?? []),
      publishedDate: this.publishedDate,
      endDate: this.endDate,
      dates: List<RequestDateModel>.from(this.dates ?? []),
      description: this.description,
      vacancy: this.vacancy,
    );
  }
  String toRawJson({required String type}) => json.encode(toJson(type: type));

  Map<String, dynamic> toJson({required String type}) => {
        if (type == "update") "id": id,
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
        "experience": experience,
        "age": age,
        "salary": salary,
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

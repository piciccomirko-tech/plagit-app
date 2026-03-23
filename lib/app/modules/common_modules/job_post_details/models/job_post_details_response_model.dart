import 'dart:convert';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';

class JobPostDetailsResponseModel {
  final String? status;
  final int? statusCode;
  final String? message;
  final Job? details;

  JobPostDetailsResponseModel({
    this.status,
    this.statusCode,
    this.message,
    this.details,
  });

  factory JobPostDetailsResponseModel.fromRawJson(String str) =>
      JobPostDetailsResponseModel.fromJson(json.decode(str));

  factory JobPostDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      JobPostDetailsResponseModel(
        status: json["status"],
        statusCode: json["statusCode"],
        message: json["message"],
        details: json["details"] == null ? null : Job.fromJson(json["details"]),
      );
}

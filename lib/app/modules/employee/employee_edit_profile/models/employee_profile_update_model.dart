import 'dart:convert';

class EmployeeProfileRequestModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? email;
  final String? gender;
  final String? hourlyRate;
  final String? employeeExperience;
  final String? positionId;
  final String? presentAddress;
  final String? postCode;
  final String? phoneNumber;
  final String? countryName;
  final String? nationality;

  EmployeeProfileRequestModel({
    required this.id,
     this.firstName,
     this.lastName,
     this.dateOfBirth,
     this.email,
     this.gender,
     this.hourlyRate,
     this.employeeExperience,
     this.positionId,
     this.presentAddress,
     this.postCode,
     this.phoneNumber,
     this.countryName,
     this.nationality,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "dateOfBirth": dateOfBirth,
        "email": email,
        "gender": gender,
        "hourlyRate": hourlyRate,
        "employeeExperience": employeeExperience,
        "positionId": positionId,
        "presentAddress": presentAddress,
        "postCode": postCode,
        "phoneNumber": phoneNumber,
        "countryName": countryName,
        "nationality": nationality,
      };

  String toRawJson() => json.encode(toJson());
}

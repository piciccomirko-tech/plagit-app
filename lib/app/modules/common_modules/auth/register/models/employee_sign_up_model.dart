import 'dart:convert';

class EmployeeSignUpRequestModel {
  final String? firstName;
  final String? lastName;
  final String? presentAddress;
  final String? email;
  final String? positionId;
  final String? password;
  final String? lat;
  final String? long;
  final String? countryName;
  final bool? isSocialAccount;
  final String? accountType;
  final String? profilePicture;

  EmployeeSignUpRequestModel({
    this.firstName,
    this.lastName,
    this.presentAddress,
    this.email,
    this.positionId,
    this.password,
    this.lat,
    this.long,
    this.countryName,
    this.isSocialAccount,
    this.accountType,
    this.profilePicture,
  });

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        if (presentAddress != null) "presentAddress": presentAddress,
        "email": email,
        if (positionId != null) "positionId": positionId,
        if (password != null) "password": password,
        if (lat != null) "lat": lat,
        if (long != null) "long": long,
        if (countryName != null) "countryName": countryName,
        if (isSocialAccount != null) "isSocialAccount": isSocialAccount,
        if (accountType != null) "accountType": accountType,
        if (profilePicture != null) "profilePicture": profilePicture
      };
}

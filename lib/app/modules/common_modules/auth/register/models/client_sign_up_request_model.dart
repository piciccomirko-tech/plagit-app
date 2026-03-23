import 'dart:convert';

class ClientSignUpRequestModel {
  final String? restaurantName;
  final String? restaurantAddress;
  final String? email;
  final String? phoneNumber;
  final String? password;
  final String? lat;
  final String? long;
  final String? countryName;
  final bool? isSocialAccount;
  final String? accountType;
  final String? profilePicture;

  ClientSignUpRequestModel({
    this.restaurantName,
    this.restaurantAddress,
    this.email,
    this.phoneNumber,
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
        "restaurantName": restaurantName,
        if (restaurantAddress != null) "restaurantAddress": restaurantAddress,
        "email": email,
        if (phoneNumber != null) "phoneNumber": phoneNumber,
        if (password != null) "password": password,
        if (lat != null) "lat": lat,
        if (long != null) "long": long,
        if (countryName != null) "countryName": countryName,
        if (isSocialAccount != null) "isSocialAccount": isSocialAccount,
        if (accountType != null) "accountType": accountType,
        if (profilePicture != null) "profilePicture": profilePicture,
      };
}

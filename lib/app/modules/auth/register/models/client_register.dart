class ClientRegistration {
  final String restaurantName;
  final String restaurantAddress;
  final String email;
  final String phoneNumber;
  final String sourceId;
  final String referPersonId;
  final String password;
  final String lat;
  final String long;
  final String countryName;

  ClientRegistration(
      {required this.restaurantName,
      required this.restaurantAddress,
      required this.email,
      required this.phoneNumber,
      required this.sourceId,
      required this.referPersonId,
      required this.password,
      required this.lat,
      required this.long,
      required this.countryName});

  Map<String, dynamic> get toJson => {
        "restaurantName": restaurantName,
        "restaurantAddress": restaurantAddress,
        "email": email,
        "phoneNumber": phoneNumber,
        "sourceId": sourceId,
        if (referPersonId.isNotEmpty) "referPersonId": referPersonId,
        "password": password,
        "lat": lat,
        "long": long,
        "countryName": countryName,
      };
}

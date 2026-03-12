class ClientProfileUpdate {
  String id;
  String restaurantName;
  String restaurantAddress;
  String email;
  String phoneNumber;
  String lat;
  String long;

  ClientProfileUpdate({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.email,
    required this.phoneNumber,
    required this.lat,
    required this.long,
  });

  Map<String, dynamic> get toJson => {
        "id": id,
        "restaurantName": restaurantName,
        "restaurantAddress": restaurantAddress,
        "email": email,
        "phoneNumber": phoneNumber,
        "lat": lat,
        "long": long,
      };
}

class ClientProfileUpdate {
  String id;
  String? restaurantName;
  String? restaurantAddress;
  String? email;
  String? phoneNumber;
  String? lat;
  String? long;
  String? countryName;






  ClientProfileUpdate({
    required this.id,
     this.restaurantName,
     this.restaurantAddress,
     this.email,
     this.phoneNumber,
     this.lat,
     this.long,
     this.countryName,

  });

  Map<String, dynamic> get toJson => {
        "id": id,
        "restaurantName": restaurantName,
        "restaurantAddress": restaurantAddress,
        "email": email,
        "phoneNumber": phoneNumber,
        "lat": lat,
        "long": long,
        "countryName": countryName,

    
      };
}

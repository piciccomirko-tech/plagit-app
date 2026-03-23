class ProfileUpdateModel {

  final String clientName;
  final String clientAddress;
  // final String email;
  final String phoneNumber;

  ProfileUpdateModel({
    // required this.clientId,
    required this.clientName,
    required this.clientAddress,
    // required this.email,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    // "clientId": clientId,
    "clientName": clientName,
    "clientAddress": clientAddress,
    // "email": email,
    "phoneNumber": phoneNumber,
  };
}

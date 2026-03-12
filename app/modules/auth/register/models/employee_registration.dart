class EmployeeRegistration {
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String countryName;
  String positionId;
  String? documents;

  EmployeeRegistration(
      {required this.firstName,
      required this.lastName,
      required this.email,
      required this.phoneNumber,
      required this.countryName,
      required this.positionId,
      required this.documents});

  Map<String, String> get toJson => {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phoneNumber": phoneNumber,
        "countryName": countryName,
        "positionId": positionId,
        "documents": documents??''
      };
}

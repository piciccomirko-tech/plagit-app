class Login {
  String? userIdNumber;
  String? email;
  String password;

  Login({
    this.userIdNumber,
    this.email,
    required this.password,
  });

  Map<String, String?> get toJson => {
        "userIdNumber": userIdNumber,
        "email": email,
        "password": password,
      };
}

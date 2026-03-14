class Login {
  String? userIdNumber;
  String? email;
  String password;

  Login({
    this.userIdNumber,
    this.email,
    required this.password,
  });

  Map<String, String> get toJson {
    final map = <String, String>{"password": password};
    if (email != null && email!.isNotEmpty) map["email"] = email!;
    if (userIdNumber != null && userIdNumber!.isNotEmpty) map["userIdNumber"] = userIdNumber!;
    return map;
  }
}

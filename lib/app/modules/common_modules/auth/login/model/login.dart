class LoginRequestModel {
  String? email;
  String? userIdNumber;
  String? password;
  bool? isSocialAccount;
  String? accountType;

  LoginRequestModel(
      { this.email,
      this.password,
      this.userIdNumber,
      this.isSocialAccount,
      this.accountType});

  Map<String, dynamic> get toJson => {
   
        if (email != null) "email": email,
        if (userIdNumber != null) "userIdNumber": userIdNumber,
        if (password != null) "password": password,
        if (isSocialAccount != null) "isSocialAccount": isSocialAccount,
        if (accountType != null) "accountType": accountType,
      };
}

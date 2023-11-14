class OtpCheckRequestModel {
  final String email;
  final String otpNumber;

  OtpCheckRequestModel({required this.email, required this.otpNumber});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['otpNumber'] = otpNumber;
    return data;
  }
}

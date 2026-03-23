class ClientBusinessUpdate {
  final String id;
  final String? companyName;
  final String? companyRegisterNumber;
  final String? vatNumber;
  final String? emergencyContactNumber;
  final String? additionalEmailAddress;

  ClientBusinessUpdate({
    required this.id,
    this.companyName,
    this.vatNumber,
    this.companyRegisterNumber,
    this.emergencyContactNumber,
    this.additionalEmailAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'vatNumber': vatNumber,
      'companyRegisterNumber': companyRegisterNumber,
      'emergencyContactNumber': emergencyContactNumber,
      'additionalEmailAddress': additionalEmailAddress,
    };
  }
}

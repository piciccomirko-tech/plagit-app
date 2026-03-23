class Certificate {
  final String? certificateId;
  final String? certificateName;
  final String? attachment;

  Certificate({
    this.certificateId,
    this.certificateName,
    this.attachment,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateId: json['certificateId'] as String?,
      certificateName: json['certificateName'] as String?,
      attachment: json['attachment'] as String?,
    );
  }
}

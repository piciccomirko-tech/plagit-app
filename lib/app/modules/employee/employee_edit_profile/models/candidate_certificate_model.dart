class Certificate {
  String? certificateId;
  String? certificateName;
  String? attachment;

  Certificate({this.certificateId, this.certificateName, this.attachment});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      certificateId: json['certificateId'],
      certificateName: json['certificateName'],
      attachment: json['attachment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'certificateId': certificateId,
      'certificateName': certificateName,
      'attachment': attachment,
    };
  }
}

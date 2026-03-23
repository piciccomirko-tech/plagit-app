class CompleteUploadRequestModel {
  final String uploadId;
  final String fileName;
  final String type;

  CompleteUploadRequestModel({
    required this.uploadId,
    required this.fileName,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'fileName': fileName,
      'type': type,
    };
  }
}

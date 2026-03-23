class StartUploadRequestModel {
  final String fileName;
  final String fileType;

  StartUploadRequestModel({
    required this.fileName,
    required this.fileType,
  });

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'type': fileType,
    };
  }
}

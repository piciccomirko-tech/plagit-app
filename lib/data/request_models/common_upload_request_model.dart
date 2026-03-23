import 'dart:io';

class CommonUploadRequestModel {
  final File file;
  final List<String> mimeTypeSplit;

  CommonUploadRequestModel({
    required this.file,
    required this.mimeTypeSplit,
  });

  Map<String, dynamic> toJson() {
    return {
      'file': file,
      'mimeTypeSplit': mimeTypeSplit,
    };
  }
}

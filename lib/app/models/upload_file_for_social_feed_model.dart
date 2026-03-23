import 'package:file_picker/file_picker.dart';

class PlatformFileUpload {
  PlatformFile file;
  double uploadPercentage;
  String uploadedUrl;
  String type;
  int fileSize;
  PlatformFileUpload({
    required this.file,
    this.uploadPercentage = 0.0,
    this.uploadedUrl = '',
    required this.type,
    required this.fileSize,
  });
  int get uploadedBytes => ((fileSize * (uploadPercentage / 100)).round());
}

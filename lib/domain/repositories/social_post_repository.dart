import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:mh/domain/model/complete_upload_model.dart';
import 'package:mh/domain/model/start_upload_model.dart';

abstract class SocialPostRepository {
  Future<CompleteUploadModel?> commonUpload({
    required File file,
    required List<String> mimeTypeSplit,
  });

  Future<StartUploadModel?> startUpload({
    required String fileName,
    required String fileType,
  });

  Future<StreamedResponse> chunkUpload({
    required String uploadId,
    required String fileName,
    required String partNumber,
    required String fileMimeType,
    required Uint8List chunk,
  });

  Future<CompleteUploadModel?> completeUpload({
    required String uploadId,
    required String fileName,
    required String fileType,
  });
}

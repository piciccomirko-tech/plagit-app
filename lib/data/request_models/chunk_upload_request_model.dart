import 'dart:typed_data';

class ChunkUploadRequestModel {
  final String uploadId;
  final String fileName;
  final String partNumber;
  final String fileMimeType;
  final Uint8List chunk;

  ChunkUploadRequestModel({
    required this.uploadId,
    required this.fileName,
    required this.partNumber,
    required this.fileMimeType,
    required this.chunk,
  });

  Map<String, dynamic> toJson() {
    return {
      'uploadId': uploadId,
      'fileName': fileName,
      'partNumber': partNumber.toString(),
      'mimeType': fileMimeType,
      'chunk': chunk,
    };
  }
}

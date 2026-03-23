import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:mh/data/data_sources/social_post_data_source.dart';
import 'package:mh/data/mappers/common_upload_mapper.dart';
import 'package:mh/data/mappers/complete_upload_mapper.dart';
import 'package:mh/data/mappers/start_upload_mapper.dart';
import 'package:mh/data/request_models/chunk_upload_request_model.dart';
import 'package:mh/data/request_models/common_upload_request_model.dart';
import 'package:mh/data/request_models/complete_upload_request_model.dart';
import 'package:mh/data/request_models/start_upload_request_model.dart';
import 'package:mh/domain/model/complete_upload_model.dart';
import 'package:mh/domain/model/start_upload_model.dart';
import 'package:mh/domain/repositories/social_post_repository.dart';

class SocialPostRepositoryImpl implements SocialPostRepository {
  final SocialPostDataSource socialPostDataSource;

  SocialPostRepositoryImpl({
    required this.socialPostDataSource,
  });

  @override
  Future<CompleteUploadModel?> commonUpload({
    required File file,
    required List<String> mimeTypeSplit,
  }) async {
    final response = await socialPostDataSource.commonUpload(
      commonUploadRequestModel: CommonUploadRequestModel(
        file: file,
        mimeTypeSplit: mimeTypeSplit,
      ),
    );

    final commonUploadModel = CommonUploadMapper.mapResponseToDomain(response);

    return commonUploadModel;
  }

  @override
  Future<StartUploadModel?> startUpload({
    required String fileName,
    required String fileType,
  }) async {
    final response = await socialPostDataSource.startUpload(
      StartUploadRequestModel(
        fileName: fileName,
        fileType: fileType,
      ),
    );

    final startUploadModel = StartUploadMapper.mapResponseToDomain(response);

    return startUploadModel;
  }

  @override
  Future<StreamedResponse> chunkUpload({
    required String uploadId,
    required String fileName,
    required String partNumber,
    required String fileMimeType,
    required Uint8List chunk,
  }) async {
    final response = await socialPostDataSource.chunkUpload(
      chunkUploadRequestModel: ChunkUploadRequestModel(
        uploadId: uploadId,
        fileName: fileName,
        partNumber: partNumber.toString(),
        fileMimeType: fileMimeType,
        chunk: chunk,
      ),
    );

    return response;
  }

  @override
  Future<CompleteUploadModel?> completeUpload({
    required String uploadId,
    required String fileName,
    required String fileType,
  }) async {
    final response = await socialPostDataSource.completeUpload(
      completeUploadRequestModel: CompleteUploadRequestModel(
        uploadId: uploadId,
        fileName: fileName,
        type: fileType,
      ),
    );

    final completeUploadModel =
        CompleteUploadMapper.mapResponseToDomain(response);

    return completeUploadModel;
  }
}

import 'package:http/http.dart';
import 'package:mh/data/request_models/chunk_upload_request_model.dart';
import 'package:mh/data/request_models/common_upload_request_model.dart';
import 'package:mh/data/request_models/complete_upload_request_model.dart';
import 'package:mh/data/request_models/start_upload_request_model.dart';
import 'package:mh/data/response_models/common_upload_response_model.dart';
import 'package:mh/data/response_models/complete_upload_response_model.dart';
import 'package:mh/data/response_models/start_upload_response_model.dart';

abstract class SocialPostDataSource {
  Future<CommonUploadResponseModel> commonUpload(
      {required CommonUploadRequestModel commonUploadRequestModel});

  Future<StartUploadResponseModel> startUpload(
      StartUploadRequestModel startUploadRequestModel);

  Future<StreamedResponse> chunkUpload({
    required ChunkUploadRequestModel chunkUploadRequestModel,
  });

  Future<CompleteUploadResponseModel> completeUpload({
    required CompleteUploadRequestModel completeUploadRequestModel,
  });
}

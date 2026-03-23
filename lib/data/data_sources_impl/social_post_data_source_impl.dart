import 'package:http/http.dart';
import 'package:mh/app/common/local_storage/storage_helper.dart';
import 'package:mh/core/api_client/api_client.dart';
import 'package:mh/core/api_client/api_end_points.dart';
import 'package:mh/data/data_sources/social_post_data_source.dart';
import 'package:mh/data/request_models/chunk_upload_request_model.dart';
import 'package:mh/data/request_models/common_upload_request_model.dart';
import 'package:mh/data/request_models/complete_upload_request_model.dart';
import 'package:mh/data/request_models/start_upload_request_model.dart';
import 'package:mh/data/response_models/common_upload_response_model.dart';
import 'package:mh/data/response_models/complete_upload_response_model.dart';
import 'package:mh/data/response_models/start_upload_response_model.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:http_parser/http_parser.dart';

class SocialPostDataSourceImpl implements SocialPostDataSource {
  ApiClient apiClient;

  SocialPostDataSourceImpl({required this.apiClient});

  @override
  Future<CommonUploadResponseModel> commonUpload({
    required CommonUploadRequestModel commonUploadRequestModel,
  }) async {
    dio.FormData formData = dio.FormData.fromMap({});
    formData.files.add(
      MapEntry(
        "file",
        await dio.MultipartFile.fromFile(
          commonUploadRequestModel.file.path,
          contentType: MediaType(
            commonUploadRequestModel.mimeTypeSplit[0],
            commonUploadRequestModel.mimeTypeSplit[1],
          ),
        ),
      ),
    );

    // Set options for the request
    dio.Options options = dio.Options(
      headers: {
        'Content-Type': 'multipart/form-data',
        'Vary': 'Accept',
        'Authorization': 'Bearer ${StorageHelper.getToken}',
      },
      sendTimeout: const Duration(minutes: 20),
      followRedirects: false,
    );

    dio.Response response = await dio.Dio().post(
      "${apiClient.baseUrl}/${EndPoints.commonUpload}",
      data: formData,
      options: options,
    );

    final convertedModel = CommonUploadResponseModel(
      status: response.data['status'],
      statusCode: response.data['statusCode'],
      message: response.data['message'],
      fileUrl: response.data['data']?['file'],
    );

    return convertedModel;
  }

  @override
  Future<StartUploadResponseModel> startUpload(
    StartUploadRequestModel startUploadRequestModel,
  ) async {
    final response = await apiClient.post(
      EndPoints.startUpload,
      data: startUploadRequestModel.toJson(),
    );

    return StartUploadResponseModel.fromJson(response);
  }

  @override
  Future<StreamedResponse> chunkUpload({
    required ChunkUploadRequestModel chunkUploadRequestModel,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${apiClient.baseUrl}/${EndPoints.chunkUpload}'),
    );
    request.fields['uploadId'] = chunkUploadRequestModel.uploadId;
    request.fields['fileName'] = chunkUploadRequestModel.fileName;
    request.fields['partNumber'] =
        chunkUploadRequestModel.partNumber.toString();
    request.fields['mimeType'] = chunkUploadRequestModel.fileMimeType;
    request.files.add(
      http.MultipartFile.fromBytes(
        'chunk',
        chunkUploadRequestModel.chunk,
        filename: chunkUploadRequestModel.fileName,
      ),
    );

    final response = await request.send();

    return response;
  }

  @override
  Future<CompleteUploadResponseModel> completeUpload({
    required CompleteUploadRequestModel completeUploadRequestModel,
  }) async {
    final response = await apiClient.post(
      EndPoints.completeUpload,
      data: completeUploadRequestModel.toJson(),
    );

    return CompleteUploadResponseModel.fromJson(response);
  }
}

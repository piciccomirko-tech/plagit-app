import 'package:mh/data/response_models/start_upload_response_model.dart';
import 'package:mh/domain/model/start_upload_model.dart';

class StartUploadMapper {
  static StartUploadModel? mapResponseToDomain(
      StartUploadResponseModel? response) {
    if (response == null || response.result == null) {
      return null;
    }

    final result = response.result!;

    return StartUploadModel(
      status: response.status == 'success' ? true : false,
      uploadId: result.uploadId ?? '',
      fileName: result.fileName ?? '',
      type: result.type ?? '',
    );
  }
}

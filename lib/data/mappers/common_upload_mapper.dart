import 'package:mh/data/response_models/common_upload_response_model.dart';
import 'package:mh/domain/model/complete_upload_model.dart';

class CommonUploadMapper {
  static CompleteUploadModel? mapResponseToDomain(
      CommonUploadResponseModel? response) {
    if (response == null) {
      return null;
    }

    return CompleteUploadModel(
      status: response.status == 'success' ? true : false,
      message: response.message ?? '',
      fileUrl: response.fileUrl ?? '',
    );
  }
}

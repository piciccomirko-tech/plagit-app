import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../common/utils/type_def.dart';
import '../enums/error_from.dart';
import '../models/custom_error.dart';

class ApiErrorHandle {
  static EitherResponse checkError(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 400:
        return right(response);
      case 422:
        return left(CustomError(
          errorCode: response.statusCode ?? 422,
          errorFrom: ErrorFrom.api,
          msg: response.body["message"].toString(),
        ));
      default:
        return left(CustomError(
          errorCode: response.statusCode ?? 1001,
          errorFrom: ErrorFrom.api,
          msg: response.body["message"].toString(),
        ));
    }
  }
}

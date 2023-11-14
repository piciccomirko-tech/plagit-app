import 'package:dartz/dartz.dart';
import 'package:get/get_connect/http/src/response/response.dart';

import '../../models/custom_error.dart';

/// [EitherResponse] used when api return some response
/// string(left) means has error
/// Response(right) means successful
typedef EitherResponse = Either<CustomError, Response>;

/// [EitherModel] used when [EitherResponse] get right
/// then convert that response to model type [T]
/// string(left) means has error
/// T(right) means convert response to model successfully
typedef EitherModel<T> = Future<Either<CustomError, T>>;
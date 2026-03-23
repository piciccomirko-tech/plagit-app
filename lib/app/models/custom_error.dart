import '../enums/error_from.dart';

class CustomError {
  int errorCode;
  ErrorFrom errorFrom;
  String msg;
  Function()? onRetry;

  CustomError({
    required this.errorCode,
    required this.errorFrom,
    required this.msg,
    this.onRetry,
  });
}

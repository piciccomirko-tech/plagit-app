import 'package:mh/core/network/exceptions/base_exception.dart';

class NetworkException extends BaseException {
  NetworkException(String message, {required int code})
      : super(message: message);
}

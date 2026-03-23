import 'package:mh/data/response_models/payment_response_model.dart';

abstract class PaymentDataSource {
  Future<PaymentResponseModel> getPaymentDetails();
}

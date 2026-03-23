import 'package:mh/domain/model/payment_model.dart';

abstract class PaymentRepository {
  Future<PaymentModel?> getPaymentDetails();
}

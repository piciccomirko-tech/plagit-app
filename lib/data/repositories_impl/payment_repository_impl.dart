import 'package:mh/data/data_sources/payment_data_source.dart';
import 'package:mh/data/mappers/payment_mapper.dart';
import 'package:mh/domain/model/payment_model.dart';
import 'package:mh/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentDataSource paymentDataSource;

  PaymentRepositoryImpl({
    required this.paymentDataSource,
  });

  @override
  Future<PaymentModel?> getPaymentDetails() async {
    final response = await paymentDataSource.getPaymentDetails();

    final paymentModel = PaymentMapper.mapResponseToDomain(response);

    return paymentModel;
  }
}

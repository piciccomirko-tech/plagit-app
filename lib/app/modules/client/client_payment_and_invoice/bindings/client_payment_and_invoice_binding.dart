import 'package:get/get.dart';
import 'package:mh/data/data_sources/payment_data_source.dart';
import 'package:mh/data/data_sources_impl/payment_data_source_impl.dart';
import 'package:mh/data/repositories_impl/payment_repository_impl.dart';
import 'package:mh/domain/repositories/payment_repository.dart';

import '../controllers/client_payment_and_invoice_controller.dart';

class ClientPaymentAndInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientPaymentAndInvoiceController>(
      () => ClientPaymentAndInvoiceController(
        paymentRepository: Get.find(),
      ),
    );

    Get.lazyPut<PaymentDataSource>(
      () => PaymentDataSourceImpl(apiClient: Get.find()),
    );
    Get.lazyPut<PaymentRepository>(
      () => PaymentRepositoryImpl(
        paymentDataSource: Get.find(),
      ),
    );
  }
}

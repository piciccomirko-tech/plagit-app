import 'package:get/get.dart';

import '../controllers/client_payment_and_invoice_controller.dart';

class ClientPaymentAndInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientPaymentAndInvoiceController>(
      () => ClientPaymentAndInvoiceController(),
    );
  }
}

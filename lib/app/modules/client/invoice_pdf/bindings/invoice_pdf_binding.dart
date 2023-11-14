import 'package:get/get.dart';

import '../controllers/invoice_pdf_controller.dart';

class InvoicePdfBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoicePdfController>(
      () => InvoicePdfController(),
    );
  }
}

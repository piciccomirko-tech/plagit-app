import 'package:get/get.dart';

import '../controllers/stripe_payment_controller.dart';

class StripePaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StripePaymentController>(
      () => StripePaymentController(),
    );
  }
}

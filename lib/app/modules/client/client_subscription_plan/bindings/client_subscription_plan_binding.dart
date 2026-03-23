import 'package:get/get.dart';

import '../controllers/client_subscription_plan_controller.dart';

class ClientSubscriptionPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientSubscriptionPlanController>(
      () => ClientSubscriptionPlanController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/client_terms_condition_for_hire_controller.dart';

class ClientTermsConditionForHireBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClientTermsConditionForHireController>(
      () => ClientTermsConditionForHireController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/terms_and_condition_controller.dart';

class TermsAndConditionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsAndConditionController>(
      () => TermsAndConditionController(),
    );
  }
}

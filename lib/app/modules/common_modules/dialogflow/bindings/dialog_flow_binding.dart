import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/dialogflow/controllers/dialog_flow_controller.dart';

class DialogFlowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DialogFlowController>(
      () => DialogFlowController(),
    );
  }
}

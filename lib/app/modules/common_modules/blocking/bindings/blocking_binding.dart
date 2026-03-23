import 'package:get/get.dart';

import '../controllers/blocking_controller.dart';

class BlockingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockingController>(
      () => BlockingController(),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/live_location_controller.dart';

class LiveLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveLocationController>(
      () => LiveLocationController(),
    );
  }
}

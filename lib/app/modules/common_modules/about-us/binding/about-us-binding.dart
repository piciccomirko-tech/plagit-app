import 'package:get/get.dart';

import '../controller/about-us-controller.dart';

class AboutUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AboutUsController>(() => AboutUsController());
  }
}

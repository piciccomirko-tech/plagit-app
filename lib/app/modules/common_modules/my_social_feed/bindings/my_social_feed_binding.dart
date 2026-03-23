import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/my_social_feed/controllers/my_social_feed_controller.dart';

class MySocialFeedBinding extends Bindings {

  @override
  void dependencies() {
    Get.lazyPut(() => MySocialFeedController());
  }
}
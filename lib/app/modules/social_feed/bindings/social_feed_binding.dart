import 'package:get/get.dart';
import '../controllers/social_feed_controller.dart';

class SocialFeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SocialFeedController>(() => SocialFeedController());
  }
}

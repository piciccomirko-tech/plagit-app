import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/common_social_feed/controllers/common_social_feed_controller.dart';

class CommonSocialFeedBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommonSocialFeedController>(
      () => CommonSocialFeedController(
        socialFeedRepository: Get.find(),
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/social_feed/controllers/social_feed_controller.dart';

import '../controllers/client_home_controller.dart';

class ClientHomeBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<ClientHomeController>(
      () => ClientHomeController(),
    );

    Get.lazyPut<NotificationsController>(
          () => NotificationsController(),
    );

    Get.lazyPut<SocialFeedController>(
          () => SocialFeedController(),
    );
  }
}

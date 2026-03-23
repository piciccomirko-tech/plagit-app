import 'package:get/get.dart';
import '../controllers/social_post_details_controller.dart';

class SocialPostDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SocialPostDetailsController());
  }
}

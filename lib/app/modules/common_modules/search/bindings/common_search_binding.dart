import 'package:get/get.dart';

import '../../common_job_posts/controllers/common_job_posts_cntroller.dart';
import '../controllers/common_search_controller.dart';
class CommonSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommonSearchController>(
      () => CommonSearchController(),
    );
    Get.lazyPut<CommonJobPostsController>(
      () => CommonJobPostsController(userType: 'client'),
    );
  }
}

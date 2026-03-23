import 'package:get/get.dart';

import '../../search/controllers/common_search_controller.dart';
import '../controllers/common_job_posts_cntroller.dart';


class CommonJobPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommonJobPostsController>(
      () => CommonJobPostsController(userType: 'client'),
    );
     Get.lazyPut<CommonSearchController>(
      () => CommonSearchController(),
    );
  }
}

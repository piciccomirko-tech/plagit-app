import 'package:get/get.dart';

import '../../job_post_details/controllers/job_post_details_controller.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobPostDetailsController>(
      () => JobPostDetailsController(),
    );
    Get.lazyPut<UserProfileController>(
      () => UserProfileController(),
    );
  }
}

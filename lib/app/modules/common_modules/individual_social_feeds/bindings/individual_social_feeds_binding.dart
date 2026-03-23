import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';

import '../../job_post_details/controllers/job_post_details_controller.dart';

class IndividualSocialFeedsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => IndividualSocialFeedsController());
    Get.lazyPut<JobPostDetailsController>(
      () => JobPostDetailsController(),
    );
  }
}

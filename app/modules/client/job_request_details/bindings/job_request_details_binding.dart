import 'package:get/get.dart';

import '../controllers/job_request_details_controller.dart';

class JobRequestDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobRequestDetailsController>(
      () => JobRequestDetailsController(),
    );
  }
}

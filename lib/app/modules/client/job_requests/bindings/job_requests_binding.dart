import 'package:get/get.dart';

import '../controllers/job_requests_controller.dart';

class JobRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JobRequestsController>(
      () => JobRequestsController(),
    );
  }
}

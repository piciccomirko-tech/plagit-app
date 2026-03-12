import 'package:get/get.dart';

import '../controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostsDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeJobPostsDetailsController>(
      () => EmployeeJobPostsDetailsController(),
    );
  }
}

import 'package:get/get.dart';

import '../../../common_modules/job_post_details/controllers/job_post_details_controller.dart';
import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDashboardController>(
      () => EmployeeDashboardController(),
    );
    Get.lazyPut<JobPostDetailsController>(
      () => JobPostDetailsController(),
    );
  }
}

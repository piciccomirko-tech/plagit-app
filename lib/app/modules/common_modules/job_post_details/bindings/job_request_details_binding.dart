import 'package:get/get.dart';

import '../../../employee/employee_hired_history/controllers/employee_hired_history_controller.dart';
import '../controllers/job_post_details_controller.dart';

class JobPostDetailsBinding extends Bindings {
  @override
  void dependencies() {
      Get.lazyPut<EmployeeHiredHistoryController>(
      () => EmployeeHiredHistoryController(),
    );
    Get.lazyPut<JobPostDetailsController>(
      () => JobPostDetailsController(),
    );

  }
}

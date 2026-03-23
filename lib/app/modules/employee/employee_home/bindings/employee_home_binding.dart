import 'package:get/get.dart';
import '../../../common_modules/job_post_details/controllers/job_post_details_controller.dart';
import '../controllers/employee_home_controller.dart';

class EmployeeHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeHomeController>(
      () => EmployeeHomeController(),);
    Get.lazyPut<JobPostDetailsController>(
      () => JobPostDetailsController(),
      
    );
    // Get.lazyPut<AdminHomeController>(
    //   () => AdminHomeController(),
      
    // );
  }
}

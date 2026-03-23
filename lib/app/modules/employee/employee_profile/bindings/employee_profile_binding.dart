import 'package:get/get.dart';
import 'package:mh/app/modules/employee/employee_profile/controllers/employee_profile_controller.dart';

class EmployeeProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeeProfileController());
  }
}

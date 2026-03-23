import 'package:get/get.dart';
import '../../../employee/employee_search/controllers/employee_search_controller.dart';

class AdminSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<AdminSearchController>(() => AdminSearchController());
    Get.lazyPut<EmployeeSearchController>(() => EmployeeSearchController());
  }
}

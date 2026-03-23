import 'package:get/get.dart';
import 'package:mh/app/modules/employee/employee_plagit_plus/controllers/employee_plagit_plus_controller.dart';

class EmployeePlagitPlusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EmployeePlagitPlusController());
  }
}

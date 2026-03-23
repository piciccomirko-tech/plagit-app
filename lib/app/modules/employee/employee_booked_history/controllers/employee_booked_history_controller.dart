import 'package:get/get.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeeBookedHistoryController extends GetxController {
  final EmployeeHomeController employeeHomeController = Get.find<EmployeeHomeController>();

  @override
  void onInit() {
    employeeHomeController.getBookingHistory();
    super.onInit();
  }

  void onDetailsClick({required String notificationId}) {
    Get.toNamed(Routes.employeeBookedHistoryDetails, arguments: notificationId);
  }
}

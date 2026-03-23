import 'package:get/get.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import '../../../client/client_dashboard/controllers/client_dashboard_controller.dart';
import '../../../client/client_home_premium/controllers/client_home_premium_controller.dart';
import '../../../employee/employee_home/controllers/employee_home_controller.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeBinding extends Bindings {

  @override
  void dependencies() {
        Get.lazyPut<ClientDashboardController  >(
      () => ClientDashboardController(),
    );
    Get.lazyPut<AdminHomeController>(
      () => AdminHomeController(),
    );
    Get.lazyPut<ClientHomePremiumController>(() => ClientHomePremiumController());

    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
    );

    Get.lazyPut<EmployeeHomeController>(
      () => EmployeeHomeController(),
    );


  }
}

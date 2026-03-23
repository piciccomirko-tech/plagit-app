import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';

import '../../../common_modules/job_post_details/controllers/job_post_details_controller.dart';
import '../../client_dashboard/controllers/client_dashboard_controller.dart';
import '../../client_home/controllers/client_home_controller.dart';

class ClientHomePremiumBinding extends Bindings{
  @override
  void dependencies() {
   Get.lazyPut(()=> ClientHomePremiumController());
      Get.lazyPut(()=> ClientDashboardController());
   Get.lazyPut(()=> JobPostDetailsController());
   Get.lazyPut(()=> ClientHomeController());

  }

}
import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_profile/controllers/client_profile_controller.dart';

class ClientProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientProfileController());
  }
}

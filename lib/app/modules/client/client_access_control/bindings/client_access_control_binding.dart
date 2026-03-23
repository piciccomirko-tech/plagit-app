import 'package:get/get.dart';
import '../controllers/client_access_control_controller.dart';

class ClientAccessControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientAccessControlController());
  }
}

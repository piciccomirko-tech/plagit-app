import 'package:get/get.dart';
import '../controllers/client_edit_profile_controller.dart';
import '../controllers/image_upload_controller.dart';


class ClientEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ClientEditProfileController());
     Get.lazyPut(() => ProfilePictureController());  // Bind the ProfileController for image upload
  }
}

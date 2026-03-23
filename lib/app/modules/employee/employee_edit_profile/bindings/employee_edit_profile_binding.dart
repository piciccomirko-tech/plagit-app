import 'package:get/get.dart';
import '../controllers/employee_edit_profile_controller.dart';
import '../controllers/employee_profile_picture_upload_controller.dart';

class EmployeeEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeEditProfileController>(
      () => EmployeeEditProfileController());
    Get.lazyPut<CandidateProfilePictureController>(
      () => CandidateProfilePictureController());
  }
}

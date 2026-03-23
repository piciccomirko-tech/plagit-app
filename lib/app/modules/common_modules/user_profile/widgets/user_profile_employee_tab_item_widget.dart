
import '../../../../common/utils/exports.dart';
import '../controllers/user_profile_controller.dart';
import 'user_profile_employee_profile_widget.dart';
import 'user_profile_employee_social_feed_widget.dart';

class UserProfileEmployeeTabItemWidget
    extends GetWidget<UserProfileController> {
  const UserProfileEmployeeTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? const UserProfileEmployeeProfileWidget()
        : const UserProfileEmployeeSocialFeedWidget());
  }
}

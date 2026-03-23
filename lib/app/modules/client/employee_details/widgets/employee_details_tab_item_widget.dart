import 'package:mh/app/modules/client/employee_details/controllers/employee_details_controller.dart';
import 'package:mh/app/modules/client/employee_details/widgets/employee_details_profile_widget.dart';
import 'package:mh/app/modules/client/employee_details/widgets/employee_details_social_feed_widget.dart';
import '../../../../common/utils/exports.dart';

class EmployeeDetailsTabItemWidget
    extends GetWidget<EmployeeDetailsController> {
  const EmployeeDetailsTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? const EmployeeDetailsProfileWidget()
        : const EmployeeDetailsSocialFeedWidget());
  }
}

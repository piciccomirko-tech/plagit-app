import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_check_in_checkout_widget.dart';

class BottomNavBarWidget extends GetView<EmployeeHomeController> {
  const BottomNavBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: controller.showCheckInCheckOutWidget == true,
        child: Padding(
            padding:  EdgeInsets.only(left: 15.0.w,right: 15.0.w,top: 15.0.w),
            child: const EmployeeCheckInCheckoutWidget())));
  }
}

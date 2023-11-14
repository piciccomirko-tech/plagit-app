import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class CalenderBottomNavBarWidget extends GetWidget<CalenderController> {
  const CalenderBottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Get.isRegistered<AdminHomeController>()
        ? const Wrap()
        : Get.isRegistered<EmployeeHomeController>()
            ? Obx(() => CustomBottomBar(
                  child: CustomButtons.button(
                    onTap: controller.disableSubmitButton == true ? null : controller.updateUnavailableDates,
                    backgroundColor: controller.disableSubmitButton == true ? MyColors.c_A6A6A6 : MyColors.c_C6A34F,
                    text: "Submit",
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  ),
                ))
            : Obx(() => CustomBottomBar(
                  child: CustomButtons.button(
                    onTap: controller.disabledBookButton == true ? null : controller.onBookNowClick,
                    backgroundColor: controller.disabledBookButton == true ? MyColors.c_A6A6A6 : MyColors.c_C6A34F,
                    text: "Book Now",
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  ),
                ));
  }
}

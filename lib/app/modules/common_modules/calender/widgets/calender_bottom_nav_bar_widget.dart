import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/helpers/responsive_helper.dart';
import 'package:mh/app/modules/common_modules/calender/controllers/calender_controller.dart';

class CalenderBottomNavBarWidget extends GetWidget<CalendarController> {
  const CalenderBottomNavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return controller.appController.user.value.isAdmin
        ? const Wrap()
        : controller.appController.user.value.isEmployee
            ? Obx(() => CustomBottomBar(
                  child: CustomButtons.button(
                    height: Get.width>600?30.h:48.h,
                    fontSize: ResponsiveHelper.isTab(context)?10.sp:15.sp,
                    onTap: controller.disableSubmitButton == true ? controller.createShortList : controller.updateUnavailableDates,
                    backgroundColor: controller.disableSubmitButton == true ? MyColors.c_A6A6A6 : MyColors.c_C6A34F,
                    text: controller.disableSubmitButton == true ?MyStrings.submit.tr:MyStrings.updateUnavailableDates.tr,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  ),
                ))
            : Obx(() => CustomBottomBar(
                  child: CustomButtons.button(
                    height: Get.width>600?30.h:48.h,
                    fontSize: ResponsiveHelper.isTab(context)?10.sp:15.sp,
                    onTap: controller.disabledBookButton == true ? null : controller.onBookNowClick,
                    backgroundColor: controller.disabledBookButton == true ? MyColors.c_A6A6A6 : MyColors.c_C6A34F,
                    text: MyStrings.bookNow.tr,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  ),
                ));
  }
}

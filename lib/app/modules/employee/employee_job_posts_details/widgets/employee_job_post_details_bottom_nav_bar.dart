import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostDetailsBottomNavBar extends GetWidget<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostDetailsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
      visible: controller.showInterestedButton,
      child: CustomBottomBar(
        child: CustomButtons.button(
            backgroundColor: (controller.jobPostDetails.users ?? [])
                .map((e) => e.id ?? "")
                .toList()
                .contains(controller.appController.user.value.employee?.id ?? "") ==
                true
                ? Colors.teal
                : MyColors.c_C6A34F,
            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            text: (controller.jobPostDetails.users ?? [])
                .map((e) => e.id ?? "")
                .toList()
                .contains(controller.appController.user.value.employee?.id ?? "") ==
                true
                ? "Already Applied".toUpperCase()
                : "I'm Interested".toUpperCase(),
            onTap: () => (controller.jobPostDetails.users ?? [])
                .map((e) => e.id ?? "")
                .toList()
                .contains(controller.appController.user.value.employee?.id ?? "") ==
                true
                ? null
                : controller.showInterest(context: context)),
      ),
    ));
  }
}

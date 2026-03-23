import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import 'package:mh/app/modules/common_modules/job_post_details/controllers/job_post_details_controller.dart';

class EmployeeJobPostDetailsBottomNavBar extends GetWidget<JobPostDetailsController> {
  const EmployeeJobPostDetailsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
      visible: controller.showInterestedButton,
      child: CustomBottomBar(

        child: CustomButtons.button(
            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            text: (controller.jobPostDetails.value.users ?? [])
                .map((e) => e.id ?? "")
                .toList()
                .contains(controller.appController.user.value.employee?.id ?? "") ==
                true
                ? MyStrings.alreadyApplied.tr.toUpperCase()
                : MyStrings.interested.tr.toUpperCase(),
            onTap: () => (controller.jobPostDetails.value.users ?? [])
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostDetailsBottomNavBar extends GetWidget<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostDetailsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: controller.showInterestedButton,
      child: CustomBottomBar(
        child: CustomButtons.button(
            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            text: "I'm Interested".toUpperCase(),
            onTap: () => controller.showInterest(context: context)),
      ),
    );
  }
}

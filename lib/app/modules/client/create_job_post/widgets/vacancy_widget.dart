import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class VacancyWidget extends GetWidget<CreateJobPostController> {
  const VacancyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      prefixIcon: Icons.business_center,
      hints: MyStrings.vacancy,
      value: '',
      items: controller.vacancyList,
      onChange: controller.onVacancyChange,
    );
  }
}

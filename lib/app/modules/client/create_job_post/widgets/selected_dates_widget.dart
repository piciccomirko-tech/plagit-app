import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class SelectedDatesWidget extends GetWidget<CreateJobPostController> {
  const SelectedDatesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecSelectedDates.value,
        label: "Select Days",
        prefixIcon: Icons.calendar_month,
        readOnly: true,
        onTap: controller.onSelectDaysClick,
        validator: (String? value) => Validators.emptyValidator(value, MyStrings.required.tr),
      ),
    );
  }
}

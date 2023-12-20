import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class ExperienceWidget extends GetWidget<CreateJobPostController> {
  const ExperienceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecExperience.value,
        label: "Experience",
        prefixIcon: Icons.lock_clock,
        //isMapField: true,
        // onSuffixPressed: controller.onClientAddressPressed,
        readOnly: true,
        onTap: () => controller.onCustomSliderClick(
            context: context,
            minValue: controller.createJobPostRequestModel.value.minExperience ?? 0,
            maxValue: controller.createJobPostRequestModel.value.maxExperience ?? 0,
            onTap: controller.onExperienceSubmitClick),
        validator: (String? value) => Validators.emptyValidator(value, MyStrings.required.tr),
      ),
    );
  }
}

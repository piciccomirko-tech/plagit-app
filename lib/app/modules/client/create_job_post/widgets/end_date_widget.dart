import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class EndDateWidget extends GetWidget<CreateJobPostController> {
  const EndDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => CustomTextInputField(
        controller: controller.tecEndDate.value,
        label: "End Date",
        prefixIcon: Icons.calendar_today_outlined,
        readOnly: true,
        onTap: () => controller.selectDate(context: context, dateType: 'end'),
        validator: (String? value) => Validators.emptyValidator(value, MyStrings.required.tr),
      ),
    );
  }
}

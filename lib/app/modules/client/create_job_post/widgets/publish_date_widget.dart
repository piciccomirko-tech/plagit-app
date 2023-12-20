import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class PublishDateWidget extends GetWidget<CreateJobPostController> {
  const PublishDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecPublishDate.value,
        label: "Publish Date",
        prefixIcon: Icons.calendar_month,
        readOnly: true,
        onTap: () => controller.selectDate(context: context, dateType: 'publish'),
        validator: (String? value) => Validators.emptyValidator(value, MyStrings.required.tr),
      ),
    );
  }
}

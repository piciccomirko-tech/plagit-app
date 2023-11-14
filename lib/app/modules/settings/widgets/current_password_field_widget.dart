import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/settings/controllers/settings_controller.dart';

class CurrentPasswordFieldWidget extends GetWidget<SettingsController> {
  const CurrentPasswordFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomTextInputField(
          controller: controller.tecCurrentPassword.value,
          label: MyStrings.currentPassword,
          prefixIcon: Icons.lock,
          isPasswordField: true,
          validator: (String? value) => Validators.emptyValidator(
            value,
            MyStrings.required.tr,
          ),
        ));
  }
}

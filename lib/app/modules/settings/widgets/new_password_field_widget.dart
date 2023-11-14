import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/settings/controllers/settings_controller.dart';

class NewPasswordFieldWidget extends GetWidget<SettingsController> {
  const NewPasswordFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomTextInputField(
          controller: controller.tecNewPassword.value,
          label: MyStrings.newPassword,
          prefixIcon: Icons.lock,
          isPasswordField: true,
          validator: (String? value) => Validators.emptyValidator(
            value,
            MyStrings.required.tr,
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/reset_password/controllers/reset_password_controller.dart';

class ConfirmPasswordFieldWidget extends GetWidget<ResetPasswordController> {
  const ConfirmPasswordFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomTextInputField(
      controller: controller.tecConfirmPassword.value,
      label: MyStrings.confirmPassword,
      prefixIcon: Icons.lock,
      isPasswordField: true,
      validator: (String? value) => Validators.emptyValidator(
        value,
        MyStrings.required.tr,
      ),
    ));
  }
}

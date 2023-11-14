import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/email_input/controllers/email_input_controller.dart';

class EmailFieldWidget extends GetWidget<EmailInputController> {
  const EmailFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  CustomTextInputField(
      controller: controller.tecClientEmailAddress,
      textInputType: TextInputType.emailAddress,
      label: MyStrings.emailAddress.tr,
      prefixIcon: Icons.email_rounded,
      validator: (String? value) => Validators.emailValidator(value),
    );
  }
}

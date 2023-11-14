import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import 'package:mh/app/modules/settings/controllers/settings_controller.dart';

class ButtonWidget extends GetWidget<SettingsController> {
  const ButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButtons.button(
      customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
      text: MyStrings.submit,
      height: 48,
      onTap: controller.onSubmitPressed, //controller.onLoginPressed,
      margin: const EdgeInsets.symmetric(horizontal: 18),
    );
  }
}

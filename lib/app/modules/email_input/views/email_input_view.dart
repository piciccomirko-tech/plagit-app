import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/header_image_widget.dart';
import 'package:mh/app/common/widgets/welcome_back_text_widget.dart';
import 'package:mh/app/modules/email_input/widgets/email_field_widget.dart';
import 'package:mh/app/modules/email_input/widgets/submit_button_widget.dart';
import '../controllers/email_input_controller.dart';

class EmailInputView extends GetView<EmailInputController> {
  const EmailInputView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
        appBar: CustomAppbar.appbar(title: 'Forgot Password', context: context, centerTitle: true),
        body:  SingleChildScrollView(
          child: Column(
            children: [
              HeaderImageWidget(imageUrl: MyAssets.lottie.inputEmailLottie),
              const WelcomeBackTextWidget(subTitle: 'Please enter your valid email'),
              const SizedBox(height: 50),
              const EmailFieldWidget(),
              const SizedBox(height: 50),
              const SubmitButtonWidget()
            ],
          ),
        ));
  }
}

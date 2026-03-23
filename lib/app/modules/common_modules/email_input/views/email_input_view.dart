import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/header_image_widget.dart';
import 'package:mh/app/common/widgets/welcome_back_text_widget.dart';
import 'package:mh/app/modules/common_modules/email_input/widgets/email_field_widget.dart';
import 'package:mh/app/modules/common_modules/email_input/widgets/submit_button_widget.dart';
import '../../../../common/utils/exports.dart';
import '../controllers/email_input_controller.dart';

class EmailInputView extends GetView<EmailInputController> {
  const EmailInputView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
        appBar: CustomAppbar.appbar(
            title: MyStrings.forgotPassword.tr,
            context: context,
            centerTitle: true),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HeaderImageWidget(imageUrl: MyAssets.lottie.inputEmailLottie),
              WelcomeBackTextWidget(
                  subTitle: MyStrings.pleaseEnterYourValidEmail.tr),
              const SizedBox(height: 50),
              const EmailFieldWidget(),
              const SizedBox(height: 50),
              // Obx(() {
              //   return Visibility(
              //     visible: !controller.isEmailValid.value,
              //     child: Text(controller.tecClientEmailAddress.text.isNotEmpty? "Invlaid Email!!": "", style: TextStyle(color: Colors.red),));
              // }),
              Obx(() {
                return Visibility(
                  visible: !controller.isEmailValid.value,
                  child: Text(controller.isEmailEmpty.value? "": "Invlaid Email!!", style: TextStyle(color: Colors.red),));
              }),
              Obx(() {
                return Visibility(
                  visible: controller.isEmailValid.value,
                  child: const SubmitButtonWidget());
              }),
            ],
          ),
        ));
  }
}

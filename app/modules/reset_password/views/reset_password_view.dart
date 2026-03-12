import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/header_image_widget.dart';
import 'package:mh/app/common/widgets/welcome_back_text_widget.dart';
import 'package:mh/app/modules/reset_password/widgets/confirm_password_field_widget.dart';
import 'package:mh/app/modules/reset_password/widgets/new_password_field_widget.dart';

import '../controllers/reset_password_controller.dart';

class ResetPasswordView extends GetView<ResetPasswordController> {
  const ResetPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(title: 'Reset Password', context: context, centerTitle: true),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            children: [
              HeaderImageWidget(imageUrl: MyAssets.lottie.resetPasswordLottie),
              const WelcomeBackTextWidget(subTitle: 'Reset your password with strong characters'),
              const SizedBox(height: 50),
              const NewPasswordFieldWidget(),
              const SizedBox(height: 20),
              const ConfirmPasswordFieldWidget(),
              const SizedBox(height: 50),
              CustomButtons.button(
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                text: MyStrings.submit,
                height: 48,
                onTap: controller.onSubmitPressed, //controller.onLoginPressed,
                margin: const EdgeInsets.symmetric(horizontal: 18),
              )
            ],
          ),
        ),
      ),
    );
  }
}

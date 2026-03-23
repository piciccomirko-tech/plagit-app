import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/header_image_widget.dart';
import 'package:mh/app/common/widgets/welcome_back_text_widget.dart';
import 'package:mh/app/modules/common_modules/settings/widgets/button_widget.dart';
import 'package:mh/app/modules/common_modules/settings/widgets/current_password_field_widget.dart';
import 'package:mh/app/modules/common_modules/settings/widgets/new_password_field_widget.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar:
          CustomAppbar.appbar(title: MyStrings.settings.tr, context: context, centerTitle: true, visibleBack: true),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: EdgeInsets.all(10.0.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                HeaderImageWidget(
                    imageUrl: MyAssets.lottie.changePasswordLottie),
                 WelcomeBackTextWidget(
                    subTitle:   MyStrings.changeYourPasswordWithStrongCharacters.tr),
                const SizedBox(height: 50),
                const CurrentPasswordFieldWidget(),
            
                const SizedBox(height: 20),
                const NewPasswordFieldWidget(),
                const SizedBox(height: 50),
                const ButtonWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

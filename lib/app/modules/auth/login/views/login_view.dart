import 'package:flutter/gestures.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    Utils.setStatusBarColorColor(Theme.of(context).brightness);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned(
            left: -65.w,
            top: -100.h,
            child: _topLeftBg,
          ),
          Positioned(
            right: -75.w,
            bottom: -130.h,
            child: _bottomRightBg,
          ),
          Positioned(
            left: 0.w,
            right: 0.w,
            bottom: 50.h,
            child: _dontHaveAnAccount,
          ),
          _mainContent,
        ],
      ),
    );
  }

  Widget get _mainContent => Form(
        key: controller.formKey,
        child: Column(
          children: [
            SizedBox(height: 60.h),
            Image.asset(
              MyAssets.logo,
              width: 112.w,
              height: 100.h,
            ),
            SizedBox(height: 45.h),
            _welcomeBack,
            SizedBox(height: 51.h),
            _userIdField,
            SizedBox(height: 34.h),
            _passwordField,
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_rememberMeWidget, _forgotPassword],
            ),
            SizedBox(height: 57.h),
            CustomButtons.button(
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: MyStrings.login.tr,
              height: 48,
              onTap: controller.onLoginPressed,
              margin: const EdgeInsets.symmetric(horizontal: 18),
            ),
          ],
        ),
      );

  Widget get _topLeftBg => Container(
        width: 180.w,
        height: 180.h,
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          shape: BoxShape.circle,
        ),
      );

  Widget get _welcomeBack => Text(
        MyStrings.welcomeBack.tr,
        style: MyColors.l111111_dwhite(controller.context!).semiBold22,
      );

  Widget get _userIdField => Obx(() => CustomTextInputField(
        controller: controller.tecUserId.value,
        label: MyStrings.userNameEmailId.tr,
        prefixIcon: Icons.person,
        validator: (String? value) => Validators.emptyValidator(
          value,
          MyStrings.required.tr,
        ),
      ));

  Widget get _passwordField => Obx(() => CustomTextInputField(
        controller: controller.tecPassword.value,
        label: MyStrings.password.tr,
        prefixIcon: Icons.lock,
        isPasswordField: true,
        validator: (String? value) => Validators.emptyValidator(
          value,
          MyStrings.required.tr,
        ),
      ));

  Widget get _forgotPassword => Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: 18.w),
          child: InkWell(
            onTap: () => Get.toNamed(Routes.emailInput),
            child: Text(
              MyStrings.forgotPassword.tr,
              style: MyColors.c_C6A34F.semiBold16,
            ),
          ),
        ),
      );

  Widget get _dontHaveAnAccount => Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            text: "${MyStrings.dontHaveAnAccount.tr}  ",
            style: MyColors.l50555C_dtext(controller.context!).regular16,
            children: [
              TextSpan(
                text: MyStrings.register.tr,
                style: const TextStyle(
                  color: MyColors.c_C6A34F,
                  fontFamily: MyAssets.fontMontserrat,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()..onTap = controller.onRegisterPressed,
              )
            ],
          ),
        ),
      );

  Widget get _bottomRightBg => Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: Theme.of(controller.context!).cardColor,
          shape: BoxShape.circle,
        ),
      );

  Widget get _rememberMeWidget => Obx(() => Padding(
        padding: EdgeInsets.only(left: 5.w),
        child: Row(
          children: [
            Checkbox(
                activeColor: MyColors.c_C6A34F,
                checkColor: MyColors.c_FFFFFF,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2.0),
                ),
                side: MaterialStateBorderSide.resolveWith(
                  (Set<MaterialState> states) => const BorderSide(width: 2.0, color: MyColors.c_C6A34F),
                ),
                value: controller.rememberMe.value,
                onChanged: controller.onRememberMePressed),
            Text(MyStrings.rememberMeText, style: MyColors.l111111_dwhite(controller.context!).semiBold15),
          ],
        ),
      ));
}

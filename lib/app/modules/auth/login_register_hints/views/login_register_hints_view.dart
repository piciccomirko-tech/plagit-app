import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/bottom_curve_path.dart';
import '../../../../common/widgets/horizontal_divider_with_text.dart';
import '../controllers/login_register_hints_controller.dart';

class LoginRegisterHintsView extends GetView<LoginRegisterHintsController> {
  const LoginRegisterHintsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    Utils.setStatusBarColorColor(Theme.of(context).brightness);

    return WillPopScope(
      onWillPop: () => Utils.appExitConfirmation(context),
      child: Scaffold(
        body: Stack(
          children: [

            Image.asset(
              MyAssets.loginRegisterHintsBg,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.fill,
            ),

            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: CurvePainter(Theme.of(context).cardColor),
              ),
            ),

            Positioned(
              left: -65.w,
              top: -100.h,
              child: _topLeftBg(context),
            ),

            Positioned(
              right: 10.w,
              top: 50.h,
              child: _skipButton(context),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _mainContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _mainContent => Column(
        children: [
          Image.asset(
            MyAssets.logo,
            width: 173.w,
            height: 155.h,
          ),

          SizedBox(height: 48.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 37.0.w),
            child: HorizontalDividerWithText(
              text: MyStrings.premierStaffingSolutions.tr,
            ),
          ),

          SizedBox(height: 48.h),

          CustomButtons.button(
            text: MyStrings.login.tr,
            onTap: controller.onLoginPressed,
            height: 48,
            fontSize: 16.sp,
          ),

          SizedBox(height: 27.h),

          CustomButtons.button(
            text: MyStrings.signUp.tr,
            onTap: controller.onSignUpPressed,
            customButtonStyle: CustomButtonStyle.outline,
            height: 48,
            fontSize: 16.sp,
            context: controller.context,
          ),

          SizedBox(height: 60.h),
        ],
      );

  Widget _skipButton(BuildContext context) => GestureDetector(
        onTap: controller.onSkipPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: MyColors.lightCard(context),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              MyStrings.skip.tr,
              style: MyColors.l111111_dtext(context).regular14,
            ),
          ),
        ),
      );

  Widget _topLeftBg(BuildContext context) => Container(
        width: 180.w,
        height: 180.h,
        decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          shape: BoxShape.circle,
        ),
      );
}

// class LoginRegisterHintsView extends GetResponsiveView<LoginRegisterHintsController> {
//   LoginRegisterHintsView({Key? key})
//       : super(
//           settings: MyConstantValue.responsiveScreenSettings,
//           key: key,
//         );
//
//   @override
//   Widget? phone() {
//     return const LoginRegisterHintsViewPhone();
//   }
//
//   @override
//   Widget? tablet() {
//     return const LoginRegisterHintsViewTablet();
//   }
//
//   @override
//   Widget? desktop() {
//     return const LoginRegisterHintsViewTablet();
//   }
//
//   @override
//   Widget? watch() {
//     return Text(MyStrings.deviceNotSupport.tr);
//   }
// }

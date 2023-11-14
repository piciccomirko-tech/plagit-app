import 'package:lottie/lottie.dart';

import '../../../../common/utils/exports.dart';
import '../controllers/employee_register_success_controller.dart';

class EmployeeRegisterSuccessView extends GetView<EmployeeRegisterSuccessController> {
  const EmployeeRegisterSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Utils.appExitConfirmation(context),
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: Get.height * .05),

                Expanded(
                  flex: 2,
                  child: Lottie.asset(
                    MyAssets.lottie.registrationDone,
                  ),
                ),

                SizedBox(height: Get.height * .05),

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Congratulation!",
                    style: MyColors.c_C6A34F.semiBold22.copyWith(
                      fontSize: 30.sp,
                    ),
                  ),
                ),

                SizedBox(height: Get.height * .05),

                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Register successfully",
                        style: MyColors.l111111_dwhite(context).medium20,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        controller.appController.user.value.isClient
                            ? "Welcome to MH premier staffing solution"
                            : "Our HR contact with you within 24 Hours",
                        textAlign: TextAlign.center,
                        style: MyColors.l7B7B7B_dtext(context).regular15,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: CustomButtons.button(
                      text: "Get Started",
                      onTap: controller.onGetStartedClick,
                      customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

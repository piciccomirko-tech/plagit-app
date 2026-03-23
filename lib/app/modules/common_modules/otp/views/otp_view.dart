import 'package:flutter/gestures.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/header_image_widget.dart';
import 'package:mh/app/common/widgets/welcome_back_text_widget.dart';
import 'package:mh/app/modules/common_modules/otp/widgets/otp_field_widget.dart';
import '../controllers/otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(title:  MyStrings.otpCheck.tr, context: context, centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.0.sp),
          child: Column(
            children: [
              HeaderImageWidget(imageUrl: MyAssets.lottie.otpCheckLottie),
               WelcomeBackTextWidget(subTitle: MyStrings.pleaseEnterValidOtpToVerify.tr),
              const SizedBox(height: 50),
              const OtpFieldWidget(),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(() => InkWell(
                        onTap: () => controller.disableButton.value == false ? controller.verifyOtpPressed() : null,
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor:
                              controller.disableButton.value == false ? MyColors.c_C6A34F : MyColors.c_D9D9D9,
                          child: Icon(Icons.arrow_forward_ios_sharp, color: Get.theme.scaffoldBackgroundColor),
                        ),
                      ))
                ],
              ),
              const SizedBox(height: 50),
              Obx(() => controller.isFinished.value == true
                  ? Center(
                      child: RichText(
                        text: TextSpan(
                          text:  MyStrings.haventYouGottenOtpYet.tr,
                          style: MyColors.l5C5C5C_dwhite(context).medium16,
                          children: [
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: MyStrings.resend.tr,
                              style: MyColors.l5C5C5C_dwhite(context).semiBold16,
                              recognizer: TapGestureRecognizer()..onTap = () => controller.resendOtpPressed(),
                            )
                          ],
                        ),
                      ),
                    )
                  : Center(
                      child: RichText(
                        text: TextSpan(
                          text:   MyStrings.otpWillBeSentWithin.tr,
                          style: MyColors.l5C5C5C_dwhite(context).medium15,
                          children: [
                            const TextSpan(text: ' '),
                            TextSpan(
                              text: '${controller.countdown.value}',
                              style: MyColors.c_C6A34F.semiBold20,
                              recognizer: TapGestureRecognizer()..onTap = () => () {},
                            ),
                            TextSpan(
                              text:   MyStrings.seconds.tr,
                              style: MyColors.l5C5C5C_dwhite(context).medium15,
                              recognizer: TapGestureRecognizer()..onTap = () => () {},
                            ),
                          ],
                        ),
                      ),
                    ))
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:developer';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/client_edit_profile_controller.dart';
import '../widgets/client_bank_form_widget.dart';
import '../widgets/client_business_form_widget.dart';
import '../widgets/bank_card_widget_for_client.dart';
import '../widgets/client_profile_form_widget.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/steps_row_widget.dart';

class ClientEditProfileView extends GetView<ClientEditProfileController> {
  const ClientEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.myProfile.tr,
        context: context,
        centerTitle: true,
        onBackButtonPressed: () {
          controller.profileFormKeyClient = GlobalKey<FormState>();
          controller.businessFormKeyClient = GlobalKey<FormState>();
          controller.bankFormKeyClient = GlobalKey<FormState>();

          log("Back pressed");
          Get.delete<
              ClientEditProfileController>(); // Deletes the controller instance
          Get.back(); // Navigate back
          // Optionally navigate back if required
          //Get.back();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                double progress;
                switch (controller.currentStep.value) {
                  case 0:
                    progress = 30;
                    break;
                  case 1:
                    progress = 50;
                    break;
                  case 2:
                    progress = 70;
                    break;
                  case 3:
                    progress = 100;
                    break;
                  default:
                    progress = 0;
                }
                return ClientProgressIndicatorWidget(
                  progress: progress / 100,
                  message: controller.getProgressMessage(),
                );
              }),
              const SizedBox(height: 20),
              Obx(() => StepsRowWidget(
                    currentStep: controller.currentStep.value,
                    progress: (controller.currentStep.value + 1) * 25.0,
                    onStepTapped: (int stepIndex) {
                      if (stepIndex <= controller.currentStep.value) {
                        controller.currentStep.value = stepIndex;
                        controller.getPublicUserDetails();
                      }
                    },
                  )),
              SizedBox(
                height: 10.h,
              ),
              Divider(
                color: MyColors.primaryLight,
                height: 2,
              ),
              const SizedBox(height: 20),
              Obx(() {
                controller.switchFormKey(controller.currentStep.value);
                switch (controller.currentStep.value) {
                  case 0:
                    return Form(
                      key: controller.profileFormKeyClient,
                      child: ClientProfileFormWidget(),
                    );
                  case 1:
                    // return CardFormWidget();
                    return BankCardWidgetForClient();
                  case 2:
                    return Form(
                      key: controller.businessFormKeyClient,
                      child: ClientBusinessFormWidget(),
                    );
                  case 3:
                    return Form(
                      key: controller.bankFormKeyClient,
                      child: ClientBankFormWidget(),
                    );
                  default:
                    return Form(
                      key: controller.profileFormKeyClient,
                      child: ClientProfileFormWidget(),
                    );
                }
              }),
              const SizedBox(height: 30),
              Obx(() {
                return Row(
                  children: [
                    if (controller.currentStep.value > 0 && controller.isButtonVisible.value)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CustomButtons.button(
                            height: 48.h,
                            text: "Previous",
                            margin: EdgeInsets.zero,
                            fontSize: 17.sp,
                            customButtonStyle:
                                CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.prevStep,
                          ),
                        ),
                      ),
                 if(controller.isButtonVisible.value)   Expanded(
                      child: CustomButtons.button(
                        height: 48.h,
                        text: controller.currentStep.value < 3 
                            ? "Save & Next"
                            : "Submit",
                        margin: EdgeInsets.zero,
                        fontSize: 17.sp,
                        customButtonStyle:
                            CustomButtonStyle.radiusTopBottomCorner,
                        onTap: () async {
                          if (controller.currentStep.value <= 3) {
                            // controller.nextStep();
                            if (controller.currentStep.value == 0) {
                              bool success =
                                  await controller.onProfileUpdatePressed();
                              if (success) {
                                // controller.nextStep();
                                // instead of here, nextstep handled from controller 
                              }
                              // controller.nextStep();
                            } else if (controller.currentStep.value == 1) {
                              // card update
                              // controller.onUpdateClientBank();
                              controller.nextStep();
                            } else if (controller.currentStep.value == 2) {
                              if (!controller.isAddiEmailValid.value &&
                                  controller.tecAdditionalEmailAddress.text
                                      .isNotEmpty) {
                                Utils.showSnackBar(
                                    message: "Invalid additional Email",
                                    isTrue: false);
                              } else {
                                bool success =
                                    await controller.onBusinessUpdatePressed();
                                if (success) {
                                  controller.nextStep();
                                }
                                controller.nextStep();
                              }
                            } else if (controller.currentStep.value == 3) {
                              bool bankSuccess =
                                  await controller.onUpdateClientBank();
                              if (bankSuccess) {
                                controller.nextStep();
                           //  Get.delete<ClientEditProfileController>();
                                //Get.back();
                             Get.offAllNamed(Routes.clientPremiumRoot);

                              }
                              //  Get.back();
                            }
                            // // controller.nextStep();
                            // controller.nextStep();
                            // controller.nextStep();
                          } else {
                            print('Form Submitted');
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../enums/custom_button_style.dart';
import '../../../../routes/app_pages.dart';
import '../../employee_home/controllers/employee_home_controller.dart';
import '../controllers/employee_edit_profile_controller.dart';
import '../widgets/bank_card_widget_for_employee.dart';
import '../widgets/candidate_additional_form_widget.dart';
import '../widgets/candidate_bank_form_widget.dart';
import '../widgets/candidate_profile_form.dart';
import '../widgets/candidate_progress_indicator_widget.dart';
import '../widgets/candidate_steps_widget.dart';

class EmployeeEditProfileView extends GetView<EmployeeEditProfileController> {
  const EmployeeEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.myProfile.tr,
        context: context,
        centerTitle: true,
        onBackButtonPressed: () async {
          // Find the EmployeeHomeController instance
          final employeeHomeController = Get.find<EmployeeHomeController>();

          // Call getProfileCompletion with the user ID
       await   employeeHomeController.getProfileCompletion(
              Get.find<AppController>().user.value.userId);
await employeeHomeController.getPublicEmployeeDetails();
          // Optionally navigate back if required
          Get.back();
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context)
                  .size
                  .height, // Ensure it doesn't take infinite height
            ),
            child: IntrinsicHeight(
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
                    return CandidateProgressIndicatorWidget(
                      progress: progress / 100,
                      message: controller.getProgressMessage(),
                    );
                  }),
                  SizedBox(height: 15.w),
                  Obx(() => CandidateStepsRowWidget(
                        currentStep: controller.currentStep.value,
                        progress: (controller.currentStep.value + 1) * 25.0,
                        onStepTapped: (int stepIndex) {
                          if (stepIndex <= controller.currentStep.value) {
                            controller.currentStep.value = stepIndex;
                            controller.getDetails();
                          }
                        },
                      )),
                  SizedBox(
                    height: 15.h,
                  ),
                  Divider(height: 3, color: MyColors.primaryLight),
                  SizedBox(
                    height: 20.h,
                  ),
                  Obx(() {
                    // controller.switchFormKey(controller.currentStep.value);
                    switch (controller.currentStep.value) {
                      case 0:
                        return Form(
                          key: controller.profileFormKeyEmployee,
                          child: CandidateProfileFormWidget(),
                        );
                      case 1:
                        return Form(
                          key: controller.bankFormKeyEmployee,
                          child: CandidateBankFormWidget(),
                        );

                      case 2:
                        return Form(
                          key: controller.additionalFormKeyEmployee,
                          child: CandidateAdditionalFormWidget(),
                        );

                      case 3:
                        return BankCardWidgetForCandidate();
                      default:
                        return Form(
                          key: controller.profileFormKeyEmployee,
                          child: CandidateProfileFormWidget(),
                        );
                    }
                  }),
                  SizedBox(height: 30.w),
                  Obx(() {
                    return Row(
                      children: [
                        if (controller.currentStep.value > 0  && controller.isButtonVisible.value)
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
                     if( controller.isButtonVisible.value)   Expanded(
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
                              // Handle step navigation logic
                              if (controller.currentStep.value == 2) {
                                // Simulate upload process
                                bool success = await controller
                                    .onAdditionalUpdatePressed();
                                if (success) {
                                  controller.nextStep();
                                }
                              } else {
                                // Handle logic for other steps
                                bool success = false;
                                if (controller.currentStep.value == 0) {
                                  success =
                                      await controller.onProfileUpdatePressed();
                                  if (success) {
                                    controller.nextStep();
                                  }
                                  controller.nextStep();
                                } else if (controller.currentStep.value == 1) {
                                  // bank details
                                  success =
                                      await controller.onUpdateCandidateBank();
                                  if (success) {
                                    controller.nextStep();
                                  }
                                } else {
                                  // Handle logic for last steps
                                  // Get.delete<EmployeeEditProfileController>();
                                  controller.getDetails();
                                // Get.back();
                                  // Utils.showSnackBar(message: "Profile Updated", isTrue: true);
                                 Get.offAllNamed(Routes.employeeRoot);
                                }
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
        ),
      ),
    );
  }

  // Function to show the progress dialog
  void _showProgressDialog(BuildContext context) {
    Future.delayed(
      Duration.zero,
      () {
        return Get.dialog(
          WillPopScope(
            onWillPop: () async =>
                false, // Prevent dialog from closing on back button
            child: Align(
              alignment: Alignment.center,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  height: Get.height * 0.3,
                  width: Get.width * 0.8, // Responsive width
                  decoration: BoxDecoration(
                    color: MyColors.c_C6A34F,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Obx(() => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upload Progress',
                              textAlign: TextAlign.center,
                              style: Get.width > 600
                                  ? MyColors.lwhite_d111111(context).semiBold15
                                  : MyColors.lwhite_d111111(context).semiBold22,
                            ),
                            SizedBox(height: 20.0.h),
                            CircularProgressIndicator(
                              value: controller.uploadPercent.value /
                                  100, // Show progress
                              backgroundColor: Colors.white,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            const SizedBox(height: 16.0),
                            Text(
                              '${controller.uploadPercent.value.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: MyColors.white,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ),
          ),
          barrierDismissible: false,
        );
      },
    );
  }
}

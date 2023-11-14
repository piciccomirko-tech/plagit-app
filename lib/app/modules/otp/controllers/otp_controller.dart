import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/email_input/models/forget_password_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/otp/models/otp_check_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class OtpController extends GetxController {
  RxBool disableButton = true.obs;
  final Rx<TextEditingController> tecOtp = TextEditingController().obs;
  RxInt countdown = 60.obs; // Initial countdown value
  RxBool isFinished = false.obs;
  BuildContext? context;
  late String email;

  final ApiHelper _apiHelper = Get.find();

  @override
  void onInit() {
    email = Get.arguments ?? '';
    super.onInit();
  }

  @override
  void onReady() {
    startCountdown();
    super.onReady();
  }

  void onPinCodeChange(String value) {
    if (value.length == 6) {
      disableButton.value = false;
    } else {
      disableButton.value = true;
    }
  }

  bool onBeforeTextPaste(String? value) {
    return false;
  }

  void verifyOtpPressed() async {
    CustomLoader.show(context!);
    OtpCheckRequestModel otpCheckRequestModel = OtpCheckRequestModel(email: email, otpNumber: tecOtp.value.text);

    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.otpCheck(otpCheckRequestModel: otpCheckRequestModel);
    CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CommonResponseModel res) {
      if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
        Utils.showSnackBar(message: '${res.message}', isTrue: true);
        Get.toNamed(Routes.resetPassword, arguments: email);
      } else {
        Utils.showSnackBar(message: '${res.message}', isTrue: false);
      }
    });
  }

  void resendOtpPressed() async {
    CustomLoader.show(context!);
    Either<CustomError, ForgetPasswordResponseModel> responseData = await _apiHelper.inputEmail(email: email);
    CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ForgetPasswordResponseModel res) {
      if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
        Utils.showSnackBar(message: '${res.message}', isTrue: true);
        isFinished.value = false;
        disableButton.value = true;
        countdown.value = 60;
        startCountdown();
      } else {
        Utils.showSnackBar(message: '${res.message}', isTrue: false);
      }
    });
  }

  void startCountdown() {
    const Duration oneSecond = Duration(seconds: 1);

    Timer.periodic(oneSecond, (Timer timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isFinished.value = true;
        timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }
}

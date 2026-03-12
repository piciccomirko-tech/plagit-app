import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/email_input/models/forget_password_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmailInputController extends GetxController {
  TextEditingController tecClientEmailAddress = TextEditingController();
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  @override
  void onClose() {
    tecClientEmailAddress.dispose();
    super.onClose();
  }

  void onSubmitPressed() async {
    Utils.unFocus();
    if (tecClientEmailAddress.text.isEmpty) {
      Utils.showSnackBar(message: 'Email is required', isTrue: false);
    }
    CustomLoader.show(context!);
    Either<CustomError, ForgetPasswordResponseModel> responseData =
        await _apiHelper.inputEmail(email: tecClientEmailAddress.text);
    CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ForgetPasswordResponseModel res) {
      if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
        Utils.showSnackBar(message: '${res.message}', isTrue: true);
        if (res.user?.toLowerCase() == 'client') {
          Get.toNamed(Routes.otp, arguments: tecClientEmailAddress.text);
        } else {
          Get.offAllNamed(Routes.login);
        }
      } else {
        Utils.showSnackBar(message: '${res.message}', isTrue: false);
      }
    });
  }
}

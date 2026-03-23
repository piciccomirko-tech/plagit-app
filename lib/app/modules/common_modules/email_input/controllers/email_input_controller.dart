
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/common_modules/email_input/models/forget_password_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';

class EmailInputController extends GetxController {
  TextEditingController tecClientEmailAddress = TextEditingController();
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();
  final RxBool isEmailValid = false.obs;
  final RxBool isEmailEmpty = true.obs;
  @override
  void onClose() {
    tecClientEmailAddress.dispose();
    super.onClose();
  }
bool isValidEmail(String email) {
  final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}
  void validateEmail(String email) {
    isEmailValid.value = isValidEmail(email);
  }

  @override
  void onInit() {
    super.onInit();
    // Listen for changes in the email text field
    tecClientEmailAddress.addListener(() {
      isEmailEmpty.value=tecClientEmailAddress.text.isEmpty;
      validateEmail(tecClientEmailAddress.text);
      // log("email validated? ${isEmailValid.value}");
    });
  }
  void onSubmitPressed() async {
    Utils.unFocus();
    if (tecClientEmailAddress.text.isEmpty) {
      Utils.showSnackBar(message:  MyStrings.emailIsRequired.tr, isTrue: false);
    }
    CustomLoader.show(context!);
    Either<CustomError, ForgetPasswordResponseModel> responseData =
        await _apiHelper.inputEmail(email: tecClientEmailAddress.text);
    CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ForgetPasswordResponseModel res) {
          //log("resss: ${res.errors?.first?.msg}");
      if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
        Utils.showSnackBar(message: '${res.message}', isTrue: true);
        if (res.user?.toLowerCase() == 'client') {
          Get.toNamed(Routes.otp, arguments: tecClientEmailAddress.text);
        } else {
          Get.offAllNamed(Routes.login);
        }
      } else {
                    res.message!=null?
            Utils.showSnackBar(message: '${res.message}', isTrue: false):
            Utils.showSnackBar(message: '${res.errors!.first.msg}', isTrue: false);
        // Utils.showSnackBar(message: '${res.message}', isTrue: false);
      }
    });
  }
}

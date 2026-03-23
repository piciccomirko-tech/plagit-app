
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/common_modules/reset_password/models/reset_password_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class ResetPasswordController extends GetxController {
  Rx<TextEditingController> tecConfirmPassword = TextEditingController().obs;
  Rx<TextEditingController> tecNewPassword = TextEditingController().obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  String email = '';

  @override
  void onInit() {
    email = Get.arguments ?? '';
    super.onInit();
  }

  @override
  void onClose() {
    tecConfirmPassword.value.dispose();
    tecNewPassword.value.dispose();
    super.onClose();
  }
bool isValidEmail(String email) {
  final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}
  void onSubmitPressed() async {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (tecNewPassword.value.text != tecConfirmPassword.value.text) {
        Utils.showSnackBar(
            message: MyStrings.newPasswordAndConfirmPasswordShouldBeSame.tr,
            isTrue: false);
      } else {
        CustomLoader.show(context!);
        ResetPasswordRequestModel resetPasswordRequestModel =
            ResetPasswordRequestModel(
                email: email, password: tecNewPassword.value.text);

        Either<CustomError, CommonResponseModel> responseData =
            await _apiHelper.resetPassword(
                resetPasswordRequestModel: resetPasswordRequestModel);
        CustomLoader.hide(context!);
        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (CommonResponseModel res) {
      
          if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
            Utils.showSnackBar(message: '${res.message}', isTrue: true);
            Get.offAllNamed(Routes.login);
          } else {
            res.message != null
                ? Utils.showSnackBar(message: '${res.message}', isTrue: false)
                : Utils.showSnackBar(
                    message: '${res.errors!.first.msg}', isTrue: false);
            // Utils.showSnackBar(message: '${res.message}', isTrue: false);
          }
        });
      }
    }
  }
}

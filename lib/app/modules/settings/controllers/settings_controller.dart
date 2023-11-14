import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/settings/models/change_password_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class SettingsController extends GetxController {
  Rx<TextEditingController> tecCurrentPassword = TextEditingController().obs;
  Rx<TextEditingController> tecNewPassword = TextEditingController().obs;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();


  @override
  void onClose() {
    tecCurrentPassword.value.dispose();
    tecNewPassword.value.dispose();
    super.onClose();
  }

  void onSubmitPressed() async {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (tecNewPassword.value.text == tecCurrentPassword.value.text) {
        Utils.showSnackBar(message: 'New password and current password should not be same', isTrue: false);
      } else {
        CustomLoader.show(context!);
        ChangePasswordRequestModel changePasswordRequestModel = ChangePasswordRequestModel(
            id: Get.find<AppController>().user.value.client?.id ?? '',
            newPassword: tecNewPassword.value.text,
            currentPassword: tecCurrentPassword.value.text);

        Either<CustomError, CommonResponseModel> responseData =
            await _apiHelper.changePassword(changePasswordRequestModel: changePasswordRequestModel);
        CustomLoader.hide(context!);
        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (CommonResponseModel res) {
          if (res.status == 'success' && [200, 201].contains(res.statusCode)) {
            Utils.showSnackBar(message: '${res.message}', isTrue: true);
            Get.find<AppController>().onLogoutClick();
          } else {
            Utils.showSnackBar(message: '${res.message}', isTrue: false);
          }
        });
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';

import '../../../../routes/app_pages.dart';
import '../interface/login_register_hints_interface.dart';

class LoginRegisterHintsController extends GetxController implements LoginRegisterHintsInterface {

  BuildContext? context;

  final AppController _appController = Get.find();

  @override
  void onLoginPressed() {
    Get.toNamed(Routes.login);
  }

  @override
  void onSignUpPressed() {
    Get.toNamed(Routes.register);
  }

  @override
  void onSkipPressed() {
    _appController.enterAsGuestMode();
  }
}

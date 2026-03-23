import 'package:flutter/material.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../../../common/utils/exports.dart';
import '../controllers/login_register_hints_controller.dart';

class LoginRegisterHintsView extends GetView<LoginRegisterHintsController> {
  const LoginRegisterHintsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    Utils.setStatusBarColorColor(Theme.of(context).brightness);

    return Scaffold(
  backgroundColor: Colors.red,
  body: const Center(
    child: Text(
      'TEST PHONE FILE',
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);
            
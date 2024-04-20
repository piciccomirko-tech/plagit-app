import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';

import '../controllers/policy_controller.dart';

class PolicyView extends GetView<PolicyController> {
  const PolicyView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(title: "Policy", context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomRadioButton(
                  autoWidth: true,
                  shapeRadius: 5,
                  elevation: 0.0,
                  height: 45,
                  defaultSelected: 1,
                  enableShape: true,
                  selectedBorderColor: Colors.transparent,
                  unSelectedBorderColor: Colors.transparent,
                  buttonLables: controller.policyLabels,
                  buttonValues: controller.policyValue,
                  radioButtonValue: controller.onButtonTapped,
                  unSelectedColor: MyColors.c_C6A34F.withOpacity(0.2),
                  selectedColor: MyColors.c_C6A34F),
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Obx(() => Text(controller.policyText.value, style: MyColors.l111111_dwhite(context).medium15)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

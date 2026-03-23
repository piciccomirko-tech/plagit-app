import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../controllers/client_edit_profile_controller.dart';

class ClientBankFormWidget extends GetWidget<ClientEditProfileController> {
  const ClientBankFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading.value
        ? CustomLoader.loading()
        : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextInputField(
              padding: EdgeInsets.all(0),
              controller: controller.tecBankName,
              label: 'Bank Name',
              prefixIcon: Icons.account_balance,
              // isRequired: true,
            ),
            const SizedBox(height: 20),
            CustomTextInputField(
              padding: EdgeInsets.all(0),
              controller: controller.tecAccountNumber,
              label: 'Account Number',
              prefixIcon: Icons.format_list_numbered,
            ),
            const SizedBox(height: 20),
            CustomTextInputField(
              padding: EdgeInsets.all(0),
              controller: controller.tecShortCode,
              label: 'Short Code',
              prefixIcon: Icons.code,
            ),
            const SizedBox(height: 20),
            // CustomTextInputField(
            //   padding: EdgeInsets.all(0),
            //   controller: controller.tecAdditionalOne,
            //   label: 'Additional One',
            //   prefixIcon: Icons.info_outline,
            // ),
            // const SizedBox(height: 20),
            // CustomTextInputField(
            //   padding: EdgeInsets.all(0),
            //   controller: controller.tecAdditionalTwo,
            //   label: 'Additional Two',
            //   prefixIcon: Icons.info_outline,
            // ),
            // const SizedBox(height: 20),
          ],
        ));
  }
}

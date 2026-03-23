import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../controllers/employee_edit_profile_controller.dart';

class CandidateBankFormWidget extends GetWidget<EmployeeEditProfileController> {
  const CandidateBankFormWidget({super.key});


  @override
  Widget build(BuildContext context) {
    return  Obx(() => controller.loading.value == true
        ? Center(child: CustomLoader.loading())
        :  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         CustomTextInputField(
          controller: controller.tecBankName,
          label: 'Bank Name',
          prefixIcon: Icons.account_balance,
          // isRequired: true,
        ),
        const SizedBox(height: 20),
        
        CustomTextInputField(
          controller: controller.tecAccountNumber,
          label: 'Account Number',
          prefixIcon: Icons.format_list_numbered,
        ),
        const SizedBox(height: 20),
        
        CustomTextInputField(
          controller: controller.tecShortCode,
          label: 'Short Code',
          prefixIcon: Icons.code,
        ),
        const SizedBox(height: 20),
        
        // CustomTextInputField(
        //   controller: controller.tecAdditionalOne,
        //   label: 'Additional One',
        //   prefixIcon: Icons.info_outline,
        // ),
        // const SizedBox(height: 20),
        
        // CustomTextInputField(
        //   controller: controller.tecAdditionalTwo,
        //   label: 'Additional Two',
        //   prefixIcon: Icons.info_outline,
        // ),
        // const SizedBox(height: 20),
          ],
        ));
  }
}

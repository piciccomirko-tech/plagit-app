import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../controllers/client_edit_profile_controller.dart';

class ClientBusinessFormWidget extends GetWidget<ClientEditProfileController> {
  const ClientBusinessFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.loading.value
        ? CustomLoader.loading()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.companyName,
                    label: 'Company Name',
                    prefixIcon: Icons.business,
                    // isRequired: true,
                  ),
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.tecVatNumber,
                    label: 'VAT Number',
                    prefixIcon: Icons.receipt,
                  ),
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.tecCompanyRegistration,
                    label: 'Company Registration Number',
                    prefixIcon: Icons.fact_check,
                  ),
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.tecEmergencyContactNumber,
                    label: 'Emergency Contact Number',
                    prefixIcon: Icons.phone_in_talk,
                    // isRequired: true,
                  ),
                  const SizedBox(height: 20),
                  CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.tecAdditionalEmailAddress,
                    label: 'Additional Email Address',
                    prefixIcon: Icons.email_outlined,
                    isValid: controller.isAddiEmailValid.value || controller.tecAdditionalEmailAddress.text.isEmpty ,
                    onChange: (addiEmail) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      controller.isAddiEmailValid.value= emailRegex.hasMatch(addiEmail);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              )
            ],
          ));
  }
}

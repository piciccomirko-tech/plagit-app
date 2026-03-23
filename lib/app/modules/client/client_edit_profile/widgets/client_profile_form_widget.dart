import 'dart:developer';

import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import '../../../../common/data/data.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dropdown.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../controllers/client_edit_profile_controller.dart';
import 'client_profile_picture.dart';

class ClientProfileFormWidget extends GetWidget<ClientEditProfileController> {
  const ClientProfileFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() =>  controller.loading.value
        ? CustomLoader.loading()
        : _profileForm());
  }

  // Profile Form
  Widget _profileForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: ProfileImageUploadWidget()),
        SizedBox(height: 20),
        CustomTextInputField(
          padding: EdgeInsets.all(0),
          controller: controller.tecClientName,
          label: MyStrings.businessName.tr,
          prefixIcon: Icons.add_business,
          // isRequired: true,
        ),
        const SizedBox(height: 20),
        CustomTextInputField(
          padding: EdgeInsets.all(0),
          controller: controller.tecRestaurantAddress,
          label: MyStrings.businessAddress.tr,
          isMapField: true,
          readOnly: true,
          onSuffixPressed: () =>
              controller.onClientAddressPressed(module: "clientEditProfile"),
          prefixIcon: Icons.location_on,
        ),
        const SizedBox(height: 20),
        IntlPhoneField(
          controller: controller.tecPhoneNumber,
          style: MyColors.l111111_dwhite(Get.context!).regular17,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            labelStyle: MyColors.lC6A34F_primaryLight(Get.context!).regular17,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(),
            ),
          ),
          dropdownTextStyle: MyColors.l111111_dwhite(Get.context!).regular17,
          initialCountryCode: controller.initialCountryCode.value,
          onCountryChanged: (country) {
            controller.initialCountryCode.value = country.code;
            controller.initialDialCode.value = "+${country.dialCode}";
            if (country.name.contains("Campione d'Italia") ||
                country.name.contains("Italia") ||
                country.name.contains("Ital")) {
              controller.initialDialCode.value = "+39";
           //   log("modified dial code : ${controller.initialDialCode}");
            }
             log("Selected country: ${country.name} with dial code: ${controller.initialDialCode.value}");
          //  print(" country dialcode=> +${country.dialCode}");
           // log("country : ${country.name}");
          },
        ),
        const SizedBox(height: 20),
        CustomTextInputField(
          padding: EdgeInsets.all(0),
          controller: controller.tecEmailAddress,
          label: 'Email Address',
          prefixIcon: Icons.email,
        ),
        const SizedBox(height: 20),
        CustomDropdown(
          padding: EdgeInsets.all(0),
          prefixIcon: Icons.flag,
          hints: MyStrings.country.tr,
          value: controller.clientCountry.value,
          items: Data.getAllCountry.map((e) => e.name).toList(),
          // items: ['United Kingdom', 'USA', 'India', 'Canada'],
          onChange: onClientCountryChange,
        ),
      ],
    );
  }

  // Handle changes to the country dropdown
  void onClientCountryChange(String? value) {
    if (value != null && value.isNotEmpty) {
      controller.clientCountry.value = value;
      controller.isClientCountryValid.value = true;
    } else {
      controller.isClientCountryValid.value = false;
    }
  }
}

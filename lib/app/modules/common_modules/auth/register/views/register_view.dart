import 'package:dropdown_search/dropdown_search.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mh/app/common/data/data.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_checkbox.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/enums/user_type.dart';
import '../../../../../common/utils/exports.dart';
import '../../../../../models/dropdown_item.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    Utils.setStatusBarColorColor(Theme.of(context).brightness);
    return SafeArea(
      child: Scaffold(
        extendBody: false,
        body: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              Positioned(
                left: -65.w,
                top: -100.h,
                child: _topLeftBg,
              ),
              Positioned(
                right: -75.w,
                bottom: -130.h,
                child: _bottomRightBg,
              ),
              _mainContent,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _mainContent => SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              MyAssets.logo,
              width: 100.w,
              height: 100.w,
            ),
            SizedBox(height: 30.h),
            _userType,
            SizedBox(height: 20.h),

            // LoginWithWidget(
            //     title: "Register with", socialLogin: controller.socialLogin),
            ExpandablePageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChange,
              children: [
                _clientInputFields(),
                _employeeInputFields,
              ],
            ),
            SizedBox(height: 20.h),
            _agreeTermsAndCondition,
            SizedBox(height: 20.h),
            CustomButtons.button(
              height: 48.h,
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: MyStrings.register.tr,
              onTap: controller.onContinuePressed,
              margin: EdgeInsets.symmetric(horizontal: 18.sp),
            ),
            SizedBox(height: 20.h),
            _alreadyHaveAnAccount,
            SizedBox(height: 52.h),
          ],
        ),
      );

  Widget get _topLeftBg => Container(
        width: 180.w,
        height: 180.h,
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          shape: BoxShape.circle,
        ),
      );

  Widget get _userType => Container(
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        padding: const EdgeInsets.symmetric(horizontal: 7),
        height: 54.h,
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Obx(
          () => Row(
            children: [
              _userItem(UserType.client,
                  controller.userType.value == UserType.client),
              _userItem(UserType.employee,
                  controller.userType.value == UserType.employee),
            ],
          ),
        ),
      );

  Widget _userItem(UserType userType, bool active) => Expanded(
        child: GestureDetector(
          onTap: () => controller.onUserTypeClick(userType),
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: active
                  ? MyColors.c_C6A34F
                  : MyColors.lightCard(controller.context!),
            ),
            child: Center(
              child: Text(
                (userType.name.capitalize ?? "") == "Employee"
                    ? "Candidate"
                    : (userType.name.capitalize == "Client"
                        ? "Business"
                        : "" ?? ""),
                style: active
                    ? MyColors.lightCard(controller.context!).semiBold17
                    : MyColors.darkCard(controller.context!).semiBold17,
              ),
            ),
          ),
        ),
      );

  Widget _clientInputFields() => Obx(() => Form(
        key: controller.formKeyClient,
        child: Column(
          children: [
            SizedBox(height: 15.h),
            CustomTextInputField(
              controller: controller.tecClientName,
              label: MyStrings.businessName.tr,
              prefixIcon: Icons.add_business,
              validator: (String? value) => Validators.emptyValidator(
                controller.tecClientName.value.text,
                MyStrings.required.tr,
              ),
              // isRequired: true,
              isValid: controller.isClientNameValid.value,
              onChange: (value) {
                // Update the validation flag
                controller.isClientNameValid.value = value.isNotEmpty;
              },
            ),
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecClientAddress,
              label: MyStrings.businessAddress.tr,
              prefixIcon: Icons.location_on_rounded,
              isMapField: true,
              onSuffixPressed: () =>
                  controller.onClientAddressPressed(module: "client"),
              readOnly: controller.restaurantAddressFromMap.value.isEmpty ||
                  controller.restaurantLat == 0 ||
                  controller.restaurantLong == 0,
              onTap: (controller.restaurantAddressFromMap.value.isEmpty ||
                      controller.restaurantLat == 0 ||
                      controller.restaurantLong == 0)
                  ? () => controller.onClientAddressPressed(module: "client")
                  : null,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
              // isRequired: true,
              isValid: controller.isClientAddressValid.value ||
                  controller.tecClientAddress.text.isEmpty,
              onChange: (value) {
                // Update the validation flag
                print("address set");
                controller.isClientAddressValid.value = value.isNotEmpty;
              },
            ),

            Visibility(
              visible: !(controller.restaurantAddressFromMap.value.isEmpty ||
                  controller.restaurantLat == 0 ||
                  controller.restaurantLong == 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Confirm your location on map. we follow your employee based on your map location",
                  textAlign: TextAlign.center,
                  style: Colors.grey.regular12,
                ),
              ),
            ),

            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecClientEmailAddress,
              textInputType: TextInputType.emailAddress,
              label: MyStrings.emailAddress.tr,
              prefixIcon: Icons.email_rounded,
              validator: (String? value) => Validators.emailValidator(value),
              isValid: controller.isClientEmailValid.value,
              onChange: (value) {
                // Update the validation flag
                controller.isClientEmailValid.value = value.isNotEmpty;
              },
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0.w),
              child: IntlPhoneField(
                controller: controller.tecClientPhoneNumber,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: MyStrings.phoneNumber.tr,
                )
                    .copyWith(
                      counterStyle: TextStyle(
                        color: MyColors.l111111_dwhite(controller.context!),
                      ),
                    )
                    .copyWith(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: controller.isClientPhoneValid.value
                              ? MyColors.noColor
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: controller.isClientPhoneValid.value
                              ? MyColors.primaryLight
                              : Colors.red,
                          width: 1,
                        ),
                      ),
                    ),
                style: Get.width > 600
                    ? MyColors.l111111_dwhite(controller.context!).regular9
                    : MyColors.l111111_dwhite(controller.context!).regular16_5,
                dropdownTextStyle: Get.width > 600
                    ? MyColors.l111111_dwhite(controller.context!).regular9
                    : MyColors.l111111_dwhite(controller.context!).regular16_5,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: MyColors.lightCard(controller.context!),
                  countryCodeStyle: Get.width > 600
                      ? MyColors.l111111_dwhite(controller.context!).regular9
                      : MyColors.l111111_dwhite(controller.context!)
                          .regular16_5,
                  countryNameStyle: Get.width > 600
                      ? MyColors.l111111_dwhite(controller.context!).regular9
                      : MyColors.l111111_dwhite(controller.context!)
                          .regular16_5,
                  // searchFieldCursorColor: MyColors.c_C6A34F,
                  searchFieldInputDecoration: InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    labelText: "Search Country",
                    filled: true,
                    labelStyle: TextStyle(
                      fontFamily: MyAssets.fontKlavika,
                      fontWeight: FontWeight.w400,
                      color: MyColors.c_7B7B7B,
                    ),
                    fillColor: Colors.white,
                    floatingLabelStyle: TextStyle(
                      fontFamily: MyAssets.fontKlavika,
                      fontWeight: FontWeight.w600,
                      color: MyColors.c_C6A34F,
                    ),
                  ),
                ),
                onChanged: (phone) {
                  // Perform phone validation
                  if (phone.number.isEmpty ||
                      phone.completeNumber.isEmpty ||
                      !RegExp(r'^\+?[0-9]{7,15}$')
                          .hasMatch(phone.completeNumber)) {
                    controller.isClientPhoneValid.value = false; // Mark invalid
                  } else {
                    controller.isClientPhoneValid.value = true; // Mark valid
                  }
                },
                onCountryChanged: (Country phone) {
                  // Update the country code change logic here
                  controller.onClientCountryWisePhoneNumberChange(phone);
                  controller.isClientPhoneValid.value = true; // Mark valid
                },
                initialCountryCode:
                    controller.selectedClientWisePhoneNumber.code,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            // Text(" phone : ${controller.selectedClientWisePhoneNumber.dialCode +
            // controller.tecClientPhoneNumber.text.trim()}"),
            SizedBox(height: 10.h),
            // CustomDropdown(
            //   prefixIcon: Icons.flag,
            //   hints: MyStrings.country.tr,
            //   value: controller.selectedClientCountry.value,
            //   items: Data.getAllCountry.map((e) => e.name).toList(),
            //   onChange: (value) {
            //     // Update the validation flag dynamically
            //     controller.isClientCountryValid.value =
            //         value != null && value.isNotEmpty;
            //     controller.onClientCountryChange(value);
            //   },
            // ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.sp),
              child: DropdownSearch<String>(
                key: key,
                selectedItem: controller.selectedClientCountry.value,
                mode: Mode.form,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                items: (text, props) async => Data.getAllCountry
                    .where((country) =>
                        country.name.toLowerCase().contains(text.toLowerCase()))
                    .map((country) => country.name)
                    .toList(),
                onChanged: (value) {
                  controller.isClientCountryValid.value =
                      value != null && value.isNotEmpty;
                  controller.onClientCountryChange(value);
                },
                dropdownBuilder: (context, selectedItem) => Text(
                  selectedItem ?? MyStrings.country.tr,
                  style: MyColors.l7B7B7B_dtext(context)
                      .regular9
                      .copyWith(fontSize: 15.sp),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontFamily: MyAssets.fontKlavika),
                      labelText: "Search Country",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  fit: FlexFit.loose,
                    itemBuilder: (context,value, isB,isC) =>Container(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        value,
                        style: MyColors.l111111_dwhite(context)
                            .regular15,
                      ),
                    ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please select a country"
                    : null,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    hintText: MyStrings.country.tr,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecClientPassword,
              label: MyStrings.password.tr,
              prefixIcon: Icons.lock,
              isPasswordField: true,
              validator: (String? value) => Validators.passwordValidator(value),
              onChange: (value) {
                // Update the validation flag
                print("password typed");
                controller.isClientPasswordValid.value = value.isNotEmpty;
              },
              isValid: controller.isClientPasswordValid.value,
            )
          ],
        ),
      ));

  Widget get _employeeInputFields => Obx(() => Form(
        key: controller.formKeyEmployee,
        child: Column(
          children: [
            SizedBox(height: 15.h),
            CustomTextInputField(
              controller: controller.tecEmployeeFirstName,
              label: MyStrings.firstName.tr,
              prefixIcon: Icons.person,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),

              // isRequired: true,
              isValid: controller.isFirstNameValid.value,
              onChange: (value) {
                print("testing");
                // Update the validation flag
                controller.isFirstNameValid.value = value.isNotEmpty;
              },
            ),
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecEmployeeLastName,
              label: MyStrings.lastName.tr,
              prefixIcon: Icons.person,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
              onChange: (value) {
                // Update the validation flag
                controller.isLastNameValid.value = value.isNotEmpty;
              },
              // isRequired: true,
              isValid: controller.isLastNameValid.value,
            ),
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecEmployeeAddress,
              label: MyStrings.address.tr,
              prefixIcon: Icons.location_on_rounded,
              isMapField: true,
              onSuffixPressed: () =>
                  controller.onClientAddressPressed(module: "employee"),
              readOnly: controller.employeeAddressFromMap.value.isEmpty ||
                  controller.employeeLat == 0 ||
                  controller.employeeLong == 0,
              onTap: (controller.employeeAddressFromMap.value.isEmpty ||
                      controller.employeeLat == 0 ||
                      controller.employeeLong == 0)
                  ? () => controller.onClientAddressPressed(module: "employee")
                  : null,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
              // isRequired: true,
              isValid: controller.isEmployeeAddressValid.value,
              onChange: (value) {
                // Update the validation flag
                controller.isEmployeeAddressValid.value = value.isNotEmpty;
              },
            ),

            Visibility(
              visible: !(controller.employeeAddressFromMap.value.isEmpty ||
                  controller.employeeLat == 0 ||
                  controller.employeeLong == 0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Confirm your location on map. we follow your employee based on your map location",
                  textAlign: TextAlign.center,
                  style: Colors.grey.regular12,
                ),
              ),
            ),

            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecEmployeeEmail,
              textInputType: TextInputType.emailAddress,
              label: MyStrings.emailAddress.tr,
              prefixIcon: Icons.email_rounded,
              onChange: (value) {
                // Update the validation flag
                controller.isEmailValid.value = value.isNotEmpty;
                print("email typed/changed");
              },
              validator: (String? value) => Validators.emailValidator(value),
              // isRequired: true,
              isValid: controller.isEmailValid.value,
            ),
            SizedBox(height: 10.h),
            // CustomDropdown(
            //   prefixIcon: Icons.flag,
            //   hints: MyStrings.country.tr,
            //   value: controller.selectedEmployeeCountry.value,
            //   items: Data.getAllCountry.map((e) => e.name).toList(),
            //   onChange: (value) {
            //     // Update the validation flag dynamically
            //     controller.isCountryValid.value =
            //         value != null && value.isNotEmpty;
            //     controller.onEmployeeCountryChange(value);
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please select a country';
            //     }
            //     return null;
            //   },
            //   isValid: controller.isCountryValid.value,
            // ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18.sp),
              child: DropdownSearch<String>(
                key: key,
                selectedItem: controller.selectedEmployeeCountry.value,
                mode: Mode.form,
                autoValidateMode: AutovalidateMode.onUserInteraction,
                items: (text, props) async => Data.getAllCountry
                    .where((country) =>
                        country.name.toLowerCase().contains(text.toLowerCase()))
                    .map((country) => country.name)
                    .toList(),
                onChanged: (String? value) {
                  if (value != null && value.isNotEmpty) {
                    controller.selectedEmployeeCountry.value = value;
                    controller.isCountryValid.value = true;
                  } else {
                    controller.isCountryValid.value = false;
                  }
                  controller.onEmployeeCountryChange(value);
                },
                dropdownBuilder: (context, selectedItem) => Text(
                  selectedItem ?? MyStrings.country.tr,
                  style: MyColors.l7B7B7B_dtext(context)
                      .regular9
                      .copyWith(fontSize: 15.sp),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    decoration: InputDecoration(
                      labelStyle: TextStyle(fontFamily: MyAssets.fontKlavika),
                      labelText: "Search Country",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  fit: FlexFit.loose,
                  itemBuilder: (context,value, isB,isC) =>Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      value,
                      style: MyColors.l111111_dwhite(context)
                          .regular15,
                    ),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Please select a country"
                    : null,
                decoratorProps: DropDownDecoratorProps(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.flag),
                    hintText: MyStrings.country.tr,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // CustomDropdown(
            //   prefixIcon: Icons.business_center,
            //   hints: MyStrings.position.tr,
            //   value: controller.selectedPosition.value,
            //   items: controller.appController.allActivePositions
            //       .map((e) => e.name!)
            //       .toList(),
            //   onChange: (value) {
            //     // Update the validation flag dynamically
            //     controller.isPositionValid.value =
            //         value != null && value.isNotEmpty;
            //     controller.onPositionChange;
            //   },
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please select a position';
            //     }
            //     return null;
            //   },
            //   isValid: controller.isPositionValid.value,
            // ),
            CustomDropdown(
              prefixIcon: Icons.business_center,
              hints: MyStrings.position.tr,
              value: controller.selectedPosition
                  .value, // This should hold the selected position's name
              items: controller.appController.allActivePositions
                  .map((e) => e.name!)
                  .toList(),
              onChange: (value) {
                // Update the validation flag dynamically
                controller.isPositionValid.value =
                    value != null && value.isNotEmpty;

                // Find the corresponding position object by name
                final selectedPosition =
                    controller.appController.allActivePositions.firstWhere(
                  (e) => e.name == value,
                  orElse: () => DropdownItem(
                      id: '', name: ''), // Provide a default instance
                );

                // Update the controller with the selected name and id
                if (selectedPosition.id!.isNotEmpty) {
                  controller.selectedPosition.value =
                      selectedPosition.name!; // Update with the name for UI
                  controller.selectedPositionId.value =
                      selectedPosition.id!; // Store the id separately
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a position';
                }
                return null;
              },
              isValid: controller.isPositionValid.value,
            ),

            //   Text("position id: ${controller.selectedPositionId.value}"),
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecEmployeePassword,
              label: MyStrings.password.tr,
              prefixIcon: Icons.lock,
              isPasswordField: true,
              validator: (String? value) => Validators.passwordValidator(value),
              isValid: controller.isEmployeePasswordValid.value,
              onChange: (value) {
                // Update the validation flag
                controller.isEmployeePasswordValid.value = value.isNotEmpty;
              },
            ),
          ],
        ),
      ));

  Widget get _agreeTermsAndCondition => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Obx(
                () => CustomCheckBox(
                  active: controller.termsAndConditionCheck.value,
                  onChange: controller.onTermsAndConditionCheck,
                ),
              ),
              SizedBox(width: 18.w),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: MyStrings.iAgreeToTheOf.tr,
                    style:
                        MyColors.l50555C_dtext(controller.context!).regular15,
                    children: [
                      TextSpan(
                        text: MyStrings.termsConditions.tr,
                        style: MyColors.c_C6A34F.semiBold16,
                        recognizer: TapGestureRecognizer()
                          ..onTap = controller.onTermsAndConditionPressed,
                      ),
                      TextSpan(
                        text: "${MyStrings.plagItApp.tr}  ",
                        style: MyColors.l50555C_dtext(controller.context!)
                            .regular15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget get _alreadyHaveAnAccount => Align(
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            text: "${MyStrings.alreadyHaveAnAccount.tr}  ",
            style: MyColors.l50555C_dtext(controller.context!).regular16,
            children: [
              TextSpan(
                text: MyStrings.login.tr,
                style: const TextStyle(
                  color: MyColors.c_C6A34F,
                  fontFamily: MyAssets.fontKlavika,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = controller.onLoginPressed,
              )
            ],
          ),
        ),
      );

  Widget get _bottomRightBg => Container(
        width: 200.w,
        height: 200.h,
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          shape: BoxShape.circle,
        ),
      );
}

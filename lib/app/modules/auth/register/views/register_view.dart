import 'package:dotted_border/dotted_border.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/gestures.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mh/app/modules/auth/register/widgets/employee_extra_field_widget.dart';

import '../../../../common/data/data.dart';
import '../../../../common/style/my_decoration.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/custom_checkbox.dart';
import '../../../../common/widgets/custom_dropdown.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../../../../enums/user_type.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    Utils.setStatusBarColorColor(Theme.of(context).brightness);

    return Scaffold(
      body: Obx(
        () => controller.loading.value
            ? const Center(
                child: CircularProgressIndicator.adaptive(
                backgroundColor: MyColors.c_C6A34F,
              ))
            : SizedBox(
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
            SizedBox(height: 40.h),
            Image.asset(
              MyAssets.logo,
              width: 73.w,
              height: 65.h,
            ),
            SizedBox(height: 30.h),
            _userType,
            SizedBox(height: 23.h),
            ExpandablePageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChange,
              children: [
                _clientInputFields,
                _employeeInputFields,
              ],
            ),
            SizedBox(height: 37.h),
            _agreeTermsAndCondition,
            SizedBox(height: 37.h),
            CustomButtons.button(
              height: 48,
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: MyStrings.register.tr,
              onTap: controller.onContinuePressed,
              margin: const EdgeInsets.symmetric(horizontal: 18),
            ),
            SizedBox(height: 52.h),
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
          border: Border.all(color: MyColors.c_A6A6A6, width: .5),
        ),
        child: Obx(
          () => Row(
            children: [
              _userItem(UserType.client, controller.userType.value == UserType.client),
              _userItem(UserType.employee, controller.userType.value == UserType.employee),
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
              color: active ? MyColors.c_C6A34F : MyColors.lightCard(controller.context!),
            ),
            child: Center(
              child: Text(
                userType.name.capitalize!,
                style: active
                    ? MyColors.lightCard(controller.context!).semiBold14
                    : MyColors.darkCard(controller.context!).semiBold14,
              ),
            ),
          ),
        ),
      );

  Widget get _clientInputFields => Form(
        key: controller.formKeyClient,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecClientName,
              label: MyStrings.restaurantName.tr,
              prefixIcon: Icons.add_business,
              validator: (String? value) => Validators.emptyValidator(
                controller.tecClientName.value.text,
                MyStrings.required.tr,
              ),
            ),
            SizedBox(height: 26.h),
            Obx(
              () => CustomTextInputField(
                controller: controller.tecClientAddress,
                label: MyStrings.restaurantAddress.tr,
                prefixIcon: Icons.location_on_rounded,
                isMapField: true,
                onSuffixPressed: controller.onClientAddressPressed,
                readOnly: controller.restaurantAddressFromMap.value.isEmpty ||
                    controller.restaurantLat == 0 ||
                    controller.restaurantLong == 0,
                onTap: (controller.restaurantAddressFromMap.value.isEmpty ||
                        controller.restaurantLat == 0 ||
                        controller.restaurantLong == 0)
                    ? controller.onClientAddressPressed
                    : null,
                validator: (String? value) => Validators.emptyValidator(
                  value,
                  MyStrings.required.tr,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Obx(
              () => Visibility(
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
            ),
            SizedBox(height: 26.h),
            CustomTextInputField(
              controller: controller.tecClientEmailAddress,
              textInputType: TextInputType.emailAddress,
              label: MyStrings.emailAddress.tr,
              prefixIcon: Icons.email_rounded,
              validator: (String? value) => Validators.emailValidator(value),
            ),
            SizedBox(height: 26.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0.w),
              child: IntlPhoneField(
                controller: controller.tecClientPhoneNumber,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: MyStrings.phoneNumber.tr,
                ).copyWith(
                  counterStyle: TextStyle(
                    color: MyColors.l111111_dwhite(controller.context!),
                  ),
                ),
                style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                dropdownTextStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: MyColors.lightCard(controller.context!),
                  countryCodeStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                  countryNameStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                  // searchFieldCursorColor: MyColors.c_C6A34F,
                  searchFieldInputDecoration: const InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    labelText: "Search Country",
                    labelStyle: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontWeight: FontWeight.w400,
                      color: MyColors.c_7B7B7B,
                    ),
                    floatingLabelStyle: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontWeight: FontWeight.w600,
                      color: MyColors.c_C6A34F,
                    ),
                  ),
                ),
                initialCountryCode: controller.selectedClientWisePhoneNumber.code,
                onCountryChanged: controller.onClientCountryWisePhoneNumberChange,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            SizedBox(height: 26.h),
            CustomDropdown(
              prefixIcon: Icons.flag,
              hints: MyStrings.country.tr,
              value: controller.selectedClientCountry.value,
              items: Data.getAllCountry.map((e) => e.name).toList(),
              onChange: controller.onClientCountryChange,
            ),
            SizedBox(height: 26.h),
            CustomTextInputField(
              controller: controller.tecClientPassword,
              label: MyStrings.password.tr,
              prefixIcon: Icons.lock,
              isPasswordField: true,
              validator: (String? value) => Validators.passwordValidator(value),
            ),
            SizedBox(height: 26.h),
            CustomTextInputField(
              controller: controller.tecClientConfirmPassword,
              label: MyStrings.confirmPassword.tr,
              prefixIcon: Icons.lock,
              isPasswordField: true,
              validator: (String? value) => Validators.confirmPasswordValidator(
                controller.tecClientPassword.text,
                value ?? "",
              ),
            ),
            SizedBox(height: 26.h),
            _extraInfoHeading(MyStrings.howYouKnowAboutUs.tr),
            SizedBox(height: 18.h),
            CustomDropdown(
              prefixIcon: Icons.bookmark,
              hints: null,
              value: null,
              items: (controller.sources?.sources! ?? []).map((e) => e.name).toList(),
              onChange: controller.onSourceChange,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
            ),
            SizedBox(height: 20.h),
            _extraInfoHeading(MyStrings.refer.tr),
            SizedBox(height: 18.h),
            CustomDropdown(
              prefixIcon: Icons.label,
              hints: null,
              value: controller.selectedRefer,
              items: (controller.employees?.users ?? [])
                  .map((e) => "${e.firstName} ${e.lastName} - ${e.userIdNumber}")
                  .toList()
                ..add("Other"),
              onChange: controller.onReferChange,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      );

  /// new employee field is add in tue-28-mar-2023
  // Widget get _employeeInputFields => Form(
  //       key: controller.formKeyEmployee,
  //       child: Column(
  //         children: [
  //           SizedBox(height: 10.h),
  //
  //           CustomTextInputField(
  //             controller: controller.tecEmployeeFullName,
  //             label: MyStrings.fullName.tr,
  //             prefixIcon: Icons.person,
  //             validator: (String? value) => Validators.emptyValidator(
  //               value,
  //               MyStrings.required.tr,
  //             ),
  //           ),
  //
  //           SizedBox(height: 26.h),
  //
  //           CustomTextInputField(
  //             controller: controller.tecEmployeeDob,
  //             label: MyStrings.dateOfBirth.tr,
  //             prefixIcon: Icons.calendar_month,
  //             readOnly: true,
  //             onTap: () => _selectDate(controller.context!),
  //             validator: (String? value) => Validators.emptyValidator(
  //               value,
  //               MyStrings.required.tr,
  //             ),
  //           ),
  //
  //           SizedBox(height: 26.h),
  //
  //           CustomTextInputField(
  //             controller: controller.tecEmployeeEmail,
  //             textInputType: TextInputType.emailAddress,
  //             label: MyStrings.emailAddress.tr,
  //             prefixIcon: Icons.email_rounded,
  //             validator: (String? value) => Validators.emailValidator(value),
  //           ),
  //
  //           SizedBox(height: 26.h),
  //
  //           Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 18.0.w),
  //             child: IntlPhoneField(
  //               controller: controller.tecEmployeePhone,
  //               decoration: MyDecoration.inputFieldDecoration(
  //                 context: controller.context!,
  //                 label: MyStrings.phoneNumber.tr,
  //               ),
  //               style: MyColors.l111111_dwhite(controller.context!).regular16_5,
  //               dropdownTextStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
  //               pickerDialogStyle: PickerDialogStyle(
  //                 backgroundColor: MyColors.lightCard(controller.context!),
  //                 countryCodeStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
  //                 countryNameStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
  //                 searchFieldCursorColor: MyColors.c_C6A34F,
  //                 searchFieldInputDecoration: const InputDecoration(
  //                   suffixIcon: Icon(Icons.search),
  //                   labelText: "Search Country",
  //                   labelStyle: TextStyle(
  //                     fontFamily: MyAssets.fontMontserrat,
  //                     fontWeight: FontWeight.w400,
  //                     color: MyColors.c_7B7B7B,
  //                   ),
  //                   floatingLabelStyle: TextStyle(
  //                     fontFamily: MyAssets.fontMontserrat,
  //                     fontWeight: FontWeight.w600,
  //                     color: MyColors.c_C6A34F,
  //                   ),
  //                 ),
  //               ),
  //               initialCountryCode: controller.selectedEmployeeCountry.code,
  //               onCountryChanged: controller.onEmployeeCountryChange,
  //               autovalidateMode: AutovalidateMode.onUserInteraction,
  //             ),
  //           ),
  //
  //           SizedBox(height: 26.h),
  //
  //           CustomDropdown(
  //             prefixIcon: Icons.sell,
  //             hints: MyStrings.gender.tr,
  //             value: controller.selectedGender.value,
  //             items: Data.genders.map((e) => e.name!).toList(),
  //             onChange: controller.onGenderChange,
  //           ),
  //
  //           SizedBox(height: 26.h),
  //
  //           CustomDropdown(
  //             prefixIcon: Icons.business_center,
  //             hints: MyStrings.position.tr,
  //             value: controller.selectedPosition.value,
  //             items: controller.appController.allActivePositions.map((e) => e.name!).toList(),
  //             onChange: controller.onPositionChange,
  //           ),
  //
  //           SizedBox(height: 10.h),
  //         ],
  //       ),
  // );

  Widget get _employeeInputFields => Form(
        key: controller.formKeyEmployee,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            CustomTextInputField(
              controller: controller.tecEmployeeFirstName,
              label: MyStrings.firstName.tr,
              prefixIcon: Icons.person,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
            ),
            SizedBox(height: 26.h),
            CustomTextInputField(
              controller: controller.tecEmployeeLastName,
              label: MyStrings.lastName.tr,
              prefixIcon: Icons.person,
              validator: (String? value) => Validators.emptyValidator(
                value,
                MyStrings.required.tr,
              ),
            ),
            SizedBox(height: 26.h),
            CustomTextInputField(
              controller: controller.tecEmployeeEmail,
              textInputType: TextInputType.emailAddress,
              label: MyStrings.emailAddress.tr,
              prefixIcon: Icons.email_rounded,
              validator: (String? value) => Validators.emailValidator(value),
            ),
            SizedBox(height: 26.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.0.w),
              child: IntlPhoneField(
                controller: controller.tecEmployeePhone,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: MyStrings.phoneNumber.tr,
                ).copyWith(
                  counterStyle: TextStyle(
                    color: MyColors.l111111_dwhite(controller.context!),
                  ),
                ),
                style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                dropdownTextStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                pickerDialogStyle: PickerDialogStyle(
                  backgroundColor: MyColors.lightCard(controller.context!),
                  countryCodeStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                  countryNameStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                  searchFieldCursorColor: MyColors.c_C6A34F,
                  searchFieldInputDecoration: const InputDecoration(
                    suffixIcon: Icon(Icons.search),
                    labelText: "Search Country",
                    labelStyle: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontWeight: FontWeight.w400,
                      color: MyColors.c_7B7B7B,
                    ),
                    floatingLabelStyle: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontWeight: FontWeight.w600,
                      color: MyColors.c_C6A34F,
                    ),
                  ),
                ),
                initialCountryCode: controller.selectedEmployeeWisePhoneNumber.code,
                onCountryChanged: controller.onEmployeeCountryWisePhoneNumberChange,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ),
            SizedBox(height: 26.h),
            CustomDropdown(
              prefixIcon: Icons.flag,
              hints: MyStrings.country.tr,
              value: controller.selectedEmployeeCountry.value,
              items: Data.getAllCountry.map((e) => e.name).toList(),
              onChange: controller.onEmployeeCountryChange,
            ),
            SizedBox(height: 26.h),
            CustomDropdown(
              prefixIcon: Icons.business_center,
              hints: MyStrings.position.tr,
              value: controller.selectedPosition.value,
              items: controller.appController.allActivePositions.map((e) => e.name!).toList(),
              onChange: controller.onPositionChange,
            ),
            SizedBox(height: 26.h),
            _cv,
            const EmployeeExtraFieldWidget(),
            _profileImage,
            SizedBox(height: 5.h),
            _profilePhotoHints,
            SizedBox(height: 10.h),
          ],
        ),
      );

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
                    style: MyColors.l50555C_dtext(controller.context!).regular15,
                    children: [
                      TextSpan(
                        text: MyStrings.termsConditions.tr,
                        style: MyColors.c_C6A34F.semiBold16,
                        recognizer: TapGestureRecognizer()..onTap = controller.onTermsAndConditionPressed,
                      ),
                      TextSpan(
                        text: "${MyStrings.mhApp.tr}  ",
                        style: MyColors.l50555C_dtext(controller.context!).regular15,
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
                  fontFamily: MyAssets.fontMontserrat,
                  fontWeight: FontWeight.w600,
                ),
                recognizer: TapGestureRecognizer()..onTap = controller.onLoginPressed,
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

  Widget get _cv => Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 18.w),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(width: .5, color: MyColors.c_777777),
              color: Theme.of(controller.context!).cardColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Obx(
              () => Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: MyColors.c_7B7B7B,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Text(
                      controller.cv.isEmpty ? "Upload your cv" : controller.cv.first.path.split("/").last,
                      style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.onCvClick,
                    child: Icon(
                      controller.cv.isEmpty ? Icons.upload : Icons.cancel,
                      color: MyColors.c_7B7B7B,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: controller.cv.isNotEmpty && controller.cv.first.path.split(".").last.toLowerCase() != "pdf",
              child: Text(
                'CV must be pdf format',
                style: Colors.redAccent.medium12,
              ),
            ),
          ),
        ],
      );

  Widget _extraInfoHeading(String text) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(
            text,
            style: MyColors.c_C6A34F.medium14,
          ),
        ),
      );

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: controller.dateOfBirth.value,
  //     firstDate: DateTime(2015, 8),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != null && picked != controller.dateOfBirth.value) {
  //     controller.onDatePicked(picked);
  //   }
  // }

  Widget get _profileImage => GestureDetector(
        onTap: controller.onProfileImageClick,
        child: DottedBorder(
          borderType: BorderType.Circle,
          dashPattern: const [11],
          strokeWidth: 2,
          color: MyColors.c_C6A34F,
          child: Container(
            height: 162.w,
            width: 162.w,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: MyColors.c_C6A34F_22,
              shape: BoxShape.circle,
            ),
            child: Obx(
              () => controller.profileImage.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          color: MyColors.c_C6A34F,
                          size: 50,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          MyStrings.uploadYourPhoto.tr,
                          textAlign: TextAlign.center,
                          style: MyColors.text.medium12,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(162),
                      child: Image.file(
                        controller.profileImage.first,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          ),
        ),
      );

  Widget get _profilePhotoHints => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(
          top: 10,
        ),
        child: Text(
          "NB: Please upload passport size photo with white background",
          textAlign: TextAlign.center,
          style: Colors.blue.medium12,
        ),
      );
}

import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/profile_picture_widget.dart';
import 'package:mh/app/modules/client/employee_details/widgets/vlog_carsousel_slider.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/employee_self_profile_controller.dart';

class EmployeeSelfProfileView extends GetView<EmployeeSelfProfileController> {
  const EmployeeSelfProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      backgroundColor: MyColors.lFAFAFA_dframeBg(context),
      appBar: CustomAppbar.appbar(title: "My Profile", context: context),
      // bottomNavigationBar: _bottomBar(context),
      body: Obx(() => controller.loading.value == true
          ? Center(child: CustomLoader.loading())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(21, 0, 21, 20),
                child: Form(
                  key: controller.formKeyClient,
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      // const EmployeeProfileImageWidget(),
                      ProfilePictureWidget(
                          profilePictureUrl: (controller.employee.value.details?.profilePicture ?? "").imageUrl),
                      SizedBox(height: 10.h),
                      Obx(() => Container(
                          width: 100,
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                          decoration: const BoxDecoration(
                              color: MyColors.c_C6A34F,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 15),
                              Text(controller.rating.value,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ))),
                      SizedBox(height: 30.h),
                      Obx(() => VlogCarouselSlider(vlogs: controller.employee.value.details?.vlogs ?? [], height: 200)),
                      Row(
                        children: [
                          Expanded(
                            child: _item(
                              logo: Icons.person,
                              fieldName: "First Name",
                              textEditingController: controller.tecFirstName,
                              validator: (String? value) => Validators.emptyValidator(
                                controller.tecFirstName.text,
                                MyStrings.required.tr,
                              ),
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: _item(
                              logo: Icons.person,
                              fieldName: "Last Name",
                              textEditingController: controller.tecLastName,
                              validator: (String? value) => Validators.emptyValidator(
                                controller.tecLastName.text,
                                MyStrings.required.tr,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.person,
                        fieldName: "Date of Birth",
                        textEditingController: controller.tecDob,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecDob.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.flag,
                        fieldName: "Country",
                        textEditingController: controller.tecCountry,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecCountry.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      /*_item(
                  logo: Icons.flag,
                  fieldName: "Country",
                  child: DropdownButtonFormField(
                    dropdownColor: MyColors.lightCard(context),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: controller.onCountryChange,
                    isExpanded: true,
                    isDense: true,
                    value: controller.selectedCountry.value,
                    items: Data.getAllCountry
                        .map((e) => e.name)
                        .toList()
                        .map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: MyColors.l111111_dwhite(context).regular14,
                        ),
                      );
                    }).toList(),
                    decoration: _decoration,
                  ),
                ),*/

                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.phone_android_rounded,
                        fieldName: "Phone Number",
                        textEditingController: controller.tecPhoneNumber,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecPhoneNumber.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.email_rounded,
                        fieldName: "Email",
                        textEditingController: controller.tecEmail,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecEmail.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.location_on_rounded,
                        fieldName: "Present Address",
                        textEditingController: controller.tecPresentAddress,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecPresentAddress.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.location_on_rounded,
                        fieldName: "Permanent Address",
                        textEditingController: controller.tecPermanentAddress,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecPermanentAddress.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      _item(
                        logo: Icons.phone_android_rounded,
                        fieldName: "Emergency Contact",
                        textEditingController: controller.tecEmergencyContact,
                        validator: (String? value) => Validators.emptyValidator(
                          controller.tecEmergencyContact.text,
                          MyStrings.required.tr,
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            )),
    );
  }

  Widget _item({
    required IconData logo,
    required String fieldName,
    TextEditingController? textEditingController,
    String? Function(String?)? validator,
    bool readOnly = true,
    GestureTapCallback? onTap,
    Function()? onSuffixPressed,
    Widget? child,
  }) =>
      Column(
        children: [
          Row(
            children: [
              Icon(
                logo,
                color: MyColors.c_C6A34F,
                size: 16,
              ),
              const SizedBox(width: 5),
              Text(
                fieldName,
                style: MyColors.c_C6A34F.regular12,
              ),
            ],
          ),
          SizedBox(
            height: 40.h,
            child: child ??
                TextFormField(
                  controller: textEditingController,
                  style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                  cursorColor: MyColors.c_C6A34F,
                  validator: validator,
                  decoration: _decoration.copyWith(
                    suffixIcon: onSuffixPressed == null
                        ? null
                        : GestureDetector(
                            onTap: onSuffixPressed,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: MyColors.c_C6A34F,
                            ),
                          ),
                  ),
                  readOnly: readOnly,
                  onTap: onTap,
                ),
          ),
        ],
      );

  InputDecoration get _decoration => const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
        errorStyle: TextStyle(fontSize: 0.01),
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
        border: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: MyColors.c_909090),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: MyColors.c_909090),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: MyColors.c_909090),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(width: 1, color: Colors.redAccent),
        ),
      );

  Widget _bottomBar(BuildContext context) {
    return CustomBottomBar(
      child: CustomButtons.button(
        onTap: controller.onUpdatePressed,
        text: "Update",
        customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
      ),
    );
  }
}

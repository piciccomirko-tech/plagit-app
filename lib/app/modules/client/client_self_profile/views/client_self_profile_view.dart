import '../../../../common/utils/exports.dart';
import '../../../../common/utils/validators.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/client_self_profile_controller.dart';

class ClientSelfProfileView extends GetView<ClientSelfProfileController> {
  const ClientSelfProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      backgroundColor: MyColors.lFAFAFA_dframeBg(context),
      appBar: CustomAppbar.appbar(title: "My Profile", context: context),
      bottomNavigationBar: _bottomBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(21, 0, 21, 20),
          child: Form(
            key: controller.formKeyClient,
            child: Column(
              children: [
                SizedBox(height: 40.h),

                _backButtonImageBookmark,

                SizedBox(height: 40.h),

                _item(
                  logo: Icons.add_business,
                  fieldName: "Restaurant Name",
                  textEditingController: controller.tecRestaurantName,
                  validator: (String? value) => Validators.emptyValidator(
                    controller.tecRestaurantName.text,
                    MyStrings.required.tr,
                  ),
                ),

                SizedBox(height: 20.h),

                _item(
                  logo: Icons.location_on_rounded,
                  fieldName: "Restaurant Location",
                  textEditingController: controller.tecRestaurantAddress,
                  validator: (String? value) => Validators.emptyValidator(
                    controller.tecRestaurantAddress.text,
                    MyStrings.required.tr,
                  ),
                  onSuffixPressed: controller.onRestaurantAddressPressed,
                  readOnly: controller.restaurantAddressFromMap.value.isEmpty || controller.restaurantLat == 0 || controller.restaurantLong == 0,
                  onTap: (controller.restaurantAddressFromMap.value.isEmpty || controller.restaurantLat == 0 || controller.restaurantLong == 0)
                      ? controller.onRestaurantAddressPressed
                      : null,
                ),

                SizedBox(height: 5.h),

                Obx(
                      () => Visibility(
                    visible: !(controller.restaurantAddressFromMap.value.isEmpty || controller.restaurantLat == 0 || controller.restaurantLong == 0),
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

                SizedBox(height: 20.h),

                _item(
                  logo: Icons.phone_android_rounded,
                  fieldName: "Phone Number",
                  textEditingController: controller.tecRestaurantPhoneNumber,
                  validator: (String? value) => Validators.emptyValidator(
                    controller.tecRestaurantName.text,
                    MyStrings.required.tr,
                  ),
                ),

                // IntlPhoneField(
                //   controller: controller.tecRestaurantPhoneNumber,
                //   decoration: _decoration.copyWith(
                //     counterStyle: TextStyle(
                //       color: MyColors.l111111_dwhite(controller.context!),
                //     ),
                //   ),
                //   style: MyColors.l111111_dwhite(controller.context!).regular16_5,
                //   dropdownTextStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                //   pickerDialogStyle: PickerDialogStyle(
                //     backgroundColor: MyColors.lightCard(controller.context!),
                //     countryCodeStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                //     countryNameStyle: MyColors.l111111_dwhite(controller.context!).regular16_5,
                //     // searchFieldCursorColor: MyColors.c_C6A34F,
                //     searchFieldInputDecoration: const InputDecoration(
                //       suffixIcon: Icon(Icons.search),
                //       labelText: "Search Country",
                //       labelStyle: TextStyle(
                //         fontFamily: MyAssets.fontMontserrat,
                //         fontWeight: FontWeight.w400,
                //         color: MyColors.c_7B7B7B,
                //       ),
                //       floatingLabelStyle: TextStyle(
                //         fontFamily: MyAssets.fontMontserrat,
                //         fontWeight: FontWeight.w600,
                //         color: MyColors.c_C6A34F,
                //       ),
                //     ),
                //   ),
                //   initialCountryCode: controller.selectedClientCountry.code,
                //   onCountryChanged: controller.onClientCountryChange,
                //   autovalidateMode: AutovalidateMode.onUserInteraction,
                // ),

                SizedBox(height: 20.h),

                _item(
                  logo: Icons.email_rounded,
                  fieldName: "Email",
                  textEditingController: controller.tecRestaurantEmail,
                  validator: (String? value) => Validators.emptyValidator(
                    controller.tecRestaurantEmail.text,
                    MyStrings.required.tr,
                  ),
                ),

                SizedBox(height: 40.h),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _backButtonImageBookmark => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 130.h,
            height: 130.h,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.5,
                  color: MyColors.c_C6A34F,
                )),
            child: Image.asset(MyAssets.clientFixedLogo),
          ),
          const Spacer(),
        ],
      );


  Widget _item({
    required IconData logo,
    required String fieldName,
    required TextEditingController textEditingController,
    String? Function(String?)? validator,
    bool readOnly = false,
    GestureTapCallback? onTap,
    Function()? onSuffixPressed,
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
            child: TextFormField(
              controller: textEditingController,
              style: MyColors.l111111_dwhite(controller.context!).regular16_5,
              cursorColor: MyColors.c_C6A34F,
              validator: validator,
              decoration: _decoration.copyWith(
                suffixIcon: onSuffixPressed == null ? null : GestureDetector(
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

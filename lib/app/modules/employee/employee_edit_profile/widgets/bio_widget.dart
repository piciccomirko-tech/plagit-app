import 'package:flutter/services.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/controllers/employee_edit_profile_controller.dart';

class BioWidget extends GetWidget<EmployeeEditProfileController> {
  const BioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.width*0.6,
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            // key: controller.formKeyBio,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: TextFormField(
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                            RegExp(r"[\d@]|(http(s)?://[^\s]+)|(www\.[^\s]+)|(facebook|twitter|instagram|linkedin|youtube)")),
                      ],
                    keyboardType: TextInputType.multiline,
                      minLines: 3,
                      maxLines: null,
                      controller: controller.tecBio,
                      style: TextStyle(color: Get.textTheme.bodyLarge?.color),
                      cursorColor: MyColors.c_C6A34F,
                      decoration: InputDecoration(
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: context.theme.highlightColor,
                        contentPadding: const EdgeInsets.all(15.0),
                        border: InputBorder.none,

                        hintText: MyStrings.enterBio.tr,
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      validator: (String? value) {
                        if ((value ?? "").isEmpty) {
                          return MyStrings.bioIsRequired.tr;
                        } else if (_isValid(value ?? "") == false) {
                          return MyStrings.pleaseDoNotEnterContactInformation.tr;
                        } else {
                          return null;
                        }
                      }),
                ),
                SizedBox(height: 20.h),
                CustomButtons.button(
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    margin: EdgeInsets.zero,
                    text: MyStrings.update.tr,
                    onTap: controller.onUpdateTapped
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isValid(String value) {
    RegExp regExp = RegExp(
        r'(https?://(?:www\.)?\w+\.\w{2,})(?:[/\w\s.-]*)?|(?:\b\d{3}\b\s?[-.\s]?\d{5}\b)'
    );
    if (regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }
}

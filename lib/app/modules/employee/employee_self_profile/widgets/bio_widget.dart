import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_self_profile/controllers/employee_self_profile_controller.dart';

class BioWidget extends GetWidget<EmployeeSelfProfileController> {
  const BioWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.width * 0.5,
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Form(
            key: controller.formKeyBio,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: TextFormField(
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
                        hintText: 'Enter bio...',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                      validator: (String? value) {
                        if ((value ?? "").isEmpty) {
                          return "Bio is required";
                        } else if (_isValid(value ?? "") == false) {
                          return 'Please do not enter contact information';
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
        r'(https?://(?:www\.)?\w+\.\w{2,})(?:[/\w\s.-]*)?|(?:\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b)|(?:\+\d{1,3}[- ]?\d{2,4}[- ]?\d{2,4}[- ]?\d{2,4})|(?:\w+@\w+\.\w{2,})'
    );
    if (regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }
}

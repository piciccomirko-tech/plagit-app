import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class AgeWidget extends GetWidget<CreateJobPostController> {
  const AgeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecAge.value,
        label: MyStrings.age.tr,
        prefixIcon: Icons.person,
        //isMapField: true,
        // onSuffixPressed: controller.onClientAddressPressed,
        
        readOnly: true,
        onTap: () => controller.onCustomSliderClick(
            context: context,
            typeName: "Age",
            minValue: "${controller.createJobPostRequestModel.value.minAge}" ,
            maxValue: "${controller.createJobPostRequestModel.value.maxAge}" ,
           
            onTap: controller.onAgeSubmitClick),
        validator: (String? value) => Validators.emptyValidator(value, MyStrings.required.tr),
      ),
    );
  }
}

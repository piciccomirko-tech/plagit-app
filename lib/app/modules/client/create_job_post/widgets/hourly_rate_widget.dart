import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class HourlyRateWidget extends GetWidget<CreateJobPostController> {
  const HourlyRateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecRatePerHour.value,
        label: "Hourly Rate",
        prefixIcon: Icons.money,
        //isMapField: true,
        // onSuffixPressed: controller.onClientAddressPressed,
        readOnly: true,
        onTap: () => controller.onCustomSliderClick(
            context: context,
            typeName: "Hourly Rate",
            minValue: controller.createJobPostRequestModel.value.minRatePerHour?.toInt() ?? 0,
            maxValue: controller.createJobPostRequestModel.value.maxRatePerHour?.toInt() ?? 0,
            onTap: controller.onHourlyRateSubmitClick),
        validator: (String? value) => Validators.emptyValidator(
          value,
          MyStrings.required.tr,
        ),
      ),
    );
  }
}

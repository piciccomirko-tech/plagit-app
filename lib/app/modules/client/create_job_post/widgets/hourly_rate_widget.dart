import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
import 'package:mh/app/modules/client/create_job_post/models/custom_slider_model.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/custom_slider_widget.dart';

class HourlyRateWidget extends GetWidget<CreateJobPostController> {
  const HourlyRateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CustomTextInputField(
        controller: controller.tecRatePerHour.value,
        label: "Rate/ Per Hour",
        prefixIcon: Icons.money,
        //isMapField: true,
        // onSuffixPressed: controller.onClientAddressPressed,
        readOnly: true,
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              // padding: EdgeInsets.only(
              //   bottom: MediaQuery.of(context).viewInsets.bottom,
              // ),
              color: MyColors.lightCard(context),
              child: CustomSliderWidget(
                customSliderModel:
                    CustomSliderModel(minValue: controller.minHourlyRate.value, maxValue: controller.maxHourlyRate.value, onTap: controller.onHourlyRateSubmitClick)
              ),
            ),
          );
        },
        validator: (String? value) => Validators.emptyValidator(
          value,
          MyStrings.required.tr,
        ),
      ),
    );
  }
}

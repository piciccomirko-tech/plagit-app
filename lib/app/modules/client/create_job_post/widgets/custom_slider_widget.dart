import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/hatch_mark.dart';
import 'package:another_xlider/models/hatch_mark_label.dart';
import 'package:another_xlider/models/slider_step.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/tooltip/tooltip_box.dart';
import 'package:another_xlider/models/tooltip/tooltip_position_offset.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/create_job_post/models/custom_slider_model.dart';

class CustomSliderWidget extends StatelessWidget {
  final CustomSliderModel customSliderModel;
  const CustomSliderWidget({super.key, required this.customSliderModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.h,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              FlutterSlider(
                min: customSliderModel.minValue,
                max: customSliderModel.maxValue,
                rangeSlider: true,
                values: [customSliderModel.minValue, customSliderModel.maxValue],
                selectByTap: false,
                step: const FlutterSliderStep(step: 1),
                onDragCompleted: (int handlerIndex, lowerValue, upperValue) {
                  customSliderModel.minValue = lowerValue;
                  customSliderModel.maxValue = upperValue;
                },
                tooltip: FlutterSliderTooltip(
                  alwaysShowTooltip: true,
                  positionOffset: FlutterSliderTooltipPositionOffset(top: -10),
                  format: (String value) {
                    return value.split(".").first;
                  },
                  boxStyle: FlutterSliderTooltipBox(
                    decoration: BoxDecoration(
                      color: MyColors.c_C6A34F,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  textStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
                trackBar: _sliderTrackbar(context),
                handler: FlutterSliderHandler(
                  decoration: const BoxDecoration(),
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: const BoxDecoration(
                      color: MyColors.c_C6A34F,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  decoration: const BoxDecoration(),
                  child: Container(
                    height: 15,
                    width: 15,
                    decoration: const BoxDecoration(
                      color: MyColors.c_C6A34F,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                hatchMark: FlutterSliderHatchMark(
                  linesDistanceFromTrackBar: -5,
                  labelsDistanceFromTrackBar: 40,
                  labels: [
                    FlutterSliderHatchMarkLabel(
                        percent: 0, label: _sliderHatchMarkLabel(context, "${customSliderModel.minValue}")),
                    FlutterSliderHatchMarkLabel(
                        percent: 100, label: _sliderHatchMarkLabel(context, "${customSliderModel.maxValue}")),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              CustomButtons.button(
                  text: 'Submit',
                  onTap: customSliderModel.onTap,
                  margin: EdgeInsets.zero,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner)
            ],
          ),
        ),
      ),
    );
  }

  Widget _sliderHatchMarkLabel(BuildContext context, String text) => Text(
        text,
        style: MyColors.l111111_dwhite(context).regular16_5,
      );

  FlutterSliderTrackBar _sliderTrackbar(BuildContext context) => FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(
          color: MyColors.darkCard(context),
        ),
        activeTrackBar: const BoxDecoration(
          color: MyColors.c_C6A34F,
        ),
      );
}

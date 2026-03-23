// import 'package:another_xlider/another_xlider.dart';
// import 'package:another_xlider/models/handler.dart';
// import 'package:another_xlider/models/hatch_mark.dart';
// import 'package:another_xlider/models/hatch_mark_label.dart';
// import 'package:another_xlider/models/slider_step.dart';
// import 'package:another_xlider/models/tooltip/tooltip.dart';
// import 'package:another_xlider/models/tooltip/tooltip_box.dart';
// import 'package:another_xlider/models/tooltip/tooltip_position_offset.dart';
// import 'package:another_xlider/models/trackbar.dart';
// import 'package:mh/app/common/utils/exports.dart';
// import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
// import 'package:mh/app/modules/client/create_job_post/controllers/slider_controller.dart';

// class CustomSliderWidget extends GetWidget<CreateJobPostController> {
//   final String type;
//    CustomSliderWidget(this.type, {super.key, });
//   // final SliderController sliderController = Get.find<SliderController>();

//   @override
//   Widget build(BuildContext context) {
//     // final sliderData = sliderController.getSliderDataByType(type);
//     // sliderController.addOrUpdateSliderData('Experience', 18.0, 65.0);
//     return Container(
//       height: Get.height * 0.5,
//       decoration: BoxDecoration(
//           color: MyColors.lightCard(context),
//           borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
//       child: Padding(
//         padding: EdgeInsets.all(20.0.sp),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 10.h),
//               Text(
//                   "${MyStrings.selectRangeFor.tr} ${controller.customSliderModel.value.typeName ?? ""}"
//                       .toUpperCase(),
//                   style: Get.width > 600
//                       ? MyColors.l111111_dwhite(context).semiBold13
//                       : MyColors.l111111_dwhite(context).semiBold18),
//               SizedBox(height: 40.h),
//               // Text("Type- ${type} ${sliderData}"),
//             FlutterSlider(
//               min:  0.0,
//               max:  14.0,
//               rangeSlider: true,
//               values: [
//                0.0,
//                 20.0,
//                 // controller.customSliderModel.value.maxValue ?? 1.0
//               ],
//               selectByTap: false,
//               step: const FlutterSliderStep(step: 1),
//               onDragging: (int handlerIndex, dynamic lowerValue, dynamic upperValue) {
//                 double minValue = controller.customSliderModel.value.minValue ?? 0.0;
//                 double maxValue = controller.customSliderModel.value.maxValue ?? 1.0;

// //  sliderController.addOrUpdateSliderData(type,lowerValue,upperValue);
// //             sliderController.sliderData.refresh();
//               },
//               tooltip: FlutterSliderTooltip(
//                 alwaysShowTooltip: true,
//                 positionOffset: FlutterSliderTooltipPositionOffset(top: -10),
//                 format: (String value) {
//                   return value.split(".").first;
//                 },

//                 boxStyle: FlutterSliderTooltipBox(
//                   decoration: BoxDecoration(
//                     color: MyColors.c_C6A34F,
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//                 textStyle:  TextStyle(
//                   color: Colors.white,
//                   fontSize: Get.width>600? 12.sp:null
//                 ),
//               ),
//               trackBar: _sliderTrackbar(context),
//               handler: FlutterSliderHandler(
//                 decoration: const BoxDecoration(),
//                 child: Container(
//                   height: 15.h,
//                   width: 15.w,
//                   decoration: const BoxDecoration(
//                     color: MyColors.c_C6A34F,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               rightHandler: FlutterSliderHandler(
//                 decoration: const BoxDecoration(),
//                 child: Container(
//                   height: 15.h,
//                   width: 15.w,
//                   decoration: const BoxDecoration(
//                     color: MyColors.c_C6A34F,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               hatchMark: FlutterSliderHatchMark(
//                 linesDistanceFromTrackBar: -5,
//                 labelsDistanceFromTrackBar: 40,
//                 labels: [
//                   FlutterSliderHatchMarkLabel(
//                       percent: 0,
//                       label: _sliderHatchMarkLabel(context, "${controller.customSliderModel.value.minValue}")),
//                   FlutterSliderHatchMarkLabel(
//                       percent: 100,
//                       label: _sliderHatchMarkLabel(context, "${controller.customSliderModel.value.maxValue}")),
//                 ],
//               ),
//             ),
//             SizedBox(height: 40.h),
//               CustomButtons.button(
//                   text: MyStrings.submit.tr,
//                       height: Get.width>600? 30.h: 48.h,
//                   fontSize: Get.width>600? 12.sp:16,
//                   onTap: controller.customSliderModel.value.onTap,
//                   margin: EdgeInsets.zero,
//                   customButtonStyle: CustomButtonStyle.radiusTopBottomCorner)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sliderHatchMarkLabel(BuildContext context, String text) => Text(
//         text,
//         style: Get.width > 600
//             ? MyColors.l111111_dwhite(context).regular9
//             : MyColors.l111111_dwhite(context).regular16_5,
//       );

//   FlutterSliderTrackBar _sliderTrackbar(BuildContext context) =>
//       FlutterSliderTrackBar(
//         inactiveTrackBar: BoxDecoration(
//           color: MyColors.darkCard(context),
//         ),
//         activeTrackBar: const BoxDecoration(
//           color: MyColors.c_C6A34F,
//         ),
//       );
// }

// import 'package:another_xlider/another_xlider.dart';
// import 'package:another_xlider/models/handler.dart';
// import 'package:another_xlider/models/hatch_mark.dart';
// import 'package:another_xlider/models/hatch_mark_label.dart';
// import 'package:another_xlider/models/slider_step.dart';
// import 'package:another_xlider/models/tooltip/tooltip.dart';
// import 'package:another_xlider/models/tooltip/tooltip_box.dart';
// import 'package:another_xlider/models/tooltip/tooltip_position_offset.dart';
// import 'package:another_xlider/models/trackbar.dart';
// import 'package:mh/app/common/utils/exports.dart';
// import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
// import 'package:mh/app/modules/client/create_job_post/controllers/slider_controller.dart';

// class CustomSliderWidget extends GetWidget<CreateJobPostController> {
//   final String type;
//   CustomSliderWidget({required this.type, super.key});
//   final SliderController sliderController = Get.find<SliderController>();

//   @override
//   Widget build(BuildContext context) {
//     final sliderData = sliderController.getSliderDataByType(type);

//     // Fetch the fixed range for the current type from the controller
//     final fixedRange = sliderController.getFixedRangeForType(type);
//     double overallMin = fixedRange['min']!;
//     double overallMax = fixedRange['max']!;

//     // Use saved min and max values (last selected), or default to overallMin/Max
//     double currentMinValue = sliderData?['min'] ?? overallMin;
//     double currentMaxValue = sliderData?['max'] ?? overallMax;
// // Ensure the values are within the fixed range
//     currentMinValue = currentMinValue.clamp(overallMin, overallMax);
//     currentMaxValue = currentMaxValue.clamp(overallMin, overallMax);
//     // Ensure the initial values are set in the controller
//     sliderController.addOrUpdateSliderData(
//         type, currentMinValue, currentMaxValue);
//     return Container(
//       height: Get.width * 0.7,
//       decoration: BoxDecoration(
//           color: MyColors.lightCard(context),
//           borderRadius: const BorderRadius.only(
//               topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
//       child: Padding(
//         padding: EdgeInsets.all(20.0.sp),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(height: 10.h),
//               controller.customSliderModel.value.typeName!.toUpperCase() ==
//                       'HOURLY RATE'
//                   ? Text("Select Salary Range")
//                   : Text(
//                       "Select Range for ${controller.customSliderModel.value.typeName ?? ""}"
//                           .toUpperCase(),
//                       style: Get.width > 600
//                           ? MyColors.l111111_dwhite(context).semiBold13
//                           : MyColors.l111111_dwhite(context).semiBold18),
//               SizedBox(height: 40.h),
//               // Text("${sliderData?['min']} -- ${sliderData?['max']}"),
//               FlutterSlider(
//                 min: overallMin,
//                 max: overallMax,
//                 rangeSlider: true,
//                 values: [
//                   currentMinValue,
//                   currentMaxValue,
//                 ],
//                 selectByTap: false,
//                 step: const FlutterSliderStep(step: 1),
//                 onDragging:
//                     (int handlerIndex, dynamic lowerValue, dynamic upperValue) {
//                   lowerValue = lowerValue.clamp(overallMin, overallMax);
//                   upperValue = upperValue.clamp(overallMin, overallMax);
//                   // Update the values in the controller when dragging
//                   sliderController.addOrUpdateSliderData(
//                       type, lowerValue, upperValue);
//                   // controller.customSliderModel.refresh();
//                 },
//                 tooltip: FlutterSliderTooltip(
//                   alwaysShowTooltip: true,
//                   positionOffset: FlutterSliderTooltipPositionOffset(top: -10),
//                   format: (String value) {
//                     return value.split(".").first;
//                   },
//                   boxStyle: FlutterSliderTooltipBox(
//                     decoration: BoxDecoration(
//                       color: MyColors.c_C6A34F,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                   ),
//                   textStyle: const TextStyle(
//                     color: Colors.white,
//                   ),
//                 ),
//                 trackBar: _sliderTrackbar(context),
//                 handler: FlutterSliderHandler(
//                   decoration: const BoxDecoration(),
//                   child: Container(
//                     height: 15,
//                     width: 15,
//                     decoration: const BoxDecoration(
//                       color: MyColors.c_C6A34F,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 rightHandler: FlutterSliderHandler(
//                   decoration: const BoxDecoration(),
//                   child: Container(
//                     height: 15,
//                     width: 15,
//                     decoration: const BoxDecoration(
//                       color: MyColors.c_C6A34F,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 ),
//                 hatchMark: FlutterSliderHatchMark(
//                   linesDistanceFromTrackBar: -5,
//                   labelsDistanceFromTrackBar: 40,
//                   labels: [
//                     FlutterSliderHatchMarkLabel(
//                         percent: 0,
//                         label: _sliderHatchMarkLabel(context, "$overallMin")),
//                     FlutterSliderHatchMarkLabel(
//                         percent: 100,
//                         label: _sliderHatchMarkLabel(context, "$overallMax")),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 40.h),
//               CustomButtons.button(
//                   text: MyStrings.submit.tr,
//                   height: 48.h,
//                   fontSize: 16,
//                   onTap: controller.customSliderModel.value.onTap,
//                   margin: EdgeInsets.zero,
//                   customButtonStyle: CustomButtonStyle.radiusTopBottomCorner)
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sliderHatchMarkLabel(BuildContext context, String text) => Text(
//         text,
//         style: Get.width > 600
//             ? MyColors.l111111_dwhite(context).regular9
//             : MyColors.l111111_dwhite(context).regular16_5,
//       );

//   FlutterSliderTrackBar _sliderTrackbar(BuildContext context) =>
//       FlutterSliderTrackBar(
//         inactiveTrackBar: BoxDecoration(
//           color: MyColors.darkCard(context),
//         ),
//         activeTrackBar: const BoxDecoration(
//           color: MyColors.c_C6A34F,
//         ),
//       );
// }

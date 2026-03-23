import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_text_input_field.dart';

import '../../../../common/widgets/custom_appbar_back_button.dart';
import '../../../../models/check_in_out_histories.dart';
import '../controllers/client_dashboard_controller.dart';

class EditDetailsModal extends GetView<ClientDashboardController> {
  final CheckInCheckOutHistoryElement history;

  EditDetailsModal({required this.history}) {
    // Initialize controllers with history data
    controller.employeeCheckIn.text =
        history.checkInCheckOutDetails?.checkInTime?.toString() ?? "";
    controller.employeeCheckOut.text =
        history.checkInCheckOutDetails?.checkOutTime?.toString() ?? "";
    //tmp hold loaded data

    controller.tmpCheckIn =
        history.checkInCheckOutDetails?.checkInTime?.toString() ?? "";
    controller.tmpCheckOut =
        history.checkInCheckOutDetails?.checkOutTime?.toString() ?? "";
//load client changes data if avialable
    controller.tecCheckIn.text =
        (history.checkInCheckOutDetails?.clientCheckInTime?.toString().substring(0,19) ??
                history.checkInCheckOutDetails?.checkInTime?.toString().substring(0,19)) ??
            "";
    controller.tecCheckOut.text =
        // DateFormat('HH:mm:ss').format(DateTime.parse(
        history.checkInCheckOutDetails?.clientCheckOutTime?.toString().substring(0,19) ??
            history.checkInCheckOutDetails?.checkOutTime?.toString().substring(0,19) ??
            "";

    controller.tecBreakTime.text =
        history.checkInCheckOutDetails?.clientBreakTime?.toString() ?? history.checkInCheckOutDetails?.breakTime?.toString() ?? "";
    controller.tecTravelCost.text = history.travelCost?.toString() ?? "";
    controller.tecTips.text = history.tips?.toString() ?? "";
    controller.tecTotalHours.text =
        history.employeeDetails?.totalWorkingHour?.toString() ?? "";
    controller.tecTotalAmount.text = history.totalAmount?.toString() ?? "";
    controller.tecComment2.text =
        history.checkInCheckOutDetails!.clientComment ?? '';
    controller.originalAmount.value = (history.totalAmount ?? 0.0).toDouble();
    //  -((history.tips ?? 0.0) + (history.travelCost ?? 0.0));
    controller.totalAmount.value = "${(history.totalAmount)}";

    controller.vatAmount.value = "${(history.vatAmount)}";
    controller.hourlyRate.value =
        "${(history.employeeDetails?.hourlyRate ?? 0.0)}";
    controller.plagitPlatformFee.value = "${(history.platformFee ?? 0.0)}";
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return WillPopScope(
        onWillPop: () async {
          if (FocusScope.of(context).hasFocus) {
            FocusScope.of(context).unfocus();
            return false;
          }
          return true;
        },
        child: Container(
          width: width * 0.9,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomAppbarBackButton(),
                    Text(
                      MyStrings.checkInCheckOutHistory.tr,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        fontFamily: MyAssets.fontKlavika,
                      ),
                    ),
                    SizedBox(
                        width:
                            30.w), // Placeholder to align the title centrally
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                // if (history.employeeId != null &&
                //     history.employeeId!.isNotEmpty &&
                //     history.employeeDetails != null &&
                //     history.employeeDetails!.profilePicture != null &&
                //     history.employeeDetails!.profilePicture!.isNotEmpty)
                //   CircleAvatar(
                //     radius: 30.r,
                //     backgroundImage: NetworkImage(
                //       '${(history.employeeDetails!.profilePicture)!.imageUrl}', // Replace with the actual image URL
                //     ),
                //   ),
                // SizedBox(height: 10.h),
                // Text(
                //   '${history.employeeDetails!.name}',
                //   style: TextStyle(
                //     fontSize: 15.sp,
                //     fontWeight: FontWeight.bold,
                //     fontFamily: MyAssets.fontMontserrat,
                //   ),
                // ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Icon(Icons.work, color: Colors.orange),
                //     SizedBox(width: 5.w),
                //     Text(
                //       '${history.employeeDetails!.positionName}',
                //       style: TextStyle(
                //         fontSize: 14.sp,
                //         fontFamily: MyAssets.fontMontserrat,
                //       ),
                //     ),
                //     SizedBox(width: 20.w),
                //     Icon(Icons.attach_money, color: Colors.green),
                //     SizedBox(width: 5),
                //     Text(
                //       'Rate: ${history.employeeDetails!.hourlyRate}/hour',
                //       style: TextStyle(
                //         fontSize: 14.sp,
                //         fontFamily: MyAssets.fontMontserrat,
                //       ),
                //     ),
                //   ],
                // ),
                SizedBox(height: 20.h),
                //  Text("${history.checkInCheckOutDetails!.clientCheckInTime}"),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectTimeOnly(
                            context, controller.tecCheckIn),
                        child: AbsorbPointer(
                          child: CustomTextInputField(
                            padding: EdgeInsets.all(0),
                            controller: controller.tecCheckIn,
                            label: 'Check In',
                            prefixIcon: Icons.checklist_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => controller.selectTimeOnly(
                            context, controller.tecCheckOut),
                        child: AbsorbPointer(
                          child: CustomTextInputField(
                            padding: EdgeInsets.all(0),
                            controller: controller.tecCheckOut,
                            label: 'Check Out',
                            prefixIcon: Icons.checklist_outlined,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextInputField(
                        padding: EdgeInsets.all(0),
                        controller: controller.tecBreakTime,
                        label: 'Break Time',
                        textInputType: TextInputType.number,
                        prefixIcon: Icons.free_breakfast_outlined,
                        // isRequired: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CustomTextInputField(
                        padding: EdgeInsets.all(0),
                        controller: controller.tecTravelCost,
                        label: 'Travel Cost',
                        textInputType: TextInputType.number,
                        prefixIcon: Icons.money,
                        // isRequired: true,
                      ),
                    ),
                  ],
                ),
                // DropdownButtonFormField(
                //   decoration: InputDecoration(
                //     border: OutlineInputBorder(),
                //   ),
                //   items: [
                //     DropdownMenuItem(
                //       value: '30 Min',
                //       child: Text('30 Min'),
                //     ),
                //     DropdownMenuItem(
                //       value: '1 Hour',
                //       child: Text('1 Hour'),
                //     ),
                //     DropdownMenuItem(
                //       value: '1.5 Hours',
                //       child: Text('1.5 Hours'),
                //     ),
                //   ],
                //   onChanged: (value) {},
                //   hint: Text('Break time'),
                // ),
                SizedBox(height: 20),
                Row(
                  children: [
                    // Expanded(
                    //   child: CustomTextInputField(
                    //     padding: EdgeInsets.all(0),
                    //     controller: controller.tecTravelCost,
                    //     label: 'Travel Cost',
                    //     textInputType: TextInputType.number,
                    //     prefixIcon: Icons.money,
                    //     // isRequired: true,
                    //   ),
                    // ),
                    Expanded(
                      child: CustomTextInputField(
                        padding: EdgeInsets.all(0),
                        controller: controller.tecTips,
                        label: 'Tips',
                        textInputType: TextInputType.number,
                        prefixIcon: Icons.tips_and_updates_rounded,
                        // isRequired: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Obx(
                            () => CustomTextInputField(
                          padding: EdgeInsets.all(0),
                          controller: TextEditingController()
                            ..text = controller.totalAmount.value,
                          label: 'Total Amount',
                          readOnly: true,
                          prefixIcon: Icons.summarize,
                        ),
                      ),
                    ),
                  ],
                ),

                // SizedBox(height: 20),
                // Row(
                //   children: [
                //     // Expanded(
                //     //   child: Obx(
                //     //     () => CustomTextInputField(
                //     //       padding: EdgeInsets.all(0),
                //     //       controller: TextEditingController()
                //     //         ..text = controller.totalHours.value,
                //     //       label: 'Total Hours',
                //     //       readOnly: true,
                //     //       prefixIcon: Icons.lock_clock,
                //     //     ),
                //     //   ),
                //     // ),
                //     // SizedBox(width: 10.w),
                //     // Expanded(
                //     //   child: Obx(
                //     //     () => CustomTextInputField(
                //     //       padding: EdgeInsets.all(0),
                //     //       controller: TextEditingController()
                //     //         ..text = controller.totalAmount.value,
                //     //       label: 'Total Amount',
                //     //       readOnly: true,
                //     //       prefixIcon: Icons.summarize,
                //     //     ),
                //     //   ),
                //     // ),
                //   ],
                // ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextInputField(
                        padding: EdgeInsets.all(0),
                        controller: controller.tecComment2,
                        label: 'Write Comment...',

                        prefixIcon: Icons.comment,

                        // isRequired: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomButtons.button(
                  height: 48.h,
                  text: "Submit",
                  margin: EdgeInsets.zero,
                  fontSize: 14.sp,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  // onTap: controller.prevStep,
                  onTap: () {
                    // Compare employee and client check-in and check-out times

                    log("controller.isCheckInChanged(): ${controller.isCheckInChanged()}");
                    log("controller.isCheckOutChanged(): ${controller.isCheckOutChanged()}");
                    double travelCostValue =
                        double.tryParse(controller.tecTravelCost.text) ?? 0;
                    double tipsValue =
                        double.tryParse(controller.tecTips.text) ?? 0;
                    controller.submitData(
                      id: history.currentHiredEmployeeId ?? "",
                      // checkIn: !isCheckInSame,
                      // checkOut: !isCheckOutSame,

                      checkIn: true,
                      checkOut: true,

                      // checkIn: controller.isCheckInChanged(),
                      // checkOut: controller.isCheckOutChanged(),
                      clientComment: controller.tecComment2.text,
                      clientCheckInTime: controller.tecCheckIn.text,
                      clientCheckOutTime: controller.tecCheckOut.text,
                      clientBreakTime:
                          int.tryParse(controller.tecBreakTime.text) ?? 0,
                      // travelCost:
                      // int.tryParse(controller.tecTravelCost.text) ?? 0,
                      // tips: int.tryParse(controller.tecTips.text) ?? 0,
                      travelCost: travelCostValue,
                      tips: tipsValue,
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

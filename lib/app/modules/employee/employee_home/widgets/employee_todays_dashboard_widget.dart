import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class EmployeeTodayDashboardWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeTodayDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.todayCheckInCheckOutDetailsDataLoading.value == true
        ? ShimmerWidget.employeeTodayDashboardShimmerWidget()
        : Visibility(
            visible: controller.checkIn.value == true,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(bottom: 15.h),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Get.theme.dividerColor.withOpacity(0.05),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ], borderRadius: BorderRadius.circular(10.0), color: Colors.teal.withOpacity(0.6)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _itemValue("Check In", controller.dailyStatistics.displayCheckInTime),
                      _itemValue("Check Out", controller.dailyStatistics.displayCheckOutTime),
                      _itemValue("Break", controller.dailyStatistics.displayBreakTime),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Divider(
                    indent: Get.width * .1,
                    endIndent: Get.width * .1,
                    color: MyColors.white,
                  ),
                  const SizedBox(height: 7),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _itemValue("Working Time", controller.dailyStatistics.workingHour, valueFontSize: 18),
                      _itemValue("Date", controller.dailyStatistics.date, valueFontSize: 14),
                    ],
                  ),
                ],
              ),
            )));
  }

  Widget _itemValue(String text, String value, {double valueFontSize = 14}) => Column(
        children: [
          Text(
            value,
            style: MyColors.white.semiBold14.copyWith(fontSize: valueFontSize),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: MyColors.white.medium12,
          ),
        ],
      );
}

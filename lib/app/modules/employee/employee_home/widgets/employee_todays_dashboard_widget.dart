import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

import '../../../../helpers/responsive_helper.dart';

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
              margin: EdgeInsets.only(top: 13.w),
              width: Get.width,
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.noColor, width: 0.5),
                color: MyColors.lightCard(context), borderRadius: BorderRadius.circular(15.0)),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _itemValue(context, MyStrings.checkIn.tr, controller.dailyStatistics.displayCheckInTime),
                        _itemValue(context, MyStrings.checkOut.tr, controller.dailyStatistics.displayCheckOutTime),
                        _itemValue(context, MyStrings.breakTime.tr, controller.dailyStatistics.displayBreakTime),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Divider(
                      indent: Get.width * .1,
                      endIndent: Get.width * .1,
                      color: MyColors.lightGrey,
                      thickness: 0.3,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _itemValue(context, MyStrings.workingTime.tr, controller.dailyStatisticsInHour.value,),
                        _itemValue(context, MyStrings.date.tr, controller.dailyStatistics.date,),
                      ],
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _itemValue(BuildContext context, String text, String value,) => Column(
        children: [
          Text(
            value,
            style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).semiBold10:MyColors.l111111_dwhite(context).semiBold14,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style:ResponsiveHelper.isTab(context)? MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(controller.context!).medium12,
          ),
        ],
      );
}

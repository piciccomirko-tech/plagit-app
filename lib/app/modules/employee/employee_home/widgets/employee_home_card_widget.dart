import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/common/widgets/custom_feature_box.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class EmployeeHomeCardWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeHomeCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.bookingHistoryDataLoaded.value == false ||
            controller.hiredHistoryDataLoaded.value == false
        ? ShimmerWidget.employeeHomeShimmerWidget()
        : Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        CustomFeatureBox(
                            title: MyStrings.bookedHistory,
                            icon: MyAssets.bookedHistory,
                            onTap: controller.onBookedHistoryClick),
                        Obx(
                          () => Positioned(
                            top: 0,
                            right: 5,
                            child: Visibility(
                              visible: controller.bookingHistoryList.isNotEmpty,
                              child: CustomBadge(
                                controller.bookingHistoryList.length.toString(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Stack(
                      children: [
                        CustomFeatureBox(
                            title: MyStrings.hiredHistory,
                            icon: MyAssets.hiredHistory,
                            onTap: controller.onHiredHistoryClick),
                        Obx(
                          () => Positioned(
                            top: 0,
                            right: 5,
                            child: Visibility(
                              visible: controller.hiredHistoryList.isNotEmpty,
                              child: CustomBadge(
                                controller.hiredHistoryList.length.toString(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: CustomFeatureBox(
                        title: MyStrings.myDashboard, icon: MyAssets.mhEmployees, onTap: controller.onDashboardClick),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: CustomFeatureBox(
                        title: MyStrings.calendar, icon: MyAssets.calender2, onTap: controller.onCalenderClick),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
              Row(
                children: [
                  Expanded(
                    child: CustomFeatureBox(
                        title: MyStrings.paymentHistory.tr,
                        icon: MyAssets.invoicePayment,
                        onTap: controller.onPaymentHistoryClick),
                  ),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: Stack(
                      children: [
                        CustomFeatureBox(
                            title: MyStrings.helpSupport.tr,
                            icon: MyAssets.helpSupport,
                            onTap: controller.onHelpAndSupportClick),
                        Obx(
                          () => Positioned(
                            top: 0,
                            right: 5,
                            child: Visibility(
                              visible: (controller.unreadMsgFromClient.value + controller.unreadMsgFromAdmin.value) > 0,
                              child: CustomBadge(
                                (controller.unreadMsgFromClient.value + controller.unreadMsgFromAdmin.value).toString(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
            ],
          ));
  }
}

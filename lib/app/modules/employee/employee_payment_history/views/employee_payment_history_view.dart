import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/models/check_in_check_out_details.dart';

import '../controllers/employee_payment_history_controller.dart';

class EmployeePaymentHistoryView extends GetView<EmployeePaymentHistoryController> {
  const EmployeePaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.paymentHistory.tr.replaceAll("\n", " "),
        context: context,
      ),
      body: Obx(() {
        if (controller.employeePaymentHistoryDataLoaded.value == false) {
          return Center(child: CustomLoader.loading());
        } else if (controller.employeePaymentHistoryDataLoaded.value == true &&
            controller.employeePaymentHistoryList.isEmpty) {
          return const NoItemFound();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: HorizontalDataTable(
              leftHandSideColumnWidth: 150.w,
              rightHandSideColumnWidth: 800.w,
              isFixedHeader: true,
              headerWidgets: _getTitleWidget(),
              leftSideItemBuilder: _generateFirstColumnRow,
              rightSideItemBuilder: _generateRightHandSideColumnRow,
              itemCount: controller.employeePaymentHistoryList.length,
              rowSeparatorWidget: Container(
                height: 6.h,
                color: MyColors.lFAFAFA_dframeBg(context),
              ),
              leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
              rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
            ),
          );
        }
      }),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.day.tr, 150.w),
      _getTitleItemWidget(MyStrings.restaurantName.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget(MyStrings.contractorPerHoursRate.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr} ${MyStrings.hours.tr}', 100.w),
      _getTitleItemWidget(MyStrings.amount.tr, 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
      _getTitleItemWidget(MyStrings.complain.tr, 100.w),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 62.h,
      color: MyColors.c_C6A34F,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Get.width>600?MyColors.lffffff_dframeBg(controller.context!).semiBold10:MyColors.lffffff_dframeBg(controller.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      width: 150.w,
      height: 71.h,
      color: Colors.white,
      child: _cell(
          width: 90.w,
          widget: Text(
            controller.employeePaymentHistory(index).day,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          )),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        _cell(
            width: 150.w,
            widget: Text(
              controller.employeePaymentHistory(index).restaurantName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.employeePaymentHistory(index).position,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              '${Utils.getCurrencySymbol(controller.appController.user.value.employee?.countryName ?? "")}${controller.employeePaymentHistory(index).contractorPerHoursRate.toStringAsFixed(2)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.employeePaymentHistory(index).totalHours.contains(':')
                  ? '${controller.employeePaymentHistory(index).totalHours}h'
                  : '${double.parse(controller.employeePaymentHistory(index).totalHours).toStringAsFixed(2)}h',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style:Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              "${Utils.getCurrencySymbol(controller.appController.user.value.employee?.countryName ?? "")}${controller.employeePaymentHistory(index).employeeAmount.toStringAsFixed(2)}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width>600?MyColors.l7B7B7B_dtext(controller.context!).semiBold9:MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.employeePaymentHistory(index).status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: controller.employeePaymentHistory(index).status == 'DUE' ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold, fontSize: Get.width>600?16:12),
            )),
        _cell(
            width: 100.w,
            widget: _action(
                index: index,
                checkInCheckOutDetails: controller.employeePaymentHistoryList[index].checkInCheckOutDetails!)),
      ],
    );
  }

  Widget _cell({required double width, required Widget widget}) => SizedBox(
        width: width,
        height: 71.h,
        child: Center(
          child: widget,
        ),
      );

  Widget _action({required int index, required CheckInCheckOutDetails checkInCheckOutDetails}) =>
      controller.getComment(index).isEmpty
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 22,
            )
          : GestureDetector(
              onTap: () {
                CustomDialogue.information(
                  context: controller.context!,
                  title: MyStrings.restaurantReport.tr,
                  description:
                      "CheckIn Time: ${DateFormat('HH: mm: ss').format(checkInCheckOutDetails.clientCheckInTime!)}\nCheckOut Time: ${DateFormat('HH: mm: ss').format(checkInCheckOutDetails.clientCheckOutTime!)}\nBreak Time: ${checkInCheckOutDetails.clientBreakTime} min\nComment: ${checkInCheckOutDetails.clientComment}",
                );
              },
              child: const Icon(
                Icons.info,
                color: Colors.orange,
                size: 22,
              ),
            );
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/controllers/admin_todays_employees_controller.dart';

class AdminTodaysEmployeeBodyWidget extends GetWidget<AdminTodaysEmployeesController> {
  const AdminTodaysEmployeeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: Obx(
            () => Visibility(
              visible: controller.todaysEmployeesList.isNotEmpty,
              child: Container(
                width: Get.width*0.7,
                padding: const EdgeInsets.all(5.0),
                decoration: const BoxDecoration(
                  color: MyColors.c_C6A34F,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(5.0), bottomLeft:Radius.circular(5.0) )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(MyAssets.manager, height: 25, width: 25),
                    Text(
                      " ${controller.todaysEmployeesList.length}",
                      style: MyColors.white.semiBold24,
                    ),
                    Text(' Employees Active', style: MyColors.white.semiBold15)
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Visibility(
            visible: controller.todaysEmployeesList.isNotEmpty,
            child: Expanded(
              child: HorizontalDataTable(
                leftHandSideColumnWidth: 150.w,
                rightHandSideColumnWidth: 1000.w,
                isFixedHeader: true,
                headerWidgets: _getTitleWidget(),
                leftSideItemBuilder: _generateFirstColumnRow,
                rightSideItemBuilder: _generateRightHandSideColumnRow,
                itemCount: controller.todaysEmployeesList.length,
                rowSeparatorWidget: Container(
                  height: 6.h,
                  color: MyColors.lFAFAFA_dframeBg(context),
                ),
                leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
              ),
            ),
          ),
        ),
        Obx(
          () => Visibility(
            visible: controller.todaysEmployeesDataLoaded.value == true && controller.todaysEmployeesList.isEmpty,
            child: controller.todaysEmployeesDataLoaded.value == false
                ? const CircularProgressIndicator.adaptive(
                    backgroundColor: MyColors.c_C6A34F,
                  )
                : const NoItemFound(),
          ),
        ),
      ],
    );
  }
  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Date', 150.w),
      _getTitleItemWidget('Employee Name', 150.w),
      _getTitleItemWidget('Restaurant Name', 150.w),
      _getTitleItemWidget('Position', 150.w),
      _getTitleItemWidget('Restaurant Rate', 100.w),
      _getTitleItemWidget('Contractor Rate', 100.w),
      _getTitleItemWidget('Start Time', 150.w),
      _getTitleItemWidget('End Time', 150.w)
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
          style: MyColors.lffffff_dframeBg(controller.context!).semiBold14,
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
            controller.startDate.value.EdMMMy,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          )),
    );
  }

  Widget _cell({required double width, required Widget widget}) => SizedBox(
        width: width,
        height: 71.h,
        child: Center(
          child: widget,
        ),
      );

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        _cell(
            width: 150.w,
            widget: Text(
              controller.todaysEmployeesList[index].employeeDetails?.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.todaysEmployeesList[index].restaurantDetails?.restaurantName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.todaysEmployeesList[index].employeeDetails?.positionName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${controller.todaysEmployeesList[index].employeeDetails?.hourlyRate ?? 0.0}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${controller.todaysEmployeesList[index].employeeDetails?.contractorHourlyRate ?? 0.0}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.getTime(index: index, tag: 'start'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.getTime(index: index, tag: 'end'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            ))
      ],
    );
  }
}

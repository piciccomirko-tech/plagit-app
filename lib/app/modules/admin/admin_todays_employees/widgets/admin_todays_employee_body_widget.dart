import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/exports.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                  child: SizedBox(
                height: 40.h,
                child: Obx(
                      () => ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: MyColors.lightCard(context),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: controller.onClientChange,
                      isExpanded: true,
                      itemHeight: 58.h,
                      borderRadius: BorderRadius.circular(5.0),
                      isDense: false,
                      hint: Text(
                        controller.clientLoading.value ? "Loading..." : "Select Client",
                        style: MyColors.l7B7B7B_dtext(context).regular18,
                      ),
                      value: controller.selectedRestaurantName.value,
                      items: controller.restaurants.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: MyColors.l111111_dwhite(context).medium16,
                          ),
                        );
                      }).toList(),
                      decoration:  InputDecoration(
                        filled: true,
                        fillColor: MyColors.c_C6A34F.withOpacity(0.5),
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 15),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintMaxLines: 1,
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                  child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(color: MyColors.c_C6A34F.withOpacity(0.5), borderRadius: BorderRadius.circular(5.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(MyAssets.calendar, height: 20, width: 20),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Row(
                        children: [
                          Obx(
                                () => Text(
                              controller.startDate.value.EdMMMy,
                              style: MyColors.l111111_dwhite(context).medium16,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: Obx(
            () => Visibility(
              visible: controller.todaysEmployeesList.isNotEmpty,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(MyAssets.manager, height: 25, width: 25),
                  Text(
                    " ${controller.todaysEmployeesList.length}",
                    style: MyColors.l111111_dwhite(context).semiBold24,
                  ),
                  Text(' ${MyStrings.employees.tr}${MyStrings.areShowing.tr}', style: MyColors.l111111_dwhite(context).semiBold15)
                ],
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
      _getTitleItemWidget(MyStrings.date.tr, 150.w),
      _getTitleItemWidget(MyStrings.employeeName.tr, 150.w),
      _getTitleItemWidget(MyStrings.restaurantName.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget(MyStrings.restaurantRate.tr, 100.w),
      _getTitleItemWidget('${MyStrings.contractor.tr} ${MyStrings.rate.tr}', 100.w),
      _getTitleItemWidget(MyStrings.startTime.tr, 150.w),
      _getTitleItemWidget(MyStrings.endTime.tr, 150.w)
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.startDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.startDate.value) {
      controller.onDatePicked(picked);
    }
  }

}

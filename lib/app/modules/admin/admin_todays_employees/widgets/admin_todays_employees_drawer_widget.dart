import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/controllers/admin_todays_employees_controller.dart';

class AdminTodaysEmployeesDrawerWidget extends GetWidget<AdminTodaysEmployeesController> {
  const AdminTodaysEmployeesDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      height: MediaQuery.of(context).size.height*0.5,
      color: Colors.grey[200], // Set background color
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40.h,
              child: Obx(
                    () => ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: DropdownButtonFormField<String>(
                    dropdownColor: MyColors.lightCard(context),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: controller.onEmployeeChange,
                    isExpanded: true,
                    itemHeight: 58.h,
                    borderRadius: BorderRadius.circular(5.0),
                    isDense: false,
                    hint: Text(
                      controller.employeeDataLoading.value ? "Loading..." : "Select Employee",
                      style: MyColors.l7B7B7B_dtext(context).regular18,
                    ),
                    value: controller.selectedEmployeeName.value,
                    items: controller.todaysEmployees.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: MyColors.l111111_dwhite(context).medium16,
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: MyColors.c_C6A34F,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 5, 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintMaxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
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
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: MyColors.c_C6A34F,
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 5, 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      hintMaxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(5.0)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(MyAssets.calender, height: 20, width: 20),
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
            ),
          ],
        ),
      ),
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

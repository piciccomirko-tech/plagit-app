import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';

class EmployeeDateRangeWidget extends GetWidget<CalenderController> {
  const EmployeeDateRangeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.rangeStartDate.value != null && controller.selectedDates.isNotEmpty
        ? Container(
            height: 100,
            decoration: BoxDecoration(color: Get.isDarkMode?Colors.grey.shade800:Colors.grey.shade200, borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.08, left: 15.0, right: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => Row(
                            children: [
                              Image.asset(MyAssets.calender2, height: 20.w, width: 20.w),
                              Text('  ${DateFormat('E, dd MMM, yyyy').format(controller.rangeStartDate.value!)}  ',
                                  style: MyColors.l111111_dwhite(context).semiBold13),
                              Container(width: 12.w, color: Colors.grey, height: 2.h),
                              if (controller.rangeEndDate.value == null)
                                Text('  Select End Date', style: MyColors.c_7B7B7B.semiBold13)
                              else
                                Text('  ${DateFormat('E, dd MMM, yyyy').format(controller.rangeEndDate.value!)}',
                                    style: MyColors.l111111_dwhite(context).semiBold13),
                            ],
                          )),
                      InkWell(onTap: controller.onRemoveClick, child: const Icon(CupertinoIcons.delete_solid, color: Colors.red, size: 18))
                    ],
                  ),
                ),
                Obx(() => Visibility(
                    visible: controller.rangeEndDate.value == null,
                    child: Padding(
                      padding: EdgeInsets.only(left: 5.w),
                      child: Row(
                        children: [
                          Checkbox(
                              activeColor: MyColors.c_C6A34F,
                              checkColor: MyColors.c_FFFFFF,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2.0),
                              ),
                              side: MaterialStateBorderSide.resolveWith(
                                (states) =>  BorderSide(width: 2.0.w, color: MyColors.c_C6A34F),
                              ),
                              value: controller.sameAsStartDate.value,
                              onChanged: controller.onSameAsStartDatePressedForEmployee),
                          Text('Same as Start Date', style: MyColors.primaryDark.semiBold15),
                        ],
                      ),
                    )))
              ],
            ),
          )
        : const Wrap()
    );
  }
}

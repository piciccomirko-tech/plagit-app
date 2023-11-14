import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';

class ShortListTimeRangeWidget extends StatelessWidget {
  final RequestDateModel requestDate;
  final int index;
  const ShortListTimeRangeWidget({super.key, required this.requestDate, required this.index});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 110.h,
          decoration: BoxDecoration(color: Get.isDarkMode ?Colors.grey.shade800 :Colors.grey.shade200, borderRadius: BorderRadius.circular(10.0)),
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.08, left: 15.0.w, right: 15.0.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: 15.0.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Image.asset(MyAssets.calender2, height: 20.w, width: 20.w),
                    Text('  ${DateTime.parse(requestDate.startDate ?? "").formatDateWithWeekday()}  ',
                        style: MyColors.l111111_dwhite(context).medium13),
                    Container(width: 12.w, color: Colors.grey, height: 2.h),
                    if (requestDate.endDate == null)
                      Text('  Select End Date', style: MyColors.c_7B7B7B.medium13)
                    else
                      Text('  ${DateTime.parse(requestDate.endDate ?? "").formatDateWithWeekday()}',
                          style: MyColors.l111111_dwhite(context).medium13),
                    SizedBox(width: 28.w)
                  ],
                ),
              ),
              if(requestDate.startDate != null && requestDate.endDate != null)
                Text(
                    '${DateTime.parse(requestDate.startDate ?? '').daysUntil(DateTime.parse(requestDate.endDate ?? ''))} ${DateTime.parse(requestDate.startDate ?? '').daysUntil(DateTime.parse(requestDate.endDate ?? '')) == 1 ? 'day' : 'days'}',
                    style: MyColors.c_C6A34F.semiBold15),
              Obx(() => Visibility(
                  visible: requestDate.endDate == null,
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
                              (states) => const BorderSide(width: 2.0, color: MyColors.c_C6A34F),
                            ),
                            value: Get.find<CalenderController>().sameAsStartDate.value,
                            onChanged: Get.find<CalenderController>().onSameAsStartDatePressedForShortList),
                        Text('Same as Start Date', style: MyColors.primaryDark.semiBold15),
                      ],
                    ),
                  ))),
              if (requestDate.startDate != null &&
                  requestDate.endDate != null &&
                  requestDate.startTime == null &&
                  requestDate.endTime == null)
                _selectTimeRangeWidget(index: index)
              else if (requestDate.startTime != null && requestDate.endTime != null)
                _timeRangeWidget(requestDate: requestDate, index: index)
            ],
          ),
        ),
        Positioned(
          right: 18.w,
            top: 2.h,
            child:  InkWell(
            onTap: () => Get.find<CalenderController>().onRemoveClickForShortList(index: index),
            child: const Icon(CupertinoIcons.delete_solid, color: Colors.red, size: 18)))
      ],
    );
  }

  Widget _selectTimeRangeWidget({required int index}) {
    return InkWell(
      onTap: () => Get.find<CalenderController>().showTimePickerBottomSheet(index: index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(
          children: [
            Image.asset(MyAssets.clock, height: 16.w, width: 16.w),
             SizedBox(width: 10.w),
            Text('Select Time Range'.toUpperCase(), style: MyColors.l111111_dwhite(Get.context!).medium13)
          ],
        ),
      ),
    );
  }

  Widget _timeRangeWidget({required RequestDateModel requestDate, required int index}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _timeWidget(time: requestDate.startTime ?? '', index: index),
        SizedBox(width: 10.w),
        Container(width: 12.w, color: Colors.grey, height: 2.h),
        SizedBox(width: 10.w),
        _timeWidget(time: requestDate.endTime ?? '', index: index),
      ],
    );
  }

  Widget _timeWidget({required String time, required int index}) {
    return InkWell(
      onTap: ()=>Get.find<CalenderController>().showTimePickerBottomSheet(index: index),
      child: Container(
        padding:  EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 4.0.h),
        decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(5.0)),
        child: Row(
          children: [Image.asset(MyAssets.clock, height: 16.w, width: 16.w),  SizedBox(width: 10.w), Text(time, style: MyColors.l111111_dwhite(Get.context!).medium13)],
        ),
      ),
    );
  }
}

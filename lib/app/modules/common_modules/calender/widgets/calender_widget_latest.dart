import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/calender_month_widget.dart';

class CalenderWidgetLatest extends GetWidget<CalendarController> {
  const CalenderWidgetLatest({super.key});
///Request URL:
// https://server.plagit.com/api/v1/users/update-unavailable-date
// Request Method:
// PUT

  // {"dates":[{"startDate":"2025-01-21","endDate":"2025-01-21"}]}
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.49,
      child: Column(
        children: [
           SizedBox(height: 15.h),
          Obx(() => Text(
                controller.selectedDate.value.formatMonthYear(),
                style: Get.width>600?MyColors.l111111_dwhite(context).semiBold14:MyColors.l111111_dwhite(context).semiBold18,
              )),
           SizedBox(height: 15.h),
          Container(
            padding:  EdgeInsets.symmetric(vertical: 10.0.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: MyColors.primaryLight.withOpacity(0.4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controller.dayNames
                  .map((String dayName) => Text(
                        dayName,
                        style: Get.width>600?MyColors.l111111_dwhite(context).semiBold9:MyColors.l111111_dwhite(context).semiBold14,
                      ))
                  .toList(),
            ),
          ),
          SizedBox(height: 15.h),
          // Text("Heyy"),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: 2,
              itemBuilder: (context, index) {
                final DateTime now = DateTime.now();
                final DateTime month = DateTime(now.year, now.month + index, now.day);
                return CalenderMonthWidget(month: month, controller: controller);
              },
            ),
          ),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      decoration: BoxDecoration(
                          color: controller.selectedDate.value.month == DateTime.now().month
                              ? MyColors.c_C6A34F
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(5.0)),
                      width: 30.w,
                      height: 5.h),
                  const SizedBox(width: 10),
                  Container(
                      width: 30.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                          color: controller.selectedDate.value.month != DateTime.now().month
                              ? MyColors.c_C6A34F
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(5.0))),
                ],
              ))
        ],
      ),
    );
  }
}

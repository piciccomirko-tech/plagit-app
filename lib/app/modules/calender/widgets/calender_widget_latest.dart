import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/calender/widgets/calender_month_widget.dart';

class CalenderWidgetLatest extends GetWidget<CalenderController> {
  const CalenderWidgetLatest({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.49,
      child: Column(
        children: [
           SizedBox(height: 15.h),
          Obx(() => Text(
                controller.selectedDate.value.formatMonthYear(),
                style: MyColors.l111111_dwhite(context).semiBold18,
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
                        style: MyColors.l111111_dwhite(context).semiBold16,
                      ))
                  .toList(),
            ),
          ),
          SizedBox(height: 15.h),
          Expanded(
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: 2,
              itemBuilder: (context, index) {
                final DateTime month = DateTime.now().add(Duration(days: index * 30));
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

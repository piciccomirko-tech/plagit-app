import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/month_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/time_range_for_create_job.dart';

class JobCalenderWidget extends GetWidget<CreateJobPostController> {
  const JobCalenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(color: MyColors.lightCard(context), borderRadius: BorderRadius.circular(10.0)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkResponse(
                  onTap: () => Get.back(),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.clear, color: MyColors.white),
                  ),
                )
              ],
            ),
            Obx(() => Text(
                  controller.initialDate.value.formatMonthYear(),
                  style: MyColors.l111111_dwhite(context).semiBold18,
                )),
            SizedBox(height: 15.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.0.h),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0), color: MyColors.primaryLight.withOpacity(0.4)),
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
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.37,
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: 2,
                itemBuilder: (context, index) {
                  final DateTime now = DateTime.now();
                  final DateTime month = DateTime(now.year, now.month + index, now.day);
                  return MonthWidget(currentMonth: month, controller: controller);
                },
              ),
            ),
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            color: controller.initialDate.value.month == DateTime.now().month
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
                            color: controller.initialDate.value.month != DateTime.now().month
                                ? MyColors.c_C6A34F
                                : Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(5.0))),
                  ],
                )),
            SizedBox(height: 20.h),
            const TimeRangeForCreateJob(),
            SizedBox(height: 20.h),
            Obx(() =>  Visibility(
                visible: controller.requestDateList.hasNullAttributes() == false,
                child: CustomButtons.button(
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    text: "SUBMIT", onTap: controller.onDateSubmitClick)))
            //const TotalDaysCountWidget()
          ],
        ),
      ),
    );
  }
}

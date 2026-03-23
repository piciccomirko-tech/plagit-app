import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
import '../../../../common/utils/exports.dart';

class TotalDaysCountWidget extends GetWidget<CreateJobPostController> {
  const TotalDaysCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: MyColors.c_C6A34F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(MyAssets.calender1, height: 20, width: 20),
          Text(' ${MyStrings.total.tr} ' , style: MyColors.white.medium13),
          Obx(() => Text('${controller.requestDateList.calculateTotalDays()}', style: MyColors.white.semiBold24)),
          Text(' ${MyStrings.daysHaveBeenSelected.tr}', style: MyColors.white.medium13),
        ],
      ), 
    );
  }
}

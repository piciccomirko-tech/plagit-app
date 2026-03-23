import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/calender/controllers/calender_controller.dart';

import '../../../../helpers/responsive_helper.dart';

class SelectedDaysCountWidget extends GetWidget<CalendarController> {
  const SelectedDaysCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      width: MediaQuery.of(context).size.width * 0.7,
      padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: MyColors.c_C6A34F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(MyAssets.calender1, height: 20, width: 20),
          Text(' ${MyStrings.total.tr}',
              style: ResponsiveHelper.isTab(context)?MyColors.white.medium9:MyColors.white.medium13),
          Obx(() => Text(
              ' ${controller.appController.user.value.isEmployee? controller.totalSelectedDaysForEmployee : controller.requestDateList.calculateTotalDays()}',
              style: ResponsiveHelper.isTab(context)?MyColors.white.semiBold20:MyColors.white.semiBold24)),
          // if (controller.requestDateList.isNotEmpty && controller.requestDateList[0].startDate != null && controller.requestDateList[0].endDate != null)
          //   Text(
          //       '${DateTime.parse(controller.requestDateList[0].startDate ?? '').daysUntil(DateTime.parse(controller.requestDateList[0].endDate ?? ''))} ${DateTime.parse(controller.requestDateList[0].startDate ?? '').daysUntil(DateTime.parse(controller.requestDateList[0].endDate ?? '')) == 1 ? 'day' : 'days'}',
          //       style: MyColors.c_C6A34F.semiBold15),
           Text(' ${MyStrings.daysSelected.tr}',
              style: ResponsiveHelper.isTab(context)?MyColors.white.medium9:MyColors.white.medium13),
        ],
      ),
    );
  }
}

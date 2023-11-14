import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class SelectedDaysCountWidget extends GetWidget<CalenderController> {
  const SelectedDaysCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01),
      width: MediaQuery.of(context).size.width * 0.7,
      padding:  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: MyColors.c_C6A34F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(MyAssets.calender1, height: 20, width: 20),
          Text(' Total',
              style: MyColors.white.medium13),
          Obx(() => Text(
              ' ${Get.isRegistered<EmployeeHomeController>() == true ? controller.totalSelectedDaysForEmployee : controller.requestDateList.calculateTotalDays()}',
              style: MyColors.white.semiBold24)),
           Text(' Days have been selected',
              style: MyColors.white.medium13),
        ],
      ),
    );
  }
}

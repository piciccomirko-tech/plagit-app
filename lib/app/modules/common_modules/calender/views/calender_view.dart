import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/calender_bottom_nav_bar_widget.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/calender_header_widget.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/calender_widget_latest.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/employee_date_range_widget.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/selected_days_count_widget.dart';
import 'package:mh/app/modules/common_modules/calender/widgets/short_list_date_range_widget.dart';
import '../controllers/calender_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(title: MyStrings.selectDateRange.tr, context: context),
      bottomNavigationBar: const CalenderBottomNavBarWidget(),
      body: Obx(() {
        if (controller.dateDataLoading.value == true) {
          return Center(
              child: Lottie.asset(MyAssets.lottie.calenderLoading, fit: BoxFit.cover));
        } else {
          return Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0.sp, vertical: 15.0.sp),
                    child: const Column(
                      children: [CalenderHeaderWidget(), CalenderWidgetLatest()],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                  child: Align(
                      alignment: Alignment.bottomCenter,
                      child:  controller.appController.user.value.isEmployee
                          ? const EmployeeDateRangeWidget()
                          :const ShortListDateRangeWidget())),
              Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: controller.appController.user.value.isAdmin ? const Wrap() : const SelectedDaysCountWidget(),
                  )),
            ],
          );
        }
      }),
    );
  }
}

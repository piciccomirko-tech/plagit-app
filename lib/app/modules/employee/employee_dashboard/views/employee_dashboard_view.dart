import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: 'My Dashboard',
      ),
      body: Obx(
        () => controller.loading.value
            ? Center(child: CustomLoader.loading())
            : controller.history.isEmpty
                ? const NoItemFound()
                : Column(
                    children: [
                      SizedBox(height: 30.h),
                      Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 90.w,
                          rightHandSideColumnWidth: 520.w,
                          isFixedHeader: true,
                          headerWidgets: _getTitleWidget(),
                          leftSideItemBuilder: _generateFirstColumnRow,
                          rightSideItemBuilder: _generateRightHandSideColumnRow,
                          itemCount: (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).length,
                          rowSeparatorWidget: Container(
                            height: 6.h,
                            color: MyColors.lFAFAFA_dframeBg(context),
                          ),
                          leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                          rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Date', 90.w),
      _getTitleItemWidget('Check in', 100.w),
      _getTitleItemWidget('Check out', 100.w),
      _getTitleItemWidget('Break Time', 100.w),
      _getTitleItemWidget('Total hours', 100.w),
      _getTitleItemWidget('Complain', 120.w),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 62.h,
      color: MyColors.c_C6A34F,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: MyColors.lffffff_dframeBg(controller.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(controller.history[index]);

    return SizedBox(
      width: 90.w,
      height: 71.h,
      child: _cell(width: 90.w, value: dailyStatistics.date),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(controller.history[index]);

    return Row(
      children: <Widget>[
        _cell(width: 100.w, value: dailyStatistics.displayCheckInTime, clientUpdatedValue: dailyStatistics.employeeCheckInTime),
        _cell(width: 100.w, value: dailyStatistics.displayCheckOutTime, clientUpdatedValue: dailyStatistics.employeeCheckOutTime),
        _cell(width: 100.w, value: dailyStatistics.displayBreakTime, clientUpdatedValue: dailyStatistics.employeeBreakTime),
        _cell(width: 100.w, value: dailyStatistics.workingHour),
        _cell(width: 120.w, value: "--", child: _action(index)),
      ],
    );
  }

  Widget _cell({
    required double width,
    required String value,
    String? clientUpdatedValue,
    Widget? child,
  }) =>
      SizedBox(
        width: width,
        height: 71.h,
        child: child ?? Center(
          child: Text.rich(
            TextSpan(
              text: value,
              children: [
                TextSpan(
                  text: (clientUpdatedValue == null) || (clientUpdatedValue == value) ? "" : '\n$clientUpdatedValue',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                  )
                ),
              ]
            ),
            textAlign: TextAlign.center,
            style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          ),
        ),
      );

  Widget _action(int index) => controller.getComment(index).isEmpty
      ? const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 22,
        )
      : GestureDetector(
          onTap: () {
            CustomDialogue.information(
              context: controller.context!,
              title: "Restaurant Report on You",
              description: controller.getComment(index),
            );
          },
          child: const Icon(
            Icons.info,
            color: Colors.blue,
            size: 22,
          ),
        );
}

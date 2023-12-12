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
      body: Column(
        children: [
          const SizedBox(height: 15),
          Center(
            child: Container(
              width: Get.width*0.7,
              padding: const EdgeInsets.all(10.0),
              decoration: const BoxDecoration(
                color: MyColors.c_C6A34F,
                borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), bottomLeft: Radius.circular(10.0))
              ),
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(MyAssets.calender, height: 22, width: 22),
                    const SizedBox(
                      width: 5,
                    ),
                    Obx(
                          () => Text(
                        controller.selectedDate.value.EdMMMy,
                        style: MyColors.white.medium16,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(Icons.arrow_drop_down, color: MyColors.white),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Obx(
            () => controller.loading.value
                ? Center(child: CustomLoader.loading())
                : controller.history.isEmpty
                    ? const NoItemFound()
                    : Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 90.w,
                          rightHandSideColumnWidth: 670.w,
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
          )
        ],
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Date', 90.w),
      _getTitleItemWidget('Restaurant Name', 150.w),
      _getTitleItemWidget('Check In', 100.w),
      _getTitleItemWidget('Check Out', 100.w),
      _getTitleItemWidget('Break Time', 100.w),
      _getTitleItemWidget('Total Hours', 100.w),
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
        _cell(width: 150.w, value: dailyStatistics.restaurantName, clientUpdatedValue: dailyStatistics.restaurantName),
        _cell(
            width: 100.w,
            value: dailyStatistics.displayCheckInTime,
            clientUpdatedValue: dailyStatistics.employeeCheckInTime),
        _cell(
            width: 100.w,
            value: dailyStatistics.displayCheckOutTime,
            clientUpdatedValue: dailyStatistics.employeeCheckOutTime),
        _cell(
            width: 100.w,
            value: dailyStatistics.displayBreakTime,
            clientUpdatedValue: dailyStatistics.employeeBreakTime),
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
        child: child ??
            Center(
              child: Text.rich(
                TextSpan(text: value, children: [
                  TextSpan(
                      text:
                          (clientUpdatedValue == null) || (clientUpdatedValue == value) ? "" : '\n$clientUpdatedValue',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red, // Set the color here
                          decorationThickness: 2.0)),
                ]),
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.onDatePicked(picked);
    }
  }
}

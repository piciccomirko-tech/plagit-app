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
          SizedBox(height: 15.h),
          InkWell(
            onTap: () => _selectDateRange(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                    controller.isInitial.value == true
                        ? "FILTER BY DATE RANGE"
                        : "${controller.selectedStartDate.value.dMMMy} - ${controller.selectedEndDate.value.dMMMy}",
                    style: Colors.blue.semiBold18)),
                SizedBox(width: 15.w),
                Image.asset(MyAssets.calendar, height: 30, width: 30)
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Obx(
            () => controller.loading.value
                ? Center(child: CustomLoader.loading())
                : controller.history.isEmpty
                    ? const Center(child: NoItemFound())
                    : Expanded(
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollEndNotification &&
                                scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                              controller.loadMoreData();
                            }
                            return false;
                          },
                          child: CustomMultiChildLayout(
                            delegate: MyCustomMultiChildLayout(),
                            children: [
                              LayoutId(
                                id: 'dataTable',
                                child: Container(
                                  constraints: const BoxConstraints.expand(),
                                  child: PageView.builder(
                                    physics: controller.stopScrolling.value == false
                                        ? const BouncingScrollPhysics()
                                        : const NeverScrollableScrollPhysics(),
                                    controller: controller.pageController,
                                    itemCount: (controller.history.length / controller.pageSize.value).ceil(),
                                    itemBuilder: (BuildContext context, int pageIndex) {
                                      // Build your HorizontalDataTable for each page
                                      return HorizontalDataTable(
                                        leftHandSideColumnWidth: 90.w,
                                        rightHandSideColumnWidth: 670.w,
                                        isFixedHeader: true,
                                        headerWidgets: _getTitleWidget(),
                                        leftSideItemBuilder: (context, index) => _generateFirstColumnRow(
                                            context, index + pageIndex * controller.pageSize.value),
                                        rightSideItemBuilder: (context, index) => _generateRightHandSideColumnRow(
                                            context, index + pageIndex * controller.pageSize.value),
                                        itemCount: (controller.history.length / controller.pageSize.value).ceil() *
                                            controller.pageSize.value,
                                        rowSeparatorWidget: Container(
                                          height: 6.h,
                                          color: MyColors.lFAFAFA_dframeBg(context),
                                        ),
                                        leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                                        rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
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
    if (index < controller.history.length) {
      UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(controller.history[index]);

      return SizedBox(
        width: 90.w,
        height: 71.h,
        child: _cell(width: 90.w, value: dailyStatistics.date),
      );
    } else {
      // Return an empty or placeholder widget when the index is out of bounds
      return const SizedBox.shrink();
    }
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    if (index < controller.history.length) {
      UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(controller.history[index]);

      return Row(
        children: <Widget>[
          _cell(
              width: 150.w, value: dailyStatistics.restaurantName, clientUpdatedValue: dailyStatistics.restaurantName),
          _cell(
            width: 100.w,
            value: dailyStatistics.displayCheckInTime,
            clientUpdatedValue: dailyStatistics.employeeCheckInTime,
          ),
          _cell(
            width: 100.w,
            value: dailyStatistics.displayCheckOutTime,
            clientUpdatedValue: dailyStatistics.employeeCheckOutTime,
          ),
          _cell(
            width: 100.w,
            value: dailyStatistics.displayBreakTime,
            clientUpdatedValue: dailyStatistics.employeeBreakTime,
          ),
          _cell(width: 100.w, value: dailyStatistics.workingHour),
          _cell(width: 120.w, value: "--", child: _action(index)),
        ],
      );
    } else {
      // Return an empty or placeholder widget when the index is out of bounds
      return const SizedBox.shrink();
    }
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

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: controller.selectedStartDate.value,
        end: controller.selectedEndDate.value,
      ),
      builder: (BuildContext context, Widget? child) {
        // Check the current theme mode
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Theme(
          // Use white colors for light theme and dark colors for dark theme
          data: isDarkMode
              ? ThemeData.dark().copyWith(
                  // Adjust the dark mode colors as needed
                  primaryColor: Colors.grey[800], // Dark primary color
                  hintColor: Colors.grey[600], // Dark accent color
                  dialogBackgroundColor: Colors.grey[900], // Dark background color
                  // Add other color adjustments if needed
                )
              : ThemeData.light().copyWith(
                  // Adjust the light mode colors as needed
                  primaryColor: Colors.blue, // Light primary color
                  hintColor: Colors.blueAccent, // Light accent color
                  dialogBackgroundColor: Colors.white, // Light background color
                  // Add other color adjustments if needed
                ),
          child: child!,
        );
      },
    );

    if (picked != null &&
        (picked.start != controller.selectedStartDate.value || picked.end != controller.selectedEndDate.value)) {
      controller.onDateRangePicked(picked);
    }
  }
}

// MyCustomMultiChildLayout
class MyCustomMultiChildLayout extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    layoutChild('dataTable', BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild('dataTable', const Offset(0, 0));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

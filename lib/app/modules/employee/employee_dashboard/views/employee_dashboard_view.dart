import 'dart:developer';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: MyStrings.myDashboard.tr.replaceAll("\n", " "),
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
                        ? MyStrings.filterByDateRange.tr.toUpperCase()
                        : "${controller.selectedStartDate.value.dMMMy} - ${controller.selectedEndDate.value.dMMMy}",
                    style: Get.width > 600
                        ? Colors.blue.semiBold10
                        : Colors.blue.semiBold18)),
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
                                scrollInfo.metrics.pixels ==
                                    scrollInfo.metrics.maxScrollExtent) {
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
                                    physics: controller.stopScrolling.value ==
                                            false
                                        ? const BouncingScrollPhysics()
                                        : const NeverScrollableScrollPhysics(),
                                    controller: controller.pageController,
                                    itemCount: (controller.history.length /
                                            controller.pageSize.value)
                                        .ceil(),
                                    itemBuilder:
                                        (BuildContext context, int pageIndex) {
                                      // Build your HorizontalDataTable for each page
                                      return HorizontalDataTable(
                                        leftHandSideColumnWidth: 90.w,
                                        rightHandSideColumnWidth: 870.w,
                                        isFixedHeader: true,
                                        headerWidgets: _getTitleWidget(),
                                        leftSideItemBuilder: (context, index) =>
                                            _generateFirstColumnRow(
                                                context,
                                                index +
                                                    pageIndex *
                                                        controller
                                                            .pageSize.value),
                                        rightSideItemBuilder:
                                            (context, index) =>
                                                _generateRightHandSideColumnRow(
                                                    context,
                                                    index +
                                                        pageIndex *
                                                            controller.pageSize
                                                                .value),
                                        itemCount: (controller.history.length /
                                                    controller.pageSize.value)
                                                .ceil() *
                                            controller.pageSize.value,
                                        rowSeparatorWidget: Container(
                                          height: 6.h,
                                          color: MyColors.lFAFAFA_dframeBg(
                                              context),
                                        ),
                                        leftHandSideColBackgroundColor:
                                            MyColors.lffffff_dbox(context),
                                        rightHandSideColBackgroundColor:
                                            MyColors.lffffff_dbox(context),
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
          Obx(() => controller.isLoadingMoreData.value
              ? const SpinKitThreeBounce(
                  color: MyColors.primaryLight,
                  size: 30,
                )
              : SizedBox.shrink()),
        ],
      ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 90.w),
      _getTitleItemWidget(MyStrings.business.tr, 150.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
      _getTitleItemWidget(MyStrings.tips.tr, 100.w),
      _getTitleItemWidget(MyStrings.travel.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr} ${MyStrings.hours.tr}', 100.w),
      _getTitleItemWidget(MyStrings.comments.tr, 120.w),
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
          style: ResponsiveHelper.isTab(Get.context)
              ? MyColors.lffffff_dframeBg(controller.context!).semiBold10
              : MyColors.lffffff_dframeBg(controller.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    if (index < controller.history.length) {
      UserDailyStatistics dailyStatistics =
          Utils.checkInOutToStatistics(controller.history[index]);

      return SizedBox(
        width: 90.w,
        height: 71.h,
        child: SizedBox(
          width: 90.w,
          height: 71.h,
          child: Center(
            child: Text(
              dailyStatistics.date,
              textAlign: TextAlign.center,
              style: ResponsiveHelper.isTab(Get.context)
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            ),
          ),
        ),
      );
    } else {
      // Return an empty or placeholder widget when the index is out of bounds
      return const SizedBox.shrink();
    }
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    if (index < controller.history.length) {
      UserDailyStatistics dailyStatistics =
          Utils.checkInOutToStatistics(controller.history[index]);
      //  controller.history[index]
      final DateFormat timeFormat = DateFormat("HH:mm:ss a");
      CheckInCheckOutHistoryElement hiredHistory = controller.history[index];

      return Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              // Create the ClientId object
              ClientId clientId = ClientId(
                id: hiredHistory.hiredBy ?? '',
                role: 'CLIENT',
                email: hiredHistory.restaurantDetails?.email ?? '',
                countryName: hiredHistory.restaurantDetails?.countryName ?? '',
                restaurantName:
                    hiredHistory.restaurantDetails?.restaurantName ?? '',
                restaurantAddress:
                    hiredHistory.restaurantDetails?.restaurantAddress ?? '',
                profilePicture:
                    hiredHistory.restaurantDetails?.profilePicture ?? '',
                name: hiredHistory.restaurantDetails?.restaurantName ?? '',
              );
              log("dashboard img url: ${hiredHistory.restaurantDetails?.profilePicture ?? ''}");
              Get.toNamed(
                Routes.individualSocialFeeds,
                arguments: controller.clientIdToSocialUser(clientId
                    // }
                    ),
              );
            },
            // onTap: (){
            //   //  Get.toNamed(Routes.individualSocialFeeds,
            //   //                   arguments: hiredHistory.c);
            //                 // :
            //                  Get.toNamed(Routes.employeeDetails,
            //                     arguments: {'employeeId':hiredHistory.hiredBy ?? "",   'isCandidate':
            //                                       false });
            // },
            child: _cell(
                width: 150.w,
                value: dailyStatistics.restaurantName,
                clientUpdatedValue: dailyStatistics.restaurantName),
          ),
          // _cell(
          //   width: 100.w,
          //   value: dailyStatistics.displayCheckInTime,
          //   clientUpdatedValue: dailyStatistics.employeeCheckInTime,
          // ),
          // _cell(
          //   width: 100.w,
          //   value: dailyStatistics.displayCheckOutTime,
          //   clientUpdatedValue: dailyStatistics.employeeCheckOutTime,
          // ),
          // _cell(
          //   width: 100.w,
          //   value: dailyStatistics.displayBreakTime,
          //   clientUpdatedValue: dailyStatistics.employeeBreakTime,
          // ),
          hiredHistory.checkInCheckOutDetails?.clientCheckInTime == null
              ? _cell(
                  width: 100.w,
                  value: dailyStatistics.displayCheckInTime,
                  clientUpdatedValue: dailyStatistics.employeeCheckInTime,
                )
              : _cell(
                  width: 100.w,
                  value: dailyStatistics.employeeCheckInTime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Strike-through for the original check-in time
                      Text(
                        dailyStatistics.employeeCheckInTime,
                        style: TextStyle(
                          fontFamily: MyAssets.fontKlavika,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: MyColors.primaryLight,
                          fontSize:
                              ResponsiveHelper.isTab(Get.context) ? 9 : 13,
                          decorationThickness:
                              3.0, // Increase this value for a thicker line
                          color: Colors
                              .grey, // Optional: makes it appear "disabled"
                        ),
                      ),
                      // Regular display for the client updated check-in time
                      Text(
                          timeFormat.format(DateTime.parse(hiredHistory
                              .checkInCheckOutDetails!.clientCheckInTime
                              .toString())),
                          style: ResponsiveHelper.isTab(Get.context)
                              ? MyColors.l7B7B7B_dtext(controller.context!)
                                  .semiBold9
                              : MyColors.l7B7B7B_dtext(controller.context!)
                                  .semiBold13),
                    ],
                  ),
                ),

          hiredHistory.checkInCheckOutDetails!.clientCheckOutTime == null
              ? _cell(
                  width: 100.w,
                  value: dailyStatistics.displayCheckOutTime,
                  clientUpdatedValue: dailyStatistics.employeeCheckOutTime)
              : _cell(
                  width: 100.w,
                  value: dailyStatistics.displayCheckOutTime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Strike-through for the original check-in time
                      Text(
                        dailyStatistics.employeeCheckOutTime,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: MyColors.primaryLight,
                          decorationThickness:
                              3.0, // Increase this value for a thicker line
                          color: Colors
                              .grey, // Optional: makes it appear "disabled"
                        ),
                      ),
                      // Regular display for the client updated check-in time
                      Text(
                        timeFormat.format(DateTime.parse(hiredHistory
                            .checkInCheckOutDetails!.clientCheckOutTime
                            .toString())),
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: Colors.grey, // Regular color
                        ),
                      ),
                    ],
                  ),
                ),
          hiredHistory.checkInCheckOutDetails!.clientBreakTime == null ||
                  hiredHistory.checkInCheckOutDetails!.clientBreakTime == 0 ||
                  hiredHistory.checkInCheckOutDetails!.clientBreakTime == '-'
              ? _cell(
                  width: 100.w,
                  value: dailyStatistics.displayBreakTime == '-' ? '0' : '',
                  clientUpdatedValue:
                      dailyStatistics.employeeBreakTime == '-' ? '0' : '')
              : _cell(
                  width: 100.w,
                  value: dailyStatistics.displayBreakTime,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Strike-through for the original check-in time
                      Text(
                        dailyStatistics.employeeBreakTime == '-' ? '0' : '',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: MyColors.primaryLight,
                          decorationThickness:
                              3.0, // Increase this value for a thicker line
                          color: Colors
                              .grey, // Optional: makes it appear "disabled"
                        ),
                      ),
                      // Regular display for the client updated check-in time
                      if (hiredHistory.checkInCheckOutDetails!.clientBreakTime
                          .toString()
                          .isNotEmpty)
                        Text(
                          hiredHistory.checkInCheckOutDetails!.clientBreakTime
                              .toString(),
                          style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.grey, // Regular color
                          ),
                        ),
                    ],
                  ),
                ),
          _cell(
              width: 100.w,
              value: '\$${hiredHistory.travelCost}',
              clientUpdatedValue:
                  '\$${hiredHistory.travelCost}'), // Tips column
          _cell(
              width: 100.w,
              value: '\$${hiredHistory.tips}',
              clientUpdatedValue: '\$${hiredHistory.tips}'), // Tips column
          // _cell(width: 100.w, value: dailyStatistics.workingHour),
          SizedBox(
            width: 100.w,
            height: 71.h,
            child: Center(
              child: Text(
                '${hiredHistory.workedHour} H',
                textAlign: TextAlign.center,
                style: ResponsiveHelper.isTab(Get.context)
                    ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                    : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
            ),
          ),
          _cell(
              width: 120.w,
              value: dailyStatistics.workingHour,
              child: Center(
                child: Text(
                  hiredHistory.checkInCheckOutDetails?.clientComment ?? '',
                  textAlign: TextAlign.center,
                  style: ResponsiveHelper.isTab(Get.context)
                      ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                      : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
                ),
              )),
          // _cell(width: 120.w, value: "--", child: _action(index)),
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
              child: Text(
                clientUpdatedValue.toString(),
                textAlign: TextAlign.center,
                style: ResponsiveHelper.isTab(Get.context)
                    ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                    : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
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

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: Get.height - 140,
              ),
              child: Theme(
                // Use white colors for light theme and dark colors for dark theme
                data: isDarkMode
                    ? ThemeData.dark().copyWith(
                        // Adjust the dark mode colors as needed
                        primaryColor: Colors.grey[800], // Dark primary color
                        hintColor: Colors.grey[600], // Dark accent color
                        dialogBackgroundColor:
                            Colors.grey[900], // Dark background color
                        // Add other color adjustments if needed
                        textTheme: TextTheme(
                          bodyMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          labelLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          labelMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          labelSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          titleLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          titleMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          titleSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          displayLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          displayMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          displaySmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          headlineLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          headlineMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                          headlineSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.white54),
                        ),
                      )
                    : ThemeData.light().copyWith(
                        // Adjust the light mode colors as needed
                        primaryColor: Colors.blue, // Light primary color
                        hintColor: Colors.blueAccent, // Light accent color
                        dialogBackgroundColor:
                            Colors.white, // Light background color
                        // Add other color adjustments if needed
                        textTheme: TextTheme(
                          bodyMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          labelLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          labelMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          labelSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          titleLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          titleMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          titleSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          displayLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          displayMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          displaySmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          headlineLarge: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          headlineMedium: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                          headlineSmall: TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              color: Colors.black54),
                        ),
                      ),
                child: child!,
              ),
            ),
          ],
        );
      },
    );

    if (picked != null &&
        (picked.start != controller.selectedStartDate.value ||
            picked.end != controller.selectedEndDate.value)) {
      controller.onDateRangePicked(picked);
    }
  }
}

// MyCustomMultiChildLayout
class MyCustomMultiChildLayout extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    layoutChild('dataTable',
        BoxConstraints.tightFor(width: size.width, height: size.height));
    positionChild('dataTable', const Offset(0, 0));
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }
}

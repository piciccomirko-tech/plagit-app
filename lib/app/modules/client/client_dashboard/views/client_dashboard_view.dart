import 'package:flutter_switch/flutter_switch.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/client_dashboard_controller.dart';
import '../widgets/client_dashboard_edit_checkout_history_modal.dart';

class ClientDashboardView extends GetView<ClientDashboardController> {
  const ClientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = Get.context;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppbar.appbar(
        title: MyStrings.dashboard.tr,
        context: context,
      ),
      body: Obx(
        () => controller.loading.value
            ? ShimmerWidget.clientDashboardShimmerEffectWidget()
            : (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ??
                        [])
                    .isEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Row(
                                  children: [
                                    Text(
                                      controller.selectedDate.value,
                                      style: MyColors.l111111_dwhite(context)
                                          .medium16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down_circle,
                                        color: MyColors.c_C6A34F)
                                  ],
                                ),
                              ),
                              Text(
                                MyStrings.noCandidateFound.tr,
                                style: MyColors.c_C6A34F.semiBold16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Expanded(child: NoItemFound()),
                    ],
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Row(
                                  children: [
                                    Text(
                                      controller.selectedDate.value,
                                      style: MyColors.l111111_dwhite(context)
                                          .medium16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down_circle,
                                        color: MyColors.c_C6A34F)
                                  ],
                                ),
                              ),
                              Text(
                                controller.totalActiveEmployee.length > 1
                                    ? "${controller.totalActiveEmployee.length} ${MyStrings.employeesActive.tr}"
                                    : "${controller.totalActiveEmployee.length} ${MyStrings.employeeActive.tr}",
                                style: MyColors.c_C6A34F.semiBold16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 150.w,
                          rightHandSideColumnWidth: 1450.w,
                          isFixedHeader: true,
                          headerWidgets: _getTitleWidget(),
                          leftSideItemBuilder: _generateFirstColumnRow,
                          rightSideItemBuilder: _generateRightHandSideColumnRow,
                          itemCount: (controller.checkInCheckOutHistory.value
                                      .checkInCheckOutHistory ??
                                  [])
                              .length,
                          rowSeparatorWidget: Container(
                            height: 6.h,
                            color: MyColors.lFAFAFA_dframeBg(context),
                          ),
                          leftHandSideColBackgroundColor:
                              MyColors.lffffff_dbox(context),
                          rightHandSideColBackgroundColor:
                              MyColors.lffffff_dbox(context),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.dashboardDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            textTheme: TextTheme(
              titleLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              titleMedium: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              titleSmall: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              displayMedium: TextStyle(fontSize: 24, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              headlineMedium: TextStyle(fontSize: 24, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.bold),
              bodyLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika,),
              labelLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.w500),
              headlineLarge: TextStyle(fontSize: 18, fontFamily: MyAssets.fontKlavika, fontWeight: FontWeight.w500),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != controller.dashboardDate.value) {
      controller.onDatePicked(picked);
    }
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 150.w),
      _getTitleItemWidget(MyStrings.employee.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 100.w),
      _getTitleItemWidget('Per Hour Rate', 100.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
      _getTitleItemWidget(MyStrings.travel.tr, 100.w),
      _getTitleItemWidget(MyStrings.tips.tr, 100.w),
      _getTitleItemWidget(MyStrings.totalHour.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr} ${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget('${MyStrings.business.tr} ${MyStrings.comments.tr}', 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
      _getTitleItemWidget(MyStrings.edit.tr, 100.w),
      _getTitleItemWidget(MyStrings.history.tr, 100.w),
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
          style: MyColors.lffffff_dframeBg(Get.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    CheckInCheckOutHistoryElement hiredHistory = (controller
        .checkInCheckOutHistory.value.checkInCheckOutHistory![index]);

    DateTime parsedDate = hiredHistory.createdAt ?? DateTime.now();

    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    return _cell(
      width: 150.w,
      value: formattedDate,
      clientUpdatedValue: formattedDate,
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
        height: 75.h,
        child: child ??
            Center(
              child: Text.rich(
                TextSpan(text: clientUpdatedValue),
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
            ),
      );

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    CheckInCheckOutHistoryElement hiredHistory =
        controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index];

    UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(
        controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index]);
    final DateFormat timeFormat = DateFormat("hh:mm:ss a");

    return Row(
      children: <Widget>[
        _cell(
          width: 150.w,
          value: '',
          child: _employeeDetails(
            hiredHistory.employeeDetails?.employeeId ?? "",
            hiredHistory.employeeDetails?.name ?? "-",
            hiredHistory.employeeDetails?.profilePicture ?? "",
          ),
        ),

        _cell(
          width: 100.w,
          value: '',
          clientUpdatedValue: Utils.getPositionName(
              hiredHistory.employeeDetails?.positionId ?? ''),
        ),

        _cell(
          width: 100.w,
          value: '',
          clientUpdatedValue:
              (hiredHistory.employeeDetails?.contractorHourlyRate ?? 0)
                  .toStringAsFixed(2),
        ),

        (hiredHistory.checkInCheckOutDetails!.clientCheckInTime == null ||
                (controller.dateToTimeString(hiredHistory
                            .checkInCheckOutDetails!.clientCheckInTime
                            ?.toString()) ==
                        dailyStatistics.employeeCheckInTime
                            .toString()
                            .replaceAll(' ', '') &&
                    hiredHistory.checkInCheckOutDetails!.clientCheckInTime !=
                        null))
            ? _cell(
                width: 100.w,
                value: dailyStatistics.displayCheckInTime,
                clientUpdatedValue: dailyStatistics.employeeCheckInTime,
              )
            : _cell(
                width: 100.w,
                value: dailyStatistics.displayCheckInTime,
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
                        decorationThickness:
                            3.0, // Increase this value for a thicker line
                        color:
                            Colors.grey, // Optional: makes it appear "disabled"
                      ),
                    ),
                    // Regular display for the client updated check-in time
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                              .checkInCheckOutDetails!.clientCheckInTime
                              .toString())),
                      style: TextStyle(
                        fontFamily: MyAssets.fontKlavika,
                        decoration: TextDecoration.none,
                        color: Colors.grey, // Regular color
                      ),
                    ),
                    // Text("${hiredHistory
                    //       .checkInCheckOutDetails!.clientCheckInTime
                    //       }")
                  ],
                ),
              ),

        (hiredHistory.checkInCheckOutDetails!.clientCheckOutTime == null ||
                (controller.dateToTimeString(hiredHistory
                            .checkInCheckOutDetails!.clientCheckOutTime
                            ?.toString()) ==
                        dailyStatistics.employeeCheckOutTime
                            .toString()
                            .replaceAll(' ', '') &&
                    hiredHistory.checkInCheckOutDetails!.clientCheckOutTime !=
                        null))
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
                        fontFamily: MyAssets.fontKlavika,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: MyColors.primaryLight,
                        decorationThickness:
                            3.0, // Increase this value for a thicker line
                        color:
                            Colors.grey, // Optional: makes it appear "disabled"
                      ),
                    ),
                    // Regular display for the client updated check-in time
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                          .checkInCheckOutDetails!.clientCheckOutTime
                          .toString())),
                      style: TextStyle(
                        fontFamily: MyAssets.fontKlavika,
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
                value: dailyStatistics.displayBreakTime == '-' ? '0 min' : '',
                clientUpdatedValue:
                    dailyStatistics.employeeBreakTime == '-' ? '0 min' : '')
            : _cell(
                width: 100.w,
                value: dailyStatistics.displayBreakTime,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Strike-through for the original check-in time
                    Text(
                      dailyStatistics.employeeBreakTime == '-' ? '0 min' : '',
                      style: TextStyle(
                        fontFamily: MyAssets.fontKlavika,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: MyColors.primaryLight,
                        decorationThickness:
                            3.0, // Increase this value for a thicker line
                        color:
                            Colors.grey, // Optional: makes it appear "disabled"
                      ),
                    ),
                    // Regular display for the client updated check-in time
                    if (hiredHistory.checkInCheckOutDetails!.clientBreakTime
                        .toString()
                        .isNotEmpty)
                      Text(
                        '${hiredHistory.checkInCheckOutDetails!.clientBreakTime} min',
                        style: TextStyle(
                          fontFamily: MyAssets.fontKlavika,
                          decoration: TextDecoration.none,
                          color: Colors.grey, // Regular color
                        ),
                      ),
                  ],
                ),
              ),

        _cell(
            width: 100.w,
            value:
                '${Utils.getCurrencySymbol()} ${hiredHistory.travelCost ?? 0.0}',
            clientUpdatedValue:
                '${Utils.getCurrencySymbol()} ${hiredHistory.travelCost ?? 0.0}'), // Tips column
        _cell(
            width: 100.w,
            value: '${Utils.getCurrencySymbol()} ${hiredHistory.tips ?? 0.0}',
            clientUpdatedValue:
                '${Utils.getCurrencySymbol()} ${hiredHistory.tips ?? 0.0}'), // Tips column
        _cell(
            width: 100.w,
            value: "",
            clientUpdatedValue:
                controller.formatWorkedHours(hiredHistory.workedHour!)),
        _cell(
          width: 100.w,
          value: "",
          clientUpdatedValue:
              (hiredHistory.totalAmount ?? 0).toStringAsFixed(2),
        ),
        _cell(
            width: 100.w,
            value: "",
            child: hiredHistory.checkInCheckOutDetails!.clientComment != null &&
                    hiredHistory
                        .checkInCheckOutDetails!.clientComment!.isNotEmpty
                ? Center(
                  child: Text(hiredHistory.checkInCheckOutDetails!.clientComment
                      .toString(),style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,),
                )
                : SizedBox()),
        _cell(
            width: 100.w,
            value: "-",
            child: FlutterSwitch(
              showOnOff: true,
              activeText: MyStrings.paid.tr,
              inactiveText: MyStrings.due.tr,
              valueFontSize: 8.0,
              activeTextColor: Colors.white,
              inactiveTextColor: Colors.black26,
              width: 60.0,
              height: 30.0,
              toggleSize: 25.0,
              borderRadius: 15.0,
              padding: 4.0,
              activeColor: MyColors.primaryLight,
              inactiveColor: Colors.grey.shade300,
              activeToggleColor: Colors.white,
              inactiveToggleColor: Colors.white,
              value: hiredHistory.employeePaymentStatus ?? false,
              onToggle: (newVal) {
                controller.togglePaymentStatusSwitch(index,'${hiredHistory.id}', newVal);
              },
            )),
        _cell(
          width: 100.w,
          value: "",
          child: GestureDetector(
            onTap: () {
              _openEditModal(hiredHistory);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit,
                  color: MyColors.primaryLight,
                ),
                SizedBox(width: 5.w),
                Text(
                  MyStrings.edit.tr,
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                ),
              ],
            ),
          ),
        ),
        _cell(
          width: 100.w,
          value: "",
          child: GestureDetector(
            onTap: () {
              controller.viewCheckInCheckOutHistory('${hiredHistory.currentHiredEmployeeId}');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  color: MyColors.primaryLight,
                ),
                SizedBox(width: 5.w),
                Text(
                  MyStrings.history.tr,
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                ),
              ],
            ),
          ),
        ), // Note column
      ],
    );
  }

  void _openEditModal(CheckInCheckOutHistoryElement history) {
    if (history.id!.isNotEmpty) {
      Get.bottomSheet(
        isDismissible: true,
        enableDrag: true,
        ignoreSafeArea: true,
        EditDetailsModal(
          history: history,
        ),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
    }
    // Pass `history` data to the modal as needed
    // You might need to use the controller or set up reactive variables
    // inside `EditDetailsModal` to display `history` details.
  }

  Widget _employeeDetails(
    String id,
    String name,
    String image,
  ) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.employeeDetails,
            arguments: {'employeeId': id});
      },
      child: Center(
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 25.h,
                  width: 24.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.grey.withOpacity(.3),
                  ),
                  child: (image.isEmpty || image == "undefined")
                      ? DefaultImageWidget(
                          defaultImagePath: MyAssets.employeeDefault)
                      : CustomNetworkImage(
                          url: image.imageUrl,
                          radius: 8.0,
                        ),
                ),
              ],
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l5C5C5C_dwhite(controller.context!).semiBold11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _chat(
  //         {required EmployeeDetails employeeDetails,
  //         required String bookingId}) =>
  //     GestureDetector(
  //       onTap: () => controller.chatWithEmployee(
  //           employeeDetails: employeeDetails, bookingId: bookingId),
  //       child: const Center(
  //         child: Stack(
  //           clipBehavior: Clip.none,
  //           children: [
  //             Icon(
  //               Icons.message,
  //               color: MyColors.c_C6A34F,
  //             ),
  //             /*  Positioned(
  //               top: -10.h,
  //               right: -5.w,
  //               child: Obx(
  //                 () {
  //                   Iterable<Map<String, dynamic>> result = controller.clientHomeController.employeeChatDetails.where(
  //                       (Map<String, dynamic> data) =>
  //                           data["employeeId"] == employeeDetails.employeeId &&
  //                           data["${controller.appController.user.value.userId}_unread"] > 0);
  //
  //                   if (result.isEmpty) return Container();
  //                   return CustomBadge(result.first["${controller.appController.user.value.userId}_unread"].toString());
  //                 },
  //               ),
  //             ),*/
  //           ],
  //         ),
  //       ),
  //     );
}

class BottomA extends StatelessWidget {
  final Widget updateOption;

  const BottomA(this.updateOption, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(
            bottom: Get.find<AppController>().bottomPadding.value),
        child: updateOption,
      ),
    );
  }
}

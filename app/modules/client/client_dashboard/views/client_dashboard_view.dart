import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/employee_details.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../controllers/client_dashboard_controller.dart';

class ClientDashboardView extends GetView<ClientDashboardController> {
  const ClientDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.dashboard.tr,
        context: context,
      ),
      body: Obx(
        () => controller.loading.value
            ? Center(child: CustomLoader.loading())
            : (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).isEmpty
                ? Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                                      style: MyColors.l111111_dwhite(context).medium16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down_circle, color: MyColors.c_C6A34F)
                                  ],
                                ),
                              ),
                              Text(
                                MyStrings.noEmployeeFound.tr,
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
                                      style: MyColors.l111111_dwhite(context).medium16,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(Icons.arrow_drop_down_circle, color: MyColors.c_C6A34F)
                                  ],
                                ),
                              ),
                              Text(
                                controller.totalActiveEmployee.length > 1
                                    ? "${controller.totalActiveEmployee.length} Employees Active"
                                    : "${controller.totalActiveEmployee.length} Employee Active",
                                style: MyColors.c_C6A34F.semiBold16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 143.w,
                          rightHandSideColumnWidth: 500.w,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.dashboardDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).brightness == Brightness.light
              ? ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: MyColors.c_C6A34F,
                    onPrimary: Colors.white,
                    onSurface: MyColors.l111111_dwhite(context),
                  ),
                )
              : ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: MyColors.c_C6A34F,
                    onPrimary: Colors.white,
                    onSurface: MyColors.l111111_dwhite(context),
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
      _getTitleItemWidget('Employee', 143.w),
      _getTitleItemWidget('Check in', 100.w),
      _getTitleItemWidget('Check out', 100.w),
      _getTitleItemWidget('Break Time', 100.w),
      _getTitleItemWidget('Total hours', 100.w),
      _getTitleItemWidget('Chat', 100.w),
      // _getTitleItemWidget('Complain', 100.w),
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
    CheckInCheckOutHistoryElement hiredHistory = controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index];

    return SizedBox(
      width: 143.w,
      height: 71.h,
      child: _cell(
        width: 143.w,
        value: '-',
        child: _employeeDetails(
          hiredHistory.employeeDetails?.employeeId ?? "",
          hiredHistory.employeeDetails?.name ?? "-",
          Utils.getPositionName(hiredHistory.employeeDetails?.positionId ?? ''),
          hiredHistory.employeeDetails?.profilePicture ?? "",
        ),
      ),
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
              child: /*Text(value, textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13)*/
                  Text.rich(
                TextSpan(text: clientUpdatedValue)
                /*TextSpan(text: value, children: [
                  TextSpan(
                      text:
                          (clientUpdatedValue == null) || (clientUpdatedValue == value) ? "" : '\n$clientUpdatedValue',
                      style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red, // Set the color here
                          decorationThickness: 2.0)),
                ])*/
                ,
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
            ),
      );

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    CheckInCheckOutHistoryElement hiredHistory = controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index];

    if (hiredHistory.checkInCheckOutDetails == null) {
      return Row(
        children: <Widget>[
          _cell(width: 100.w, value: "-"),
          _cell(width: 100.w, value: "-"),
          _cell(width: 100.w, value: "-"),
          _cell(width: 100.w, value: "-"),
          _cell(width: 100.w, value: "", child: _chat(employeeDetails: hiredHistory.employeeDetails!, bookingId: hiredHistory.bookingId??"")),
          /*  _cell(
            width: 100.w,
            value: "-",
          ),*/
        ],
      );
    }

    UserDailyStatistics dailyStatistics =
        Utils.checkInOutToStatistics(controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index]);
    return Row(
      children: <Widget>[
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
            clientUpdatedValue: dailyStatistics.employeeBreakTime
        ),
        _cell(width: 100.w, value:"" , clientUpdatedValue: dailyStatistics.workingHour
        ),
        _cell(width: 100.w, value: "", child: _chat(employeeDetails: hiredHistory.employeeDetails!, bookingId: hiredHistory.bookingId??"")),
        /*  _cell(width: 100.w, value: "--", child: const CircleAvatar(
          backgroundColor: Colors.transparent,
            child: Icon(Icons.check_box, color: Colors.green))
        //_action(index)
        ),*/
      ],
    );
  }

  Widget _employeeDetails(
    String id,
    String name,
    String positionName,
    String image,
  ) {
    return Container(
      width: 143.w,
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: MyColors.lightCard(controller.context!),
        border: Border(
          right: BorderSide(width: 3.0, color: Colors.grey.withOpacity(.1)),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 24.h,
                      width: 24.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.withOpacity(.3),
                      ),
                      child: CustomNetworkImage(
                        url: image.imageUrl,
                        radius: 8.0,
                      ),
                    ),
                   /* Positioned(
                      top: -15,
                      right: -3,
                      child: Obx(
                        () => Visibility(
                          visible: controller.clientHomeController.employeeChatDetails
                              .where((Map<String, dynamic> data) =>
                                  data["employeeId"] == id &&
                                  data["${controller.appController.user.value.userId}_unread"] > 0)
                              .isNotEmpty,
                          child: const CustomBadge(""),
                        ),
                      ),
                    ),*/
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
            SizedBox(height: 6.h),
            Text(
              positionName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MyColors.l50555C_dtext(controller.context!).medium12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chat({required EmployeeDetails employeeDetails, required String bookingId}) => GestureDetector(
        onTap: () => controller.chatWithEmployee(employeeDetails: employeeDetails, bookingId: bookingId),
        child: const Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.message,
                color: MyColors.c_C6A34F,
              ),
            /*  Positioned(
                top: -10.h,
                right: -5.w,
                child: Obx(
                  () {
                    Iterable<Map<String, dynamic>> result = controller.clientHomeController.employeeChatDetails.where(
                        (Map<String, dynamic> data) =>
                            data["employeeId"] == employeeDetails.employeeId &&
                            data["${controller.appController.user.value.userId}_unread"] > 0);

                    if (result.isEmpty) return Container();
                    return CustomBadge(result.first["${controller.appController.user.value.userId}_unread"].toString());
                  },
                ),
              ),*/
            ],
          ),
        ),
      );
}

class BottomA extends StatelessWidget {
  final Widget updateOption;

  const BottomA(this.updateOption, {super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.only(bottom: Get.find<AppController>().bottomPadding.value),
        child: updateOption,
      ),
    );
  }
}

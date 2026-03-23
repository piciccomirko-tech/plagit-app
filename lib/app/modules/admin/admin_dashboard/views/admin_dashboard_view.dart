import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/client/client_dashboard/views/client_dashboard_view.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends GetView<AdminDashboardController> {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: MyStrings.dashboard.tr,
      ),
      body: Obx(
        () => controller.historyLoading.value
            ? Center(child: CustomLoader.loading())
            : SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Row(
                              children: [
                                Obx(
                                  () => Text(
                                    controller.dashboardDate.value.EdMMMy,
                                    style: MyColors.l111111_dwhite(context)
                                        .medium16,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.arrow_drop_down_circle,
                                  size: Get.width > 600 ? 15.sp : 16,
                                  color: MyColors.c_C6A34F,
                                ),
                              ],
                            ),
                          ),
                          /* Expanded(
                            child: SizedBox(
                              height: 40.h,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Obx(
                                  () => DropdownButtonFormField<String>(
                                    dropdownColor: MyColors.lightCard(context),
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    onChanged: controller.onClientChange,
                                    isExpanded: true,
                                    itemHeight: 58.h,
                                    isDense: false,
                                    hint: Text(
                                      controller.clientLoading.value ? "Loading..." : "Select Client",
                                      style: MyColors.l7B7B7B_dtext(context).regular18,
                                    ),
                                    value: "ALL",
                                    items: controller.restaurants.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: MyColors.l111111_dwhite(context).regular16_5,
                                        ),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).cardColor,
                                      // contentPadding: const EdgeInsets.fromLTRB(0, 4, 8, 4),
                                      floatingLabelStyle: const TextStyle(
                                        fontFamily: MyAssets.fontMontserrat,
                                        fontWeight: FontWeight.w600,
                                        color: MyColors.c_C6A34F,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 5),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(width: 1),
                                        borderRadius: BorderRadius.circular(10.73),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(width: .5, color: MyColors.c_777777),
                                        borderRadius: BorderRadius.circular(10.73),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(width: 1, color: MyColors.c_C6A34F),
                                        borderRadius: BorderRadius.circular(10.73),
                                        gapPadding: 10,
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(width: 1, color: Colors.redAccent),
                                        borderRadius: BorderRadius.circular(10.73),
                                      ),
                                      hintMaxLines: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )*/
                        ],
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: (controller.checkInCheckOutHistory.value
                                    .checkInCheckOutHistory ??
                                [])
                            .isNotEmpty,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          padding: const EdgeInsets.symmetric(vertical: 17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              width: .5,
                              color: MyColors.c_A6A6A6,
                            ),
                            color: MyColors.lightCard(controller.context!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                  child: _itemValue(
                                      MyStrings.client.tr,
                                      controller.uniqueClient.value
                                          .toString())),
                              _vDivider,
                              Expanded(
                                  // child: _itemValue(MyStrings.hours.tr,
                                  //     (controller.totalWorkingTimeInMinutes.value / 60).toStringAsFixed(1))),
                                  child: _itemValue(MyStrings.hours.tr,
                                      ("${controller.totalWorkedHours.value}"))),
                              _vDivider,
                              Expanded(
                                  child: _itemValue(
                                      MyStrings.amount.tr,
                                      // "${Utils.getCurrencySymbol()}${controller.amount.value.toStringAsFixed(2)}")),
                                      "${Utils.getCurrencySymbol()}${controller.totalAmountForAdmin.value.toStringAsFixed(2)}")),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: (controller.checkInCheckOutHistory.value
                                    .checkInCheckOutHistory ??
                                [])
                            .isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            "${controller.history.length} ${MyStrings.candidates.tr} ${MyStrings.active.tr}",
                            style: MyColors.c_C6A34F.semiBold16,
                          ),
                        ),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: (controller.checkInCheckOutHistory.value
                                    .checkInCheckOutHistory ??
                                [])
                            .isEmpty,
                        child: controller.historyLoading.value
                            ? const CircularProgressIndicator.adaptive(
                                backgroundColor: MyColors.c_C6A34F,
                              )
                            : const NoItemFound(),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: (controller.checkInCheckOutHistory.value
                                    .checkInCheckOutHistory ??
                                [])
                            .isNotEmpty,
                        child: Expanded(
                          child: HorizontalDataTable(
                            leftHandSideColumnWidth: 90.w,
                            rightHandSideColumnWidth: 1470.w,
                            isFixedHeader: true,
                            headerWidgets: _getTitleWidget(),
                            leftSideItemBuilder: _generateFirstColumnRow,
                            rightSideItemBuilder:
                                _generateRightHandSideColumnRow,
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
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _itemValue(String text, String value) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: MyColors.c_C6A34F.semiBold22,
          ),
          const SizedBox(height: 5),
          Text(
            text,
            textAlign: TextAlign.center,
            style: MyColors.l7B7B7B_dtext(controller.context!).medium12,
          ),
        ],
      );

  Widget get _vDivider => Container(
        width: .5,
        height: 30,
        color: MyColors.l111111_dwhite(controller.context!),
      );

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
      _getTitleItemWidget(MyStrings.date.tr, 90.w),
      _getTitleItemWidget(MyStrings.restaurantName.tr, 150.w),
      _getTitleItemWidget(MyStrings.candidateName.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
      _getTitleItemWidget("Tips", 100.w),
      _getTitleItemWidget("Travels", 100.w),
      _getTitleItemWidget(MyStrings.totalHours.tr, 100.w),
      _getTitleItemWidget(MyStrings.amount.tr, 120.w),
      _getTitleItemWidget(MyStrings.complain.tr, 150.w),
      _getTitleItemWidget(MyStrings.refund.tr, 150.w),
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
    return Container(
      width: 90.w,
      height: 71.h,
      color: Colors.white,
      child: _cell(
          width: 90.w,
          widget: Text(
            controller.dailyStatistics(index).date,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          )),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    CheckInCheckOutHistoryElement hiredHistory =
        controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index];

    UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(
        controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index]);
    final DateFormat timeFormat = DateFormat("HH:mm:ss");
    return Row(
      children: <Widget>[
        _cell(
            width: 150.w,
            widget: Text(
              controller.dailyStatistics(index).restaurantName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.dailyStatistics(index).employeeName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.dailyStatistics(index).position,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        // _cell(
        //     width: 100.w,
        //     widget: Text(
        //       controller.dailyStatistics(index).displayCheckInTime,
        //       maxLines: 2,
        //       overflow: TextOverflow.ellipsis,
        //       textAlign: TextAlign.center,
        //       style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
        //     )),
        // _cell(
        //     width: 100.w,
        //     widget: Text(
        //       controller.dailyStatistics(index).displayCheckOutTime,
        //       maxLines: 2,
        //       overflow: TextOverflow.ellipsis,
        //       textAlign: TextAlign.center,
        //       style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
        //     )),
        // _cell(
        //     width: 100.w,
        //     widget: Text(
        //       controller.dailyStatistics(index).displayBreakTime,
        //       maxLines: 2,
        //       overflow: TextOverflow.ellipsis,
        //       textAlign: TextAlign.center,
        //       style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
        //     )),
        hiredHistory.checkInCheckOutDetails?.clientCheckInTime == null
            ? _cell(
                width: 100.w,
                widget: Text(
                  dailyStatistics.employeeCheckInTime,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
                ),
              )
            : _cell(
                width: 100.w,
                // value: dailyStatistics.employeeCheckInTime,
                widget: Column(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: MyColors.l7B7B7B_dtext(controller.context!)
                          .semiBold13,
                    ),
                  ],
                ),
              ),

        hiredHistory.checkInCheckOutDetails!.clientCheckOutTime == null
            ? _cell(
                width: 100.w,
                // value: dailyStatistics.displayCheckOutTime,
                widget: Text(
                  dailyStatistics.employeeCheckOutTime,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
                ))
            : _cell(
                width: 100.w,
                // value: dailyStatistics.displayCheckOutTime,
                widget: Column(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: MyColors.l7B7B7B_dtext(controller.context!)
                          .semiBold13,
                    ),
                  ],
                ),
              ),
        hiredHistory.checkInCheckOutDetails!.clientBreakTime == null ||
                hiredHistory.checkInCheckOutDetails!.clientBreakTime == 0 ||
                hiredHistory.checkInCheckOutDetails!.clientBreakTime == '-'
            ? _cell(
                width: 100.w,
                // value: dailyStatistics.displayBreakTime == '-' ? '0' : '',
                widget: Text(
                  dailyStatistics.employeeBreakTime == '-' ? '0' : '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
                ))
            : _cell(
                width: 100.w,
                // value: dailyStatistics.displayBreakTime,
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Strike-through for the original check-in time
                    Text(
                      dailyStatistics.employeeBreakTime == '-' ? '0' : '',
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
                        hiredHistory.checkInCheckOutDetails!.clientBreakTime
                            .toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: MyColors.l7B7B7B_dtext(controller.context!)
                            .semiBold13,
                      ),
                  ],
                ),
              ),
        _cell(
            width: 100.w,
            // value: '${Utils.getCurrencySymbol()} ${hiredHistory.travelCost}',
            widget: Text(
              '${Utils.getCurrencySymbol()} ${hiredHistory.travelCost}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )), // Tips column
        _cell(
            width: 100.w,
            // value: '${Utils.getCurrencySymbol()} ${hiredHistory.tips}',
            widget: Text(
              '${Utils.getCurrencySymbol()} ${hiredHistory.tips}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )), // Tips column
        _cell(
            width: 100.w,
            widget: Text(
              // controller.dailyStatistics(index).workingHour,
              "${hiredHistory.workedHour}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 120.w,
            widget: Text(
              '${Utils.getCurrencySymbol()}${hiredHistory.totalAmount}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(width: 150.w, widget: _action(index)),
        _cell(width: 150.w, widget: _refundAction(index)),
      ],
    );
  }

  Widget _cell({required double width, required Widget widget}) => SizedBox(
        width: width,
        height: 71.h,
        child: Center(
          child: widget,
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
            controller.setUpdatedDate(index);
            showModalBottomSheet(
              constraints: BoxConstraints(maxWidth: Get.width),
              context: controller.context!,
              builder: (context) => Container(
                // padding: EdgeInsets.only(
                //   bottom: MediaQuery.of(context).viewInsets.bottom,
                // ),
                color: MyColors.lightCard(context),
                child: BottomA(_updateOption(index)),
              ),
            );
          },
          child: const Icon(
            Icons.info,
            color: Colors.deepOrange,
            size: 22,
          ),
        );

  Widget _refundAction(int index) => controller.getComment(index).isEmpty
      ? const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 22,
        )
      : GestureDetector(
          onTap: () {
            showModalBottomSheet(
              constraints: BoxConstraints(maxWidth: Get.width),
              context: controller.context!,
              builder: (context) => Container(
                // padding: EdgeInsets.only(
                //   bottom: MediaQuery.of(context).viewInsets.bottom,
                // ),
                color: MyColors.lightCard(context),
                child: BottomA(_refundOption(index)),
              ),
            );
          },
          child: const Icon(
            Icons.info,
            color: Colors.deepOrange,
            size: 22,
          ),
        );

  Widget _updateOption(int index) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                height: 4.h,
                width: 70.w,
                decoration: BoxDecoration(
                    color: MyColors.c_C6A34F,
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  flex: 8,
                  child: CustomDropdown(
                    prefixIcon: Icons.timelapse,
                    hints: null,
                    value: controller.selectedComplainType,
                    items: controller.complainType,
                    onChange: (String? value) {
                      controller.onComplainTypeChange(index, value);
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 48.h,
                    child: TextFormField(
                      readOnly: true,
                      controller: controller.tecTime,
                      keyboardType: TextInputType.number,
                      cursorColor: MyColors.c_C6A34F,
                      style: MyColors.l111111_dwhite(controller.context!)
                          .regular14,
                      decoration: MyDecoration.inputFieldDecoration(
                        context: controller.context!,
                        label: "",
                      ),
                      validator: (String? value) => Validators.emptyValidator(
                        value?.trim(),
                        MyStrings.required.tr,
                      ),
                    ),
                  ),
                ),
                Text(
                  "  ${MyStrings.min.tr}",
                  style: MyColors.l111111_dffffff(controller.context!).medium12,
                ),
                const SizedBox(width: 14),
              ],
            ),
            SizedBox(height: 30.h),
            TextFormField(
              controller: controller.tecComment,
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: null,
              readOnly: true,
              cursorColor: MyColors.c_C6A34F,
              style: MyColors.l111111_dwhite(controller.context!).regular14,
              decoration: MyDecoration.inputFieldDecoration(
                context: controller.context!,
                label: MyStrings.comments.tr,
              ),
            ),
            SizedBox(height: 30.h),
            CustomButtons.button(
              onTap: () => Get.back(),
              text: MyStrings.close.tr,
              margin: EdgeInsets.zero,
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            ),
          ],
        ),
      );

  Widget _refundOption(int index) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 4.h,
                  width: 70.w,
                  decoration: BoxDecoration(
                      color: MyColors.c_C6A34F,
                      borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
              SizedBox(height: 30.h),
              TextFormField(
                controller: controller.tecRemark,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: null,
                cursorColor: MyColors.c_C6A34F,
                style: MyColors.l111111_dwhite(controller.context!).regular14,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: MyStrings.remark.tr,
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: controller.tecRefundAmount,
                minLines: 1,
                maxLines: 1,
                readOnly: false,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))
                ],
                cursorColor: MyColors.c_C6A34F,
                style: MyColors.l111111_dwhite(controller.context!).regular14,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: MyStrings.refundAmount.tr,
                ),
              ),
              SizedBox(height: 30.h),
              CustomButtons.button(
                onTap: () => controller.submitRefundAmount(index: index),
                text: MyStrings.submit.tr,
                margin: EdgeInsets.zero,
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              ),
            ],
          ),
        ),
      );
}

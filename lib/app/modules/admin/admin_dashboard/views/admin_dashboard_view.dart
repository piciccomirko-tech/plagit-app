import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/client/client_dashboard/views/client_dashboard_view.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/no_item_found.dart';
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
            : Column(
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
                                  style: MyColors.l111111_dwhite(context).medium16,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Icon(
                                Icons.arrow_drop_down_circle,
                                size: 16,
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
                      visible: (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).isNotEmpty,
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
                            Expanded(child: _itemValue(MyStrings.client.tr, controller.uniqueClient.value.toString())),
                            _vDivider,
                            Expanded(
                                child: _itemValue(MyStrings.hours.tr,
                                    (controller.totalWorkingTimeInMinutes.value / 60).toStringAsFixed(1))),
                            _vDivider,
                            Expanded(
                                child: _itemValue(MyStrings.amount.tr,
                                    "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${controller.amount.value.toStringAsFixed(2)}")),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "${controller.history.length} ${MyStrings.employees.tr} ${MyStrings.active.tr}",
                          style: MyColors.c_C6A34F.semiBold16,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).isEmpty,
                      child: controller.historyLoading.value
                          ? const CircularProgressIndicator.adaptive(
                              backgroundColor: MyColors.c_C6A34F,
                            )
                          : const NoItemFound(),
                    ),
                  ),
                  Obx(
                    () => Visibility(
                      visible: (controller.checkInCheckOutHistory.value.checkInCheckOutHistory ?? []).isNotEmpty,
                      child: Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 90.w,
                          rightHandSideColumnWidth: 1270.w,
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
                    ),
                  ),
                ],
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
    );
    if (picked != null && picked != controller.dashboardDate.value) {
      controller.onDatePicked(picked);
    }
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 90.w),
      _getTitleItemWidget(MyStrings.restaurantName.tr, 150.w),
      _getTitleItemWidget(MyStrings.employeeName.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
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
        _cell(
            width: 100.w,
            widget: Text(
              controller.dailyStatistics(index).displayCheckInTime,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.dailyStatistics(index).displayCheckOutTime,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.dailyStatistics(index).displayBreakTime,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.dailyStatistics(index).workingHour,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 120.w,
            widget: Text(
              '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${controller.dailyStatistics(index).amount}',
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
                decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(30.0)),
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
                      style: MyColors.l111111_dwhite(controller.context!).regular14,
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
                  "  Min",
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
                  decoration: BoxDecoration(color: MyColors.c_C6A34F, borderRadius: BorderRadius.circular(30.0)),
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
                  label: "Remark",
                ),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: controller.tecRefundAmount,
                minLines: 1,
                maxLines: 1,
                readOnly: false,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))],
                cursorColor: MyColors.c_C6A34F,
                style: MyColors.l111111_dwhite(controller.context!).regular14,
                decoration: MyDecoration.inputFieldDecoration(
                  context: controller.context!,
                  label: "Refund Amount",
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

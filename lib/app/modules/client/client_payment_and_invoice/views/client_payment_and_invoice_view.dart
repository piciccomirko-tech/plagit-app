import 'package:flutter/cupertino.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/employee_details.dart';
import 'package:mh/app/modules/client/client_dashboard/views/client_dashboard_view.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/client_payment_and_invoice_controller.dart';

class ClientPaymentAndInvoiceView extends GetView<ClientPaymentAndInvoiceController> {
  const ClientPaymentAndInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.invoicePayment.tr,
        context: context,
      ),
      body: Obx(
        () => controller.clientHomeController.isLoading.value
            ? _loading
            : (controller.clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory ?? []).isEmpty
                ? Center(
                    child: Text(
                    MyStrings.noInvoiceFound.tr,
                    style: MyColors.l111111_dwhite(context).semiBold16,
                  ))
                : HorizontalDataTable(
                    leftHandSideColumnWidth: 100.w,
                    rightHandSideColumnWidth: 1350.w,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidget(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRow,
                    itemCount: (controller.clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory ?? [])
                        .length,
                    rowSeparatorWidget: Container(
                      height: 6.h,
                      color: MyColors.lFAFAFA_dframeBg(context),
                    ),
                    leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                    rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
                  ),
      ),
    );
  }

  Widget get _loading => const Center(
        child: CircularProgressIndicator.adaptive(
          backgroundColor: MyColors.c_C6A34F,
        ),
      );

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 100.w),
      _getTitleItemWidget('${MyStrings.employee.tr}\n${MyStrings.name.tr}', 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 100.w),
      _getTitleItemWidget(MyStrings.totalHour.tr, 100.w),
      _getTitleItemWidget(MyStrings.amount.tr, 100.w),
      _getTitleItemWidget('${MyStrings.vat.tr} (%)', 100.w),
      _getTitleItemWidget('${MyStrings.vat.tr}\n${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.platformFee.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr}\n${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.invoiceNo.tr, 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
      _getTitleItemWidget(MyStrings.complain.tr, 100.w),
      _getTitleItemWidget(MyStrings.refund.tr, 100.w),
      _getTitleItemWidget(MyStrings.viewInvoice.tr, 100.w),
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
    CheckInCheckOutHistoryElement invoice =
        (controller.clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory ?? [])[index];

    double height = 71.h;

    if (invoice.status != "PAID") {
      height = 100.h;
    }

    return SizedBox(
      width: 143.w,
      height: height,
      child: _cell(
        width: 143.w,
        height: height,
        value: '-',
        isPaid: invoice.status == "PAID",
        child: Row(
          children: [
            const Spacer(),
            Center(
              child: Text(
                invoice.hiredDate.toString().split(" ").first,
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(context).semiBold13,
              ),
            ),
            const Spacer(),
            Container(
              width: 4,
              height: 71.h,
              decoration: BoxDecoration(
                color: invoice.status == "PAID" ? MyColors.c_00C92C : MyColors.c_FF5029,
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell({
    required double width,
    required double height,
    required String value,
    required bool isPaid,
    String? clientUpdatedValue,
    Widget? child,
  }) =>
      Container(
        width: width,
        height: height,
        color: isPaid ? Colors.transparent : MyColors.c_FFEDEA,
        child: child ??
            Center(
              child: Text.rich(
                TextSpan(text: value, children: [
                  TextSpan(
                      text:
                          (clientUpdatedValue == null) || (clientUpdatedValue == value) ? "" : '\n$clientUpdatedValue',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      )),
                ]),
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
            ),
      );

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    CheckInCheckOutHistoryElement invoice =
        (controller.clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory ?? [])[index];

    double height = 71.h;

    if (invoice.status != "PAID") {
      height = 100.h;
    }

    return Row(
      children: <Widget>[
        _cell(
            width: 150.w, height: height, value: invoice.employeeDetails?.name ?? "", isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value: (invoice.employeeDetails?.positionName ?? "").toString(),
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value: invoice.workedHour!.contains(':')
                ? "${invoice.workedHour ?? '0.0'}h"
                : "${double.parse(invoice.workedHour ?? '0.0').toStringAsFixed(2)}h",
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value:
                '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(invoice.clientAmount ?? 0).toStringAsFixed(2)}',
            isPaid: invoice.status == "PAID"),
        _cell(width: 100.w, height: height, value: '${invoice.vat ?? "-"}%', isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value:
                '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(invoice.vatAmount ?? 0).toStringAsFixed(2)}',
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value:
                '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(invoice.platformFee ?? 0).toStringAsFixed(2)}',
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value:
                '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(invoice.totalAmount ?? 0).toStringAsFixed(2)}',
            isPaid: invoice.status == "PAID"),
        _cell(width: 100.w, height: height, value: invoice.invoiceNumber ?? "", isPaid: invoice.status == "PAID"),
        _cell(
          width: 100.w,
          height: height,
          value: "-",
          child: Center(
            child: Text(
              invoice.status ?? "-",
              style: invoice.status == "PAID" ? MyColors.c_00C92C.semiBold18 : MyColors.c_FF5029.semiBold18,
            ),
          ),
          isPaid: invoice.status == "PAID",
        ),
        _cell(
          width: 100.w,
          height: height,
          value: "-",
          child: _action(index: index, employeeDetails: invoice.employeeDetails!),
          isPaid: invoice.status == "PAID",
        ),
        _cell(
          width: 100.w,
          height: height,
          value: "-",
          child: _refundWidget(refund: invoice.remark ?? ""),
          isPaid: invoice.status == "PAID",
        ),
        _cell(
            width: 100.w,
            height: height,
            value: "-",
            isPaid: invoice.status == "PAID",
            child: Visibility(
                visible: invoice.status == "PAID",
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: InkWell(
                    onTap: () => controller.onViewInvoicePress(invoice: invoice),
                    child: const CircleAvatar(
                        radius: 10,
                        backgroundColor: MyColors.c_C6A34F,
                        child: Icon(Icons.remove_red_eye_outlined, color: MyColors.c_FFFFFF, size: 20)),
                  ),
                )))
      ],
    );
  }

  Widget _action({required int index, required EmployeeDetails employeeDetails}) => controller.getComment(index).isEmpty
      ? GestureDetector(
          onTap: () {
            if (controller.clientCommentEnable(index)) {
              // controller.setUpdatedDate(index);

              showModalBottomSheet(
                context: controller.context!,
                builder: (context) => Container(
                  // padding: EdgeInsets.only(
                  //   bottom: MediaQuery.of(context).viewInsets.bottom,
                  // ),
                  color: MyColors.lightCard(context),
                  child: BottomA(_updateOption(index: index, employeeDetails: employeeDetails)),
                ),
              );
            } else {
              CustomDialogue.information(
                context: controller.context!,
                title: MyStrings.report.tr,
                description: "${MyStrings.cantReport.tr}. \n\n ${MyStrings.haveToReport.tr}",
              );
            }
          },
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 22,
          ),
        )
      : GestureDetector(
          onTap: () {
            if (controller.clientCommentEnable(index)) {
              // controller.setUpdatedDate(index);

              showModalBottomSheet(
                context: controller.context!,
                builder: (context) => Container(
                  // padding: EdgeInsets.only(
                  //   bottom: MediaQuery.of(context).viewInsets.bottom,
                  // ),
                  color: MyColors.lightCard(context),
                  child: BottomA(_updateOption(index: index, employeeDetails: employeeDetails)),
                ),
              );
            } else {
              CustomDialogue.information(
                context: controller.context!,
                title: MyStrings.report.tr,
                description: controller.getComment(index),
              );
            }
          },
          child: const Icon(
            Icons.info,
            color: Colors.orange,
            size: 22,
          ),
        );

  Widget _updateOption({required int index, required EmployeeDetails employeeDetails}) => Form(
        key: controller.formKey,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomAppbarBackButton(),
                    Text("Any issue regarding this\n              employee?",
                        style: MyColors.l111111_dwhite(controller.context!).medium18),
                    const Wrap()
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70.w,
                      height: 74.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.grey.withOpacity(.1),
                      ),
                      child: CustomNetworkImage(
                        url: (employeeDetails.profilePicture ?? "").imageUrl,
                        fit: BoxFit.fill,
                        radius: 5,
                      ),
                    ),
                    SizedBox(width: 20.h),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(employeeDetails.name ?? "",
                            style: MyColors.l111111_dwhite(controller.context!).semiBold16),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(employeeDetails.positionName ?? "",
                                style: MyColors.l111111_dwhite(controller.context!).medium12),
                            Container(
                              margin: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30.0), color: MyColors.c_00C92C.withOpacity(0.1)),
                              child: Row(
                                children: [
                                  const SizedBox(width: 5),
                                  CircleAvatar(backgroundColor: MyColors.c_00C92C, radius: 5),
                                  Text(" ${MyStrings.active.tr} ",
                                      style: MyColors.l111111_dwhite(controller.context!).medium10)
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 30.h),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.green),
                          child: Center(
                              child: Text('${MyStrings.checkIn.tr} ${MyStrings.time.tr}',
                                  style: MyColors.white.semiBold16)),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(MyAssets.checkIn, height: 30, width: 30),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Center(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Obx(() => Text(
                                  '${controller.clientUpdateStatusModel.value.clientCheckInTime?.split(" ").last.substring(0, 8)}',
                                  style: MyColors.l111111_dwhite(controller.context!).semiBold16)),
                              InkWell(
                                  onTap: () => controller.onClockPressed(index: index, tag: 'checkIn'),
                                  child: Image.asset(MyAssets.clock, height: 20, width: 20))
                            ],
                          )),
                        ))
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.red),
                          child: Center(
                              child: Text('${MyStrings.checkOut.tr} ${MyStrings.time.tr}',
                                  style: MyColors.white.semiBold16)),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(MyAssets.checkOut, height: 30, width: 30),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(5.0)),
                            child: Obx(() => controller.clientUpdateStatusModel.value.clientCheckOutTime == null ||
                                    controller.clientUpdateStatusModel.value.clientCheckOutTime!.isEmpty
                                ? const Text('')
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                          "${controller.clientUpdateStatusModel.value.clientCheckOutTime?.split(" ").last.substring(0, 8)}",
                                          style: MyColors.l111111_dwhite(controller.context!).semiBold16),
                                      InkWell(
                                          onTap: () => controller.onClockPressed(index: index, tag: 'checkout'),
                                          child: Image.asset(MyAssets.clock, height: 20, width: 20))
                                    ],
                                  ))))
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: Colors.blueGrey),
                          child: Center(child: Text(MyStrings.breakTime.tr, style: MyColors.white.semiBold16)),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Image.asset(MyAssets.breakTime, height: 30, width: 30),
                    ),
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(5.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Obx(() => Text("${controller.clientUpdateStatusModel.value.clientBreakTime} minutes",
                                  style: MyColors.l111111_dwhite(controller.context!).semiBold16)),
                              InkWell(
                                  onTap: controller.onBreakTimePressed,
                                  child: Image.asset(MyAssets.clock, height: 20, width: 20))
                            ],
                          ),
                        ))
                  ],
                ),
                SizedBox(height: 30.h),
                TextFormField(
                  controller: controller.tecComment,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  cursorColor: MyColors.c_C6A34F,
                  style: MyColors.l111111_dwhite(controller.context!).regular14,
                  decoration: MyDecoration.inputFieldDecoration(
                    context: controller.context!,
                    label: MyStrings.comments.tr,
                  ),
                  validator: (String? value) => Validators.emptyValidator(
                    value?.trim(),
                    MyStrings.required.tr,
                  ),
                ),
                SizedBox(height: 30.h),
                CustomButtons.button(
                  height: 52.h,
                  onTap: () => controller.onUpdatePressed(index),
                  text: MyStrings.update.tr,
                  margin: EdgeInsets.zero,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      );

  Widget _refundWidget({required String refund}) {
    return refund.isEmpty
        ? const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 22,
          )
        : InkWell(
            onTap: () {
              Get.bottomSheet(Container(
                decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
                    color: MyColors.lightCard(controller.context!)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(MyStrings.refund.tr, style: MyColors.l111111_dwhite(controller.context!).semiBold20),
                      SizedBox(height: 30.h),
                      Text(refund, style: MyColors.l111111_dwhite(controller.context!).medium12),
                      SizedBox(height: 30.h),
                      CustomButtons.button(
                        height: 52.h,
                        onTap: () => Get.back(),
                        text: MyStrings.underStand.tr,
                        margin: EdgeInsets.zero,
                        customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                      ),
                      SizedBox(height: 10.h)
                    ],
                  ),
                ),
              ));
            },
            child: const Icon(
              Icons.info,
              color: Colors.orange,
              size: 22,
            ),
          );
  }
}

import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_invoice_model.dart';
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
            : (controller.clientHomeController.clientInvoice.value.invoices ?? []).isEmpty
                ? Center(
                    child: Text(
                    MyStrings.noInvoiceFound.tr,
                    style: MyColors.l111111_dwhite(context).semiBold16,
                  ))
                : HorizontalDataTable(
                    leftHandSideColumnWidth: 143.w,
                    rightHandSideColumnWidth: 1000.w,
                    isFixedHeader: true,
                    headerWidgets: _getTitleWidget(),
                    leftSideItemBuilder: _generateFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideColumnRow,
                    itemCount: (controller.clientHomeController.clientInvoice.value.invoices ?? []).length,
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
      _getTitleItemWidget(MyStrings.week.tr, 143.w),
      _getTitleItemWidget('${MyStrings.total.tr}\n${MyStrings.employee.tr}', 100.w),
      _getTitleItemWidget('${MyStrings.total.tr}\n${MyStrings.hours.tr}', 100.w),
      _getTitleItemWidget(MyStrings.amount.tr, 100.w),
      _getTitleItemWidget(MyStrings.vat.tr, 100.w),
      _getTitleItemWidget('${MyStrings.vat.tr}\n${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.platformFee.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr}\n${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.invoiceNo.tr, 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
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
    InvoiceModel invoice = controller.clientHomeController.clientInvoice.value.invoices![index];

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
                "${invoice.fromWeekDate.toString().split(" ").first}\n-\n${invoice.toWeekDate.toString().split(" ").first}",
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(context).semiBold13,
              ),
            ),
            /*Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "${invoice.fromWeekDate.toString().split(" ").first}\n-\n${invoice.toWeekDate.toString().split(" ").first}",
                    textAlign: TextAlign.center,
                    style: MyColors.l7B7B7B_dtext(context).semiBold13,
                  ),
                ),
                Visibility(
                  visible: invoice.status != "PAID",
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      CustomButtons.button(
                        text: MyStrings.pay.tr,
                        height: 25,
                        onTap: () => controller.onPayClick(index),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        margin: EdgeInsets.zero,
                        customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                      ),
                    ],
                  ),
                ),
              ],
            ),*/
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
    InvoiceModel invoice = controller.clientHomeController.clientInvoice.value.invoices![index];

    double height = 71.h;

    if (invoice.status != "PAID") {
      height = 100.h;
    }

    return Row(
      children: <Widget>[
        _cell(
            width: 100.w,
            height: height,
            value: (invoice.totalEmployee ?? 0).toString(),
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value: invoice.totalWorkingHour!.contains(':')
                ? "${invoice.totalWorkingHour ?? '0.0'}h"
                : "${double.parse(invoice.totalWorkingHour ?? '0.0').toStringAsFixed(2)}h",
            isPaid: invoice.status == "PAID"),
        _cell(
            width: 100.w,
            height: height,
            value:
                '${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(invoice.amount ?? 0).toStringAsFixed(2)}',
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
        _cell(width: 100.w, height: height, value: invoice.invoiceNumber ?? "-", isPaid: invoice.status == "PAID"),
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
}

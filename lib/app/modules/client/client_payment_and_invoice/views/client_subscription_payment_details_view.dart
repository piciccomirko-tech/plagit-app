import 'dart:convert';

import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/client_payment_and_invoice_controller.dart';
import '../model/client_subscription_invoice_details_response_model.dart';

class ClientSubscriptionPaymentDetailsView
    extends GetView<ClientPaymentAndInvoiceController> {
  const ClientSubscriptionPaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: CustomAppbar.appbar(
          title: '${MyStrings.subscription.tr} ${MyStrings.payments.tr}',
          context: context,
          visibleBack:  true,
          centerTitle: true),
      body: Obx(
            () =>controller.isLoadingSubscriptionInvoiceDetails.value
                  ? CustomLoader.loading()
                  : controller.clientSubscriptionsDetails.subscriptions==null || controller.clientSubscriptionsDetails.subscriptions!.isEmpty
                  ? Center(
                child: Text(
                  MyStrings.noInvoiceFound.tr,
                  style: MyColors.l111111_dwhite(context).semiBold16,
                ),
              )
                  : SizedBox(
                height:
                Get.height - 100, // Define a fixed height for the table
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollEndNotification &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      // controller
                      //     .loadMoreData(); // Load more data when scrolled to the bottom
                    }
                    return false;
                  },
                  child: HorizontalDataTable(
                    leftHandSideColumnWidth: 100.w,
                    rightHandSideColumnWidth: 1250.w,
                    isFixedHeader: true,
                    headerWidgets: _getSubscriptionTitleWidget(),
                    leftSideItemBuilder: _generateSubscriptionFirstColumnRow,
                    rightSideItemBuilder: _generateRightHandSideSubscriptionColumnRow,
                    itemCount: controller.clientSubscriptionsDetails.subscriptions!.length,
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
              ),),
    );
  }

  List<Widget> _getSubscriptionTitleWidget() {
    return [
      _getTitleItemWidget('Transaction ID', 150.w),
      _getTitleItemWidget('Order ID', 100.w),
      _getTitleItemWidget('Amount', 100.w),
      _getTitleItemWidget('Start Date', 100.w),
      _getTitleItemWidget('End Date', 100.w),
      _getTitleItemWidget('Payment Method', 100.w),
      _getTitleItemWidget('Status', 100.w),
      _getTitleItemWidget('Payment Date', 100.w),
      _getTitleItemWidget('Card Type', 100.w),
      _getTitleItemWidget('Cardholder Name', 150.w),
      _getTitleItemWidget('Subscription Active', 150.w),
      _getTitleItemWidget('Invoice', 150.w),
    ];
  }

  Widget _generateSubscriptionFirstColumnRow(BuildContext context, int index) {
    // Subscriptions subscriptions = (controller.clientSubscriptions.subscriptions![index]);

    double height = 71.h;

    // if (invoice.paymentStatus != "PAID") {
    //   height = 100.h;
    // }

    // DateTime parsedDate = DateTime.parse(subscriptions.createdAt ?? '');
    // String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    return SizedBox(
      width: 100.w,
      height: height,
      child: _cell(
        width: 100.w,
        height: height,
        value: '-',
        isPaid: true,
        child: Row(
          children: [
            const Spacer(),
            Center(
              child: Text(
                controller.clientSubscriptionsDetails.subscriptions![index].transactionId??'',
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(context).semiBold13,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _generateRightHandSideSubscriptionColumnRow(BuildContext context, int index) {
    if (index >= controller.clientSubscriptionsDetails.subscriptions!.length) {
      return SizedBox.shrink();
    }

    Subscriptions subscriptions = controller.clientSubscriptionsDetails.subscriptions![index];

    // String platformFee =
    //     (invoice.totalPlatformFee?.toStringAsFixed(2)) ?? '0.00';

    double height = 71.h;
    // if (invoice.paymentStatus != "PAID") {
    //   height = 100.h;
    // }
    DateTime sParsedDate = DateTime.parse(subscriptions.subscription?.createdAt ?? '');
    DateTime eParsedDate = DateTime.parse(subscriptions.subscription?.endDate ?? '');
    DateTime epaymentDate = DateTime.parse(subscriptions.paymentDate ?? '');
    String startDate = DateFormat('yyyy-MM-dd').format(sParsedDate);
    String endDate = DateFormat('yyyy-MM-dd').format(eParsedDate);
    String paymentDate = DateFormat('yyyy-MM-dd').format(epaymentDate);

    return Row(
      children: <Widget>[
        _cell(
          width: 100.w,
          height: height,
          value: subscriptions.orderId??'',
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: '\$${subscriptions.amount}',
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: startDate.toString(),
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: endDate.toString(),
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: subscriptions.paymentMethod.toString(),
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: subscriptions.status.toString(),
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: paymentDate,
          isPaid: true,
        ),
        _cell(
          width: 100.w,
          height: height,
          value: (jsonDecode(subscriptions.subscription!.sourceOfFund.toString()))['provided']['card']['brand']??'',
          isPaid: true,
        ),
        _cell(
          width: 150.w,
          height: height,
          value: (jsonDecode(subscriptions.subscription!.sourceOfFund.toString()))['provided']['card']['nameOnCard']??'',
          isPaid: true,
        ),
        _cell(
          width: 150.w,
          height: height,
          value: 'Yes',
          isPaid: true,
        ),
        _cell(
          width: 150.w,
          height: height,
          value: "-",
          isPaid: true,
          child: subscriptions.invoiceUrl != null && subscriptions.invoiceUrl !=""
              ? InkWell(
            onTap: () {
              controller.onDownloadPressed(subscriptions.invoiceUrl.toString());
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: MyColors.c_C6A34F,
                child: Icon(
                  Icons.download,
                  color: MyColors.c_FFFFFF,
                  size: 20,
                ),
              ),
            ),
          )
              : InkWell(
            onTap: () {
              Utils.showToast(message: 'Invoice is not yet available', bgColor: Colors.red);
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const CircleAvatar(
                radius: 5,
                backgroundColor: MyColors.lightGrey,
                child: Icon(
                  Icons.info_outline,
                  color: MyColors.c_FFFFFF,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
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
                      text: (clientUpdatedValue == null) ||
                              (clientUpdatedValue == value)
                          ? ""
                          : '\n$clientUpdatedValue',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      )),
                ]),
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(Get.context!).semiBold13,
              ),
            ),
      );
}

import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/domain/model/payment_model.dart';
import '../../../../../data/data_sources/payment_data_source.dart';
import '../../../../../data/data_sources_impl/payment_data_source_impl.dart';
import '../../../../../data/repositories_impl/payment_repository_impl.dart';
import '../../../../../domain/repositories/payment_repository.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_tab_widget.dart';
import '../../../../routes/app_pages.dart';
import '../../../employee/employee_home/models/home_tab_model.dart';
import '../controllers/client_payment_and_invoice_controller.dart';
import '../model/client_subscription_list_response_model.dart';
import 'client_subscription_payment_details_view.dart';

class ClientPaymentAndInvoiceView
    extends GetView<ClientPaymentAndInvoiceController> {
  const ClientPaymentAndInvoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    if(Get.isRegistered<ClientPaymentAndInvoiceController>()==true){

    }else {
      Get.lazyPut<ClientPaymentAndInvoiceController>(
        () => ClientPaymentAndInvoiceController(
          paymentRepository: Get.find(),
        ),
      );
      Get.lazyPut<PaymentDataSource>(
            () => PaymentDataSourceImpl(apiClient: Get.find()),
      );
      Get.lazyPut<PaymentRepository>(
            () => PaymentRepositoryImpl(
          paymentDataSource: Get.find(),
        ),
      );
    }
    // controller.context = Get.context!;

    return Scaffold(
      appBar: CustomAppbar.appbar(
          title: MyStrings.invoicePayment.tr,
          context: context,
          visibleBack: (Get.arguments ?? "").isEmpty ? false : true,
          centerTitle: true),
      body: Obx(
            () =>Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(horizontal: 15.0.w,vertical: 10.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              color: MyColors.lightCard(context),
              border: Border.all(color: MyColors.noColor, width: 0.2),
            ),
            child: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: controller.tabs
                  .asMap()
                  .entries
                  .map(
                    (MapEntry<int, HomeTabModel> entry) => CustomTabWidget(
                  context: context,
                  module: 'client',
                  model: entry.value,
                  index: entry.key,
                  onTap: () => controller.selectTab(entry.key),
                ),
              )
                  .toList(),
            )),
          ),
          controller.selectedTabIndex.value==0?
          Expanded(child:  controller.isLoading.value
                ? CustomLoader.loading()
                : controller.paymentList.isEmpty
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
                    controller
                        .loadMoreData(); // Load more data when scrolled to the bottom
                  }
                  return false;
                },
                child: HorizontalDataTable(
                  leftHandSideColumnWidth: 150.w,
                  rightHandSideColumnWidth: 550.w,
                  isFixedHeader: true,
                  headerWidgets: _getTitleWidget(),
                  leftSideItemBuilder: _generateFirstColumnRow,
                  rightSideItemBuilder: _generateRightHandSideColumnRow,
                  itemCount:
                  controller.paymentList.length, // Use paymentList
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
          ):
          Expanded(child:  controller.isLoadingSubscriptionInvoice.value
                ? CustomLoader.loading()
                : controller.clientSubscriptions.subscriptions==null || controller.clientSubscriptions.subscriptions!.isEmpty
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
                  rightHandSideColumnWidth: 700.w,
                  isFixedHeader: true,
                  headerWidgets: _getSubscriptionTitleWidget(),
                  leftSideItemBuilder: _generateSubscriptionFirstColumnRow,
                  rightSideItemBuilder: _generateRightHandSideSubscriptionColumnRow,
                  itemCount: controller.clientSubscriptions.subscriptions!.length,
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
      ),),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 150.w),
      _getTitleItemWidget(MyStrings.contractor.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 100.w),
      // _getTitleItemWidget(MyStrings.totalHour.tr, 100.w),
      // _getTitleItemWidget(MyStrings.amount.tr, 100.w),
      // _getTitleItemWidget('${MyStrings.vat.tr} (%)', 100.w),
      // _getTitleItemWidget('${MyStrings.vat.tr}\n${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.platformFee.tr, 100.w),
      // _getTitleItemWidget('TIPS', 100.w),
      // _getTitleItemWidget('TRAVEL', 100.w),
      // _getTitleItemWidget(
      //     '${MyStrings.total.tr}\n${MyStrings.amount.tr}', 100.w),
      // _getTitleItemWidget(MyStrings.invoiceNo.tr, 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
      // _getTitleItemWidget(MyStrings.complain.tr, 120.w),
      // _getTitleItemWidget(MyStrings.refund.tr, 120.w),
      _getTitleItemWidget(MyStrings.viewInvoice.tr, 100.w),
    ];
  }

  List<Widget> _getSubscriptionTitleWidget() {
    return [
      _getTitleItemWidget('Plan Name', 100.w),
      _getTitleItemWidget('Features', 150.w),
      _getTitleItemWidget('Monthly Charge', 100.w),
      _getTitleItemWidget('Start Date', 100.w),
      _getTitleItemWidget('End Date', 100.w),
      _getTitleItemWidget('Discount', 100.w),
      _getTitleItemWidget('Payment Details', 150.w),
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
                controller.clientSubscriptions.subscriptions![index].plan?.name??'',
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
    if (index >= controller.clientSubscriptions.subscriptions!.length) {
      return SizedBox.shrink();
    }

    Subscriptions subscriptions = controller.clientSubscriptions.subscriptions![index];

    // String platformFee =
    //     (invoice.totalPlatformFee?.toStringAsFixed(2)) ?? '0.00';

    double height = 71.h;
    // if (invoice.paymentStatus != "PAID") {
    //   height = 100.h;
    // }
    DateTime sParsedDate = DateTime.parse(subscriptions.createdAt ?? '');
    DateTime eParsedDate = DateTime.parse(subscriptions.endDate ?? '');
    String startDate = DateFormat('yyyy-MM-dd').format(sParsedDate);
    String endDate = DateFormat('yyyy-MM-dd').format(eParsedDate);

    return Row(
      children: <Widget>[
        _cell(
          width: 150.w,
          height: height,
          value: '-',
          isPaid: true,
          child: TextButton( onPressed: () {  showFeaturesPopup(Get.context!,subscriptions);}, child: Text(MyStrings.details.tr,style: MyColors.l7B7B7B_dtext(context)
                        .semiBold13,),)
          // child: Center(
          //   child: ListView.builder(
          //       itemCount: subscriptions.plan!.features!.length,
          //       scrollDirection: Axis.vertical,
          //       shrinkWrap: true,
          //       primary: false,
          //       padding: EdgeInsets.zero,
          //       physics: const NeverScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         String key = '${(subscriptions.plan!.features ?? [])[index].value==-1?'Unlimited':(subscriptions.plan!.features ?? [])[index].value} ${(subscriptions.plan!.features ?? [])[index].name}';
          //         return Padding(
          //           padding: const EdgeInsets.only(bottom: 5),
          //           child: Container(
          //             decoration:BoxDecoration( border: Border.all(
          //             width: .5,
          //             color: MyColors.c_A6A6A6,),
          //               borderRadius: BorderRadius.circular(20.25),
          //           ),
          //             child: Text(key,
          //                 textAlign: TextAlign.center,
          //                 style: MyColors.l7B7B7B_dtext(context)
          //                     .semiBold13),
          //           ),
          //         );
          //       }),
          // ),
        ),
        _cell(
          width: 100.w,
          height: height,
          value: '\$${subscriptions.monthlyCharge}',
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
          value: subscriptions.plan?.hasDiscount==true?'${subscriptions.plan?.discount?.toStringAsFixed(0)} ${subscriptions.plan?.discountType=='percent'?'%':''}':'No Discount',
          isPaid: true,
        ),
        _cell(
          width: 150.w,
          height: height,
          value: "-",
          isPaid: true,
          child:InkWell(
            onTap: () {
              controller.getSubscriptionPaymentDetails( id:subscriptions.id??'');
              Get.to(()=>ClientSubscriptionPaymentDetailsView());
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: const CircleAvatar(
                radius: 10,
                backgroundColor: MyColors.c_C6A34F,
                child: Icon(
                  Icons.remove_red_eye_outlined,
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

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    PaymentResult invoice = (controller.paymentList[index]);

    double height = 71.h;

    if (invoice.paymentStatus != "PAID") {
      height = 100.h;
    }

    DateTime parsedDate = DateTime.parse(invoice.createdAt ?? '');
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);

    return SizedBox(
      width: 150.w,
      height: height,
      child: _cell(
        width: 150.w,
        height: height,
        value: '-',
        isPaid: invoice.paymentStatus == "PAID",
        child: Row(
          children: [
            const Spacer(),
            Center(
              child: Text(
                formattedDate,
                textAlign: TextAlign.center,
                style: MyColors.l7B7B7B_dtext(context).semiBold13,
              ),
            ),
            const Spacer(),
            Container(
              width: 4,
              height: 71.h,
              decoration: BoxDecoration(
                color: invoice.paymentStatus == "PAID"
                    ? MyColors.c_00C92C
                    : MyColors.c_FF5029,
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

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    if (index >= controller.paymentList.length) {
      return SizedBox.shrink();
    }

    PaymentResult invoice = controller.paymentList[index];

    String platformFee =
        (invoice.totalPlatformFee?.toStringAsFixed(2)) ?? '0.00';

    double height = 71.h;
    if (invoice.paymentStatus != "PAID") {
      height = 100.h;
    }

    return Row(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Get.toNamed(Routes.employeeDetails, arguments: {
              'employeeId': invoice.employeeDetails?.employeeId ?? "",
              'isCandidate': true,
            });
          },
          child: _cell(
            width: 150.w,
            height: height,
            value: invoice.employeeDetails?.name ?? "",
            isPaid: invoice.paymentStatus == "PAID",
          ),
        ),
        _cell(
          width: 100.w,
          height: height,
          value: invoice.employeeDetails?.positionName ?? "",
          isPaid: invoice.paymentStatus == "PAID",
        ),
        _cell(
          width: 100.w,
          height: height,
          value: '${Utils.getCurrencySymbol()} $platformFee',
          isPaid: invoice.paymentStatus == "PAID",
        ),
        _cell(
          width: 100.w,
          height: height,
          value: "-",
          child: Center(
            child: Text(
              invoice.paymentStatus ?? '',
              style: invoice.paymentStatus == "PAID"
                  ? MyColors.c_00C92C.semiBold18
                  : MyColors.c_FF5029.semiBold18,
            ),
          ),
          isPaid: invoice.paymentStatus == "PAID",
        ),
        _cell(
          width: 100.w,
          height: height,
          value: "-",
          isPaid: invoice.paymentStatus == "PAID",
          child: invoice.invoiceUrl != ""
              ? InkWell(
                  onTap: () {
                    controller.onViewInvoicePress(invoice: invoice);
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
}
void showFeaturesPopup(BuildContext context, Subscriptions subscriptions) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.25),
        ),
        contentPadding: EdgeInsets.all(10),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Subscription Features",
                style: MyColors.l5C5C5C_dwhite(context)
                                    .semiBold19,
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 300, // Adjust height as needed
                child: ListView.builder(
                  itemCount: subscriptions.plan!.features!.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    String key = '${(subscriptions.plan!.features ?? [])[index].value == -1 ? 'Unlimited' : (subscriptions.plan!.features ?? [])[index].value} ${(subscriptions.plan!.features ?? [])[index].name}';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: .5,
                            color: MyColors.c_A6A6A6,
                          ),
                          borderRadius: BorderRadius.circular(20.25),
                        ),
                        child: Text(
                          key,
                          textAlign: TextAlign.center,
                          style: MyColors.l7B7B7B_dtext(context).semiBold13,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close",style: MyColors.l7B7B7B_dtext(context).semiBold18,),
          ),
        ],
      );
    },
  );
}


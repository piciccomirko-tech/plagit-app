import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/domain/model/check_in_check_out_history_model.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../controllers/client_dashboard_controller.dart';

class ClientDashboardHistoryView extends GetView<ClientDashboardController> {
  const ClientDashboardHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppbar.appbar(
        title: MyStrings.checkInCheckOutHistory.tr,
        context: context,
      ),
      body: Obx(
        () => controller.loadingCheckInCheckOutHistory.value
            ? ShimmerWidget.clientDashboardShimmerEffectWidget()
            : controller
                    .checkInCheckOutEditHistory.value.result!.result!.isEmpty
                ? NoItemFound()
                : Column(
                    children: [
                      Expanded(
                        child: HorizontalDataTable(
                          leftHandSideColumnWidth: 75.w,
                          rightHandSideColumnWidth: 800.w,
                          isFixedHeader: true,
                          headerWidgets: _getTitleWidget(),
                          leftSideItemBuilder: _generateFirstColumnRow,
                          rightSideItemBuilder: _generateRightHandSideColumnRow,
                          itemCount: controller.checkInCheckOutEditHistory.value
                              .result!.result!.length,
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


  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('#', 75.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
      _getTitleItemWidget(MyStrings.totalHour.tr, 100.w),
      _getTitleItemWidget("Total Amount", 100.w),
      _getTitleItemWidget(MyStrings.tips.tr, 100.w),
      _getTitleItemWidget("Travel Cost", 100.w),
      _getTitleItemWidget('${MyStrings.business.tr} ${MyStrings.comments.tr}', 100.w),
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
    return _cell(
      width: 75.w,
      child: Center(child: Text('${index + 1}')),
    );
  }

  Widget _cell({
    required double width,
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
    FinalResult hiredHistory =
        controller.checkInCheckOutEditHistory.value.result!.result![index];

    // UserDailyStatistics dailyStatistics = Utils.checkInOutToStatistics(
    //     controller.checkInCheckOutHistory.value.checkInCheckOutHistory![index]);
    final DateFormat timeFormat = DateFormat("hh:mm:ss a");
    return Row(
      children: <Widget>[
        hiredHistory.checkInCheckOutDetails!.clientCheckInTime != null
            ? _cell(
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                          .checkInCheckOutDetails!.clientCheckInTime
                          .toString())),
                      style:  MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                    ),
                  ],
                ),
              )
            : _cell(
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                          .checkInCheckOutDetails!.checkInTime
                          .toString())),
                      style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                    ),
                  ],
                ),
              ),
        hiredHistory.checkInCheckOutDetails!.clientCheckOutTime != null
            ? _cell(
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                          .checkInCheckOutDetails!.clientCheckOutTime
                          .toString())),
                      style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                    ),
                  ],
                ),
              )
            : _cell(
                width: 100.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timeFormat.format(DateTime.parse(hiredHistory
                          .checkInCheckOutDetails!.clientCheckOutTime
                          .toString())),
                      style:MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                    ),
                  ],
                ),
              ),
        hiredHistory.checkInCheckOutDetails!.clientBreakTime != null &&
                hiredHistory.checkInCheckOutDetails!.clientBreakTime != 0 && hiredHistory.checkInCheckOutDetails!.clientBreakTime != hiredHistory.checkInCheckOutDetails!.breakTime
            ? _cell(
                width: 100.w,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${hiredHistory.checkInCheckOutDetails!.clientBreakTime} min',
                  style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
                ),
              ],
            ),)
        :_cell(
                width: 100.w,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${hiredHistory.checkInCheckOutDetails!.breakTime} min',
                style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,
              ),
            ],
          ),),
        _cell(
            width: 100.w,
            clientUpdatedValue:
                controller.formatWorkedHours(hiredHistory.workedHour!)),
        _cell(
          width: 100.w,
          clientUpdatedValue:
              '${Utils.getCurrencySymbol()} ${(hiredHistory.totalAmount ?? 0).toStringAsFixed(2)}',
        ),
        _cell(
            width: 100.w,
            clientUpdatedValue:
                '${Utils.getCurrencySymbol()} ${hiredHistory.tips ?? 0.0}'),
        _cell(
            width: 100.w,
            clientUpdatedValue:
                '${Utils.getCurrencySymbol()} ${hiredHistory.travelCost ?? 0.0}'),
        _cell(
            width: 100.w,
            child: hiredHistory.checkInCheckOutDetails!.clientComment != null &&
                    hiredHistory
                        .checkInCheckOutDetails!.clientComment!.isNotEmpty
                ? Center(
                    child: Text(hiredHistory
                        .checkInCheckOutDetails!.clientComment
                        .toString(),style: MyColors.l7B7B7B_dtext(controller.context!).semiBold14,),
                  )
                : SizedBox()),
      ],
    );
  }
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

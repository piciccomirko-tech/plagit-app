import 'dart:developer';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/models/check_in_check_out_details.dart';

import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../controllers/employee_payment_history_controller.dart';

class EmployeePaymentHistoryView
    extends GetView<EmployeePaymentHistoryController> {
  const EmployeePaymentHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        visibleBack: false,
        centerTitle: true,
        title: MyStrings.paymentHistory.tr.replaceAll("\n", " "),
        context: context,
      ),
      body: Obx(() {
        if (controller.employeePaymentHistoryDataLoaded.value == false) {
          return Center(child: CustomLoader.loading());
        } else if (controller.employeePaymentHistoryDataLoaded.value == true &&
            controller.employeePaymentHistoryList.isEmpty) {
          return const NoItemFound();
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: HorizontalDataTable(
              leftHandSideColumnWidth: 150.w,
              rightHandSideColumnWidth: 1300.w,
              isFixedHeader: true,
              headerWidgets: _getTitleWidget(),
              leftSideItemBuilder: _generateFirstColumnRow,
              rightSideItemBuilder: _generateRightHandSideColumnRow,
              itemCount: controller.employeePaymentHistoryList.length,
              rowSeparatorWidget: Container(
                height: 6.h,
                color: MyColors.lFAFAFA_dframeBg(context),
              ),
              leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
              rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
            ),
          );
        }
      }),
    );
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 150.w),
      _getTitleItemWidget(MyStrings.contractor.tr, 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget(MyStrings.contractorPerHoursRate.tr, 100.w),
      _getTitleItemWidget(MyStrings.tips.tr, 100.w),
      _getTitleItemWidget(MyStrings.travel.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr} ${MyStrings.amount.tr}', 100.w),
      _getTitleItemWidget(MyStrings.checkIn.tr, 100.w),
      _getTitleItemWidget(MyStrings.checkOut.tr, 100.w),
      _getTitleItemWidget(MyStrings.breakTime.tr, 100.w),
      _getTitleItemWidget('${MyStrings.total.tr} ${MyStrings.hours.tr}', 100.w),
      _getTitleItemWidget(MyStrings.status.tr, 100.w),
      _getTitleItemWidget(MyStrings.comments.tr, 100.w),
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
          style: Get.width > 600
              ? MyColors.lffffff_dframeBg(controller.context!).semiBold10
              : MyColors.lffffff_dframeBg(controller.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      width: 150.w,
      height: 71.h,
      color: Colors.white,
      child: _cell(
          width: 90.w,
          widget: Text(
            controller.employeePaymentHistory(index).day,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Get.width > 600
                ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          )),
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    var totalAmount ='0';
    if(controller.employeePaymentHistoryList[index].workedHour=='00:00:00'){
      totalAmount ='0';
    }else {
      DateTime? finalCheckOut = controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime ?? controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime;
      DateTime? finalCheckIn = controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime ?? controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkInTime;
      int? finalBreakTime = controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime ?? controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.breakTime;
      double? hourlyRate = controller.employeePaymentHistoryList[index].employeeDetails?.contractorHourlyRate ?? 0.0;
      totalAmount = (((Utils.getDaysDifference(finalCheckIn!, finalCheckOut!) - (finalBreakTime!.toInt() * 60)) * (hourlyRate / 3600)) + (controller.employeePaymentHistoryList[index].tips?.toDouble() ??  0) + (controller.employeePaymentHistoryList[index].travelCost?.toDouble() ?? 0)).toStringAsFixed(2);
    }
    return Row(
      children: <Widget>[
        _cell(
            width: 150.w,
            widget: GestureDetector(
              onTap: () {
                // Create the ClientId object
                ClientId clientId = ClientId(
                  id: controller.employeePaymentHistoryList[index].hiredBy ??
                      '',
                  role: 'CLIENT',
                  email: controller.employeePaymentHistoryList[index]
                          .restaurantDetails?.email ??
                      '',
                  countryName: controller.employeePaymentHistoryList[index]
                          .restaurantDetails?.countryName ??
                      '',
                  restaurantName: controller.employeePaymentHistoryList[index]
                          .restaurantDetails?.restaurantName ??
                      '',
                  restaurantAddress: controller
                          .employeePaymentHistoryList[index]
                          .restaurantDetails
                          ?.restaurantAddress ??
                      '',
                  profilePicture: controller.employeePaymentHistoryList[index]
                          .restaurantDetails?.profilePicture?.imageUrl ??
                      '',
                  name: controller.employeePaymentHistoryList[index]
                          .restaurantDetails?.restaurantName ??
                      '',
                );
                log("profuile img url: ${controller.employeePaymentHistoryList[index].restaurantDetails?.profilePicture?.imageUrl ?? ''}");
                Get.toNamed(
                  Routes.individualSocialFeeds,
                  arguments: controller.clientIdToSocialUser(clientId
                      // }
                      ),
                );
              }, 

              // (){

              //                Get.toNamed(Routes.employeeDetails,
              //                   arguments: {'employeeId': controller.employeePaymentHistoryList[index].hiredBy ?? "",   'isCandidate':
              //                                     false });
              // },
              child: Text(
                controller.employeePaymentHistory(index).restaurantName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Get.width > 600
                    ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                    : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
              ),
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.employeePaymentHistory(index).position,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              '${Utils.getCurrencySymbol()}${controller.employeePaymentHistory(index).contractorPerHoursRate.toStringAsFixed(2)}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              '${Utils.getCurrencySymbol()}${controller.employeePaymentHistoryList[index].tips?.toStringAsFixed(2) ?? 0.0}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              '${Utils.getCurrencySymbol()}${controller.employeePaymentHistoryList[index].travelCost?.toStringAsFixed(2) ?? 0.0}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text('${Utils.getCurrencySymbol()}$totalAmount',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime.toString().substring(0,19) != controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkInTime.toString().substring(0,19)?
                Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkInTime??DateTime.now()),
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MyColors.primaryLight,
                    decorationThickness:
                    3.0, // Increase this value for a thicker line
                    color:MyColors.l7B7B7B_dtext(controller.context!), // Optional: makes it appear "disabled"
                  ),
                ):
                Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkInTime??DateTime.now()),
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: MyAssets.fontKlavika,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ),
                controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime.toString().substring(0,19) != controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkInTime.toString().substring(0,19)? Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckInTime??DateTime.now()),
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    fontFamily: MyAssets.fontKlavika,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ):SizedBox(),
              ],
            )),
        _cell(
            width: 100.w,
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text(controller.employeePaymentHistoryList[index].checkInCheckOutDetails!.checkOutTime!=null?controller.employeePaymentHistoryList[index].checkInCheckOutDetails!.checkOutTime.toString():'n'),

                (controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime!=null) &&
                    controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime.toString().substring(0,19) !=
                        controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime.toString().substring(0,19)?
                Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime??DateTime.now()),
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MyColors.primaryLight,
                    decorationThickness:
                    3.0, // Increase this value for a thicker line
                    color:MyColors.l7B7B7B_dtext(controller.context!), // Optional: makes it appear "disabled"
                  ),
                ):
                Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime??DateTime.now()),
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.none,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ),
                (controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime!=null) &&
                    controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime.toString().substring(0,19) !=
                        controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.checkOutTime.toString().substring(0,19)? Text(
                  Utils.getTime(controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientCheckOutTime??DateTime.now()),
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.none,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ):SizedBox(),
              ],
            )),
        _cell(
            width: 100.w,
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime != controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.breakTime?
                Text('${controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.breakTime} Min',
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: MyColors.primaryLight,
                    decorationThickness:
                    3.0, // Increase this value for a thicker line
                    color:MyColors.l7B7B7B_dtext(controller.context!), // Optional: makes it appear "disabled"
                  ),
                ):
                Text('${controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime} Min',
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.none,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ),
                controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime!=null && controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime != controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.breakTime? Text(
                  '${controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientBreakTime} Min',
                  style: TextStyle(
                    fontFamily: MyAssets.fontKlavika,
                    decoration: TextDecoration.none,
                    color: MyColors.l7B7B7B_dtext(controller.context!), // Regular color
                  ),
                ):SizedBox(),
              ],
            )),
        _cell(
            width: 100.w,
            widget: Text(
              controller.employeePaymentHistory(index).totalHours.contains(':')
                  ? '${controller.employeePaymentHistory(index).totalHours}h'
                  : '${double.parse(controller.employeePaymentHistory(index).totalHours).toStringAsFixed(2)}h',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            ),),
        _cell(
            width: 100.w,
            widget: Text(
              controller.employeePaymentHistoryList[index]
                          .employeePaymentStatus ==
                      true
                  ? 'PAID'
                  : 'DUE',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: MyAssets.fontKlavika,
                  color: controller.employeePaymentHistoryList[index]
                              .employeePaymentStatus ==
                          false
                      ? Colors.red
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: Get.width > 600 ? 16 : 12),
            ),),
        _cell(
            width: 100.w,
            widget: Text(
              controller.employeePaymentHistoryList[index].checkInCheckOutDetails?.clientComment??'',
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Get.width > 600
                  ? MyColors.l7B7B7B_dtext(controller.context!).semiBold9
                  : MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            ),),
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

  Widget _action(
          {required int index,
          required CheckInCheckOutDetails checkInCheckOutDetails}) =>
      controller.getComment(index).isEmpty
          ? const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 22,
            )
          : GestureDetector(
              onTap: () {
                CustomDialogue.information(
                  context: controller.context!,
                  title: MyStrings.restaurantReport.tr,
                  description:
                      "CheckIn Time: ${DateFormat('HH: mm: ss').format(checkInCheckOutDetails.clientCheckInTime!)}\nCheckOut Time: ${DateFormat('HH: mm: ss').format(checkInCheckOutDetails.clientCheckOutTime!)}\nBreak Time: ${checkInCheckOutDetails.clientBreakTime} min\nComment: ${checkInCheckOutDetails.clientComment}",
                );
              },
              child: const Icon(
                Icons.info,
                color: Colors.orange,
                size: 22,
              ),
            );
}

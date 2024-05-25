import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
import '../controllers/employee_booked_history_controller.dart';

class EmployeeBookedHistoryView extends GetView<EmployeeBookedHistoryController> {
  const EmployeeBookedHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(title: MyStrings.bookedHistory.tr.replaceAll("\n", " "), context: context),
      body: Obx(() {
        if (controller.employeeHomeController.bookingHistoryDataLoaded.value == false) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (controller.employeeHomeController.bookingHistoryDataLoaded.value == true &&
            controller.employeeHomeController.bookingHistoryList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 15.0.sp),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.employeeHomeController.bookingHistoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  BookingDetailsModel bookingDetails = controller.employeeHomeController.bookingHistoryList[index];
                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 15.0.sp),
                        height: 130,
                        width: double.infinity,
                        padding:  EdgeInsets.only(left: 15.sp, right: 15.sp, bottom: 30.sp),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(MyColors.black.withOpacity(0.7), BlendMode.darken),
                                image: const AssetImage(MyAssets.restaurant))),
                        child: Center(
                            child: Text(bookingDetails.text ?? '',
                                style: Get.width>600?MyColors.white.semiBold9:MyColors.white.semiBold15, overflow: TextOverflow.ellipsis, maxLines: 3)),
                      ),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButtons.button(
                            onTap: ()=>controller.onDetailsClick(notificationId: bookingDetails.id??""),
                            height: 35,
                            margin:  EdgeInsets.only(left: 250.sp),
                            text: MyStrings.details.tr,
                            fontSize: 12,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                      ))
                    ],
                  );
                }),
          );
        }
      }),
    );
  }
}

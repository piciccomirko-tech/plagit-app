import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import '../../employee_home/controllers/employee_home_controller.dart';
import '../controllers/employee_hired_history_controller.dart';

class EmployeeHiredHistoryView extends GetView<EmployeeHiredHistoryController> {
  const EmployeeHiredHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
        final EmployeeHomeController employeeHomeController = Get.find<EmployeeHomeController>();

    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(title: MyStrings.hiredHistory.tr.replaceAll("\n", " "), context: context),
      body: Obx(() {
        if (employeeHomeController.hiredHistoryDataLoaded.value == false) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (employeeHomeController.hiredHistoryDataLoaded.value == true &&
            employeeHomeController.hiredHistoryList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return Padding(
            padding:  EdgeInsets.symmetric(horizontal: 15.0.sp),
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: employeeHomeController.hiredHistoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  HiredHistoryModel data = employeeHomeController.hiredHistoryList[index];
                  return Stack(
                    children: [
                      Container(
                        margin:  EdgeInsets.only(top: 15.0.sp),
                        height: 120,
                        width: double.infinity,
                        padding:  EdgeInsets.only(left: 15.sp, right: 15.sp, bottom: 30.sp),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(MyColors.black.withOpacity(0.7), BlendMode.darken),
                                image: const AssetImage(MyAssets.restaurant))),
                        child: Center(
                            child: RichText(
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(children: [
                                  TextSpan(text: MyStrings.youHaveBeenBookedBy.tr, style: Get.width>600?MyColors.white.semiBold9:MyColors.white.semiBold12),
                                  TextSpan(
                                      text: '${data.restaurantDetails?.restaurantName}',
                                      style: Get.width>600?MyColors.white.semiBold12:MyColors.white.semiBold15),
                                  TextSpan(text: MyStrings.whichIsLocatedAt.tr, style: Get.width>600?MyColors.white.semiBold9:MyColors.white.semiBold12),
                                  TextSpan(
                                      text: '${data.restaurantDetails?.restaurantAddress}',
                                      style: Get.width>600?MyColors.white.semiBold12:MyColors.white.semiBold15),
                                ]))),
                      ),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButtons.button(
                            onTap: () => controller.onDetailsClick(bookedDateList: data.bookedDate ?? []),
                            height: 35,
                            margin:  EdgeInsets.only(left: Get.width>600?650:250),
                            text: MyStrings.details.tr,
                            fontSize: Get.width>600?15:12,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                      )),
                      Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: CustomButtons.button(
                                onTap: () => controller.onPrevDateClicked(hiredBy: data.hiredBy??''),
                                height: 35,
                                margin:  EdgeInsets.only(right:  Get.width>550?600:220),
                                text: MyStrings.previousDates.tr,
                                fontSize: Get.width>600?15:12,
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

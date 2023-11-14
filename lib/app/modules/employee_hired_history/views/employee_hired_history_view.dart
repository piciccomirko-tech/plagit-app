import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import '../controllers/employee_hired_history_controller.dart';

class EmployeeHiredHistoryView extends GetView<EmployeeHiredHistoryController> {
  const EmployeeHiredHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(title: 'Hired History', context: context),
      body: Obx(() {
        if (controller.employeeHomeController.hiredHistoryDataLoaded.value == false) {
          return const Center(child: CupertinoActivityIndicator());
        } else if (controller.employeeHomeController.hiredHistoryDataLoaded.value == true &&
            controller.employeeHomeController.hiredHistoryList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: controller.employeeHomeController.hiredHistoryList.length,
                itemBuilder: (BuildContext context, int index) {
                  HiredHistoryModel data = controller.employeeHomeController.hiredHistoryList[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 15.0),
                        height: MediaQuery.of(context).size.height * 0.13,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
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
                                  TextSpan(text: 'You have been booked by ', style: MyColors.white.semiBold12),
                                  TextSpan(
                                      text: '${data.restaurantDetails?.restaurantName}',
                                      style: MyColors.white.semiBold16),
                                  TextSpan(text: ' which is located at ', style: MyColors.white.semiBold12),
                                  TextSpan(
                                      text: '${data.restaurantDetails?.restaurantAddress}',
                                      style: MyColors.white.semiBold15),
                                ]))),
                      ),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButtons.button(
                            onTap: () => controller.onDetailsClick(bookedDateList: data.bookedDate ?? []),
                            height: 35,
                            margin: const EdgeInsets.only(left: 250),
                            text: 'Details',
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

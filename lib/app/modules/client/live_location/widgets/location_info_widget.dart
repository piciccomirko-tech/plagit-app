import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/live_location/controllers/live_location_controller.dart';

class LocationInfoWidget extends GetWidget<LiveLocationController> {
  const LocationInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: Get.width * 0.75,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0))),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Will arrive approximately within",
                    style: MyColors.l111111_dwhite(context).semiBold16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: MyColors.c_C6A34F),
                  child: Column(
                    children: [
                      Text("4", style: MyColors.white.semiBold20),
                      Text("min", style: MyColors.white.medium12),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Visibility(
                  visible: controller.locationData.value.employeePicture != null &&
                      (controller.locationData.value.employeePicture ?? "").isNotEmpty,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: MyColors.c_C6A34F,
                    child: CircleAvatar(
                      radius: 18.0,
                      backgroundImage: NetworkImage(controller.locationData.value.employeePicture ?? ""),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${controller.locationData.value.employeeName}",
                        style: MyColors.l111111_dwhite(context).semiBold12),
                    Text("3rd kemal ataturk avenue, Banani, Dhaka, Bangladesh",
                        style: MyColors.l111111_dwhite(context).medium11)
                  ],
                )
              ],
            ),
             Lottie.asset(MyAssets.lottie.directionLottie, height: 30, width: 35),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: MyColors.c_C6A34F,
                  child: CircleAvatar(
                    radius: 18.0,
                    backgroundImage: AssetImage(MyAssets.restaurant),
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(controller.appController.user.value.client?.restaurantName??"",
                        style: MyColors.l111111_dwhite(context).semiBold12),
                    Text(controller.appController.user.value.client?.restaurantAddress??"",
                        style: MyColors.l111111_dwhite(context).medium11)
                  ],
                )
              ],
            ),
            SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 35,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: TextField(
                      style: MyColors.l111111_dwhite(context).regular16_5,
                      autofocus: false,
                      cursorColor: MyColors.c_C6A34F,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15.0),
                        border: InputBorder.none,
                        filled: true,
                        hintStyle: MyColors.l111111_dwhite(context).medium12,
                        fillColor: Colors.grey.shade400,
                        hintText: "Want to Chat with ${controller.locationData.value.employeeName}?"
                      ),
                    ),
                  ),
                ),
              ),
              const Expanded(
                flex: 1,
                child: CircleAvatar(
                  backgroundColor: MyColors.c_C6A34F,
                  child: Icon(CupertinoIcons.phone_solid, color: Colors.white),
                ),
              )
            ],
          )
          ],
        ),
      ),
    );
  }
}

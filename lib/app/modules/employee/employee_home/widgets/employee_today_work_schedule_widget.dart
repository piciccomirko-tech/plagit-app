import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class EmployeeTodayWorkScheduleWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeTodayWorkScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayWorkScheduleDataLoading.value == true) {
        return Center(child: ShimmerWidget.employeeTodayWorkScheduleShimmerWidget());
      } else if (controller.todayWorkScheduleDataLoading.value == false &&
          controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel == null) {
        return const Wrap();
      } else {
        RestaurantDetails? restaurantDetails =
            controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails;
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 15.0.w),
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Get.theme.dividerColor.withOpacity(0.05),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              color: Colors.blue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10.0)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.location_solid, color: MyColors.white),
                  Text(restaurantDetails?.restaurantName ?? '',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: MyColors.white.semiBold16)
                ],
              ),
              Text(
                restaurantDetails?.restaurantAddress ?? '',
                style: MyColors.white.medium15,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 20.h),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        flex: 2,
                        child: RichText(
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(children: [
                              TextSpan(
                                text: controller.locationFetchError.value.isEmpty
                                    ? (controller.restaurantDistanceFromEmployee(
                                                targetLat: double.parse(restaurantDetails!.lat.toString()),
                                                targetLng: double.parse(restaurantDetails.long.toString())) /
                                            1609)
                                        .toStringAsFixed(2)
                                    : 'xxx',
                                style: MyColors.white.semiBold26,
                              ),
                              TextSpan(
                                text: ' miles away',
                                style: MyColors.white.medium12,
                              ),
                            ]))),
                    const VerticalDivider(color: Colors.transparent, thickness: 2),
                    Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Column(
                              children: [
                                const CircleAvatar(radius: 5, backgroundColor: MyColors.white),
                                Container(width: 5, height: 40, color: MyColors.white),
                                const CircleAvatar(radius: 5, backgroundColor: MyColors.white)
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    ' ${controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.startTime ?? ''}',
                                    style: MyColors.white.medium15),
                                const SizedBox(height: 18),
                                Text(
                                    ' ${controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.endTime ?? ''}',
                                    style: MyColors.white.medium15),
                              ],
                            )
                          ],
                        )),
                    const VerticalDivider(color: Colors.transparent, thickness: 2),
                    Expanded(
                        flex: 1,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text:
                                    '${(controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.startTime)?.hoursDifference(controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.endTime ?? '')}',
                                style: MyColors.white.semiBold26),
                            TextSpan(text: ' Hours', style: MyColors.white.medium12)
                          ]),
                        ))
                  ],
                ),
              )
            ],
          ),
        );
      }
    });
  }
}

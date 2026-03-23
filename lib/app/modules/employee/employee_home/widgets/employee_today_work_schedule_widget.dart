import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/helpers/responsive_helper.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/today_check_in_out_details.dart';

class EmployeeTodayWorkScheduleWidget
    extends GetWidget<EmployeeHomeController> {
  const EmployeeTodayWorkScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.todayWorkScheduleDataLoading.value == true) {
        return Center(
            child: ShimmerWidget.employeeTodayWorkScheduleShimmerWidget());
      } else if (controller.todayWorkScheduleDataLoading.value == false &&
          controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel ==
              null) {
        return const Wrap();
      } else {
        RestaurantDetails? restaurantDetails = controller.todayWorkSchedule
            .value.todayWorkScheduleDetailsModel?.restaurantDetails;
        return Container(
          width: Get.width,
          margin: EdgeInsets.only(top: 13.w),
          padding: EdgeInsets.symmetric(vertical: 20.0.w, horizontal: 15.0.w),
          decoration: BoxDecoration(
              color: MyColors.lightCard(context),
              border: Border.all(width: 0.5, color: MyColors.noColor),
              borderRadius: BorderRadius.circular(15.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 4.w),
                  Image.asset(MyAssets.restaurant1, height: ResponsiveHelper.isTab(context)?10.w:15.w, width: ResponsiveHelper.isTab(context)?10.w:15.w),
                  Text("  ${restaurantDetails?.restaurantName ?? ''}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).semiBold9:MyColors.l111111_dwhite(context).semiBold12)
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 4.w),
                  Expanded(
                      flex: 1,
                      child:
                          Image.asset(MyAssets.marker, height: ResponsiveHelper.isTab(context)?10.w:15, width: ResponsiveHelper.isTab(context)?10.w:15)),
                  Expanded(
                    flex: 15,
                    child: Text(
                        "  ${restaurantDetails?.restaurantAddress ?? ''}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium12),
                  ),
                  SizedBox(width: 10.w),
                  const CircleAvatar(
                    backgroundColor: MyColors.lightGrey,
                    radius: 2,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    flex: 4,
                    child: RichText(
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: controller.locationFetchError.value.isEmpty
                                ? (() {
                              double distanceInMeters = controller.restaurantDistanceFromEmployee(
                                targetLat: double.parse(restaurantDetails!.lat.toString()),
                                targetLng: double.parse(restaurantDetails.long.toString()),
                              );
                              if (distanceInMeters <= 200) {
                                return '${distanceInMeters.toStringAsFixed(0)} ${MyStrings.metersAway.tr}';
                              } else {
                                double distanceInMiles = distanceInMeters / 1609.34;
                                return '${distanceInMiles.toStringAsFixed(2)} ${MyStrings.milesAway.tr}';
                              }
                            })()
                                : 'xxx',
                            style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).semiBold9:MyColors.l111111_dwhite(context).semiBold14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 4.w),
                      Image.asset(MyAssets.clock, height: ResponsiveHelper.isTab(context)?10.w:15.w, width: ResponsiveHelper.isTab(context)?10.w:15.w),
                      Text(
                          '  ${controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.startTime ?? ''} -',
                          style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium12),
                      Text(
                          ' ${controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.endTime ?? ''} ',
                          style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium12),
                    ],
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    backgroundColor: MyColors.lightGrey,
                    radius: 1.5,
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text:
                              ' ${(controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.startTime)?.hoursDifference(controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel?.endTime ?? '')}',
                          style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).semiBold9:MyColors.l111111_dwhite(context).semiBold14),
                      TextSpan(
                          text: ' ${MyStrings.hours.tr}',
                          style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium12)
                    ]),
                  )
                ],
              )
            ],
          ),
        );
      }
    });
  }
}

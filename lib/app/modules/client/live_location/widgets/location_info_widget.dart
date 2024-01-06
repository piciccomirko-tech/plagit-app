import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/live_location/controllers/live_location_controller.dart';
import 'package:mh/app/modules/client/live_location/widgets/travel_mode.dart';

class LocationInfoWidget extends GetWidget<LiveLocationController> {
  const LocationInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      height: 300,
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0), topLeft: Radius.circular(10.0))),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TravelMode(),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(MyAssets.distance, height: 20, width: 20),
                        SizedBox(width: 5.w),
                        Obx(() => Text("${controller.socketLocationModel.value.distance ?? ""} miles away",
                            style: MyColors.l111111_dwhite(context).semiBold16)),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text("Will arrive approximately within", style: MyColors.l111111_dwhite(context).medium13),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: MyColors.c_C6A34F),
                  child: Column(
                    children: [
                      Obx(() => Text(
                          controller.socketLocationModel.value.totalEta == null
                              ? ""
                              : "${controller.socketLocationModel.value.totalEta}",
                          style: MyColors.white.semiBold20)),
                      Text("min", style: MyColors.white.medium12),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Visibility(
                      visible: (controller.employeeInfo.employeeDetails?.profilePicture ?? "").isNotEmpty,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: MyColors.c_C6A34F,
                        child: CircleAvatar(
                          radius: 18.0,
                          backgroundImage: NetworkImage((controller.employeeInfo.employeeDetails?.profilePicture ?? "").imageUrl),
                        ),
                      ),
                    )),
                SizedBox(width: 10.w),
                Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.employeeInfo.employeeDetails?.name ?? "",
                            style: MyColors.l111111_dwhite(context).semiBold12),
                        Obx(() => Text(controller.socketLocationModel.value.currentPosition ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MyColors.l111111_dwhite(context).medium11)),
                      ],
                    )),
                Expanded(
                    flex: 1,
                    child: InkWell(
                      onTap: controller.onLiveChatPressed,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blueGrey.shade50,
                        child: const Icon(Icons.chat, color: MyColors.c_C6A34F, size: 20),
                      ),
                    ))
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
                    Text(controller.appController.user.value.client?.restaurantName ?? "",
                        style: MyColors.l111111_dwhite(context).semiBold12),
                    Text(controller.appController.user.value.client?.restaurantAddress ?? "",
                        style: MyColors.l111111_dwhite(context).medium11)
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

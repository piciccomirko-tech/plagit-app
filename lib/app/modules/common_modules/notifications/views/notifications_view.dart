import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/common_modules/notifications/widgets/notification_widget.dart';
import '../../../../helpers/responsive_helper.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(NotificationsController());
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.notifications.tr,
        context: context,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notificationDataLoaded.value == false) {
          return ShimmerWidget.clientMyEmployeesShimmerWidget(height: 120.w);
        } else if (controller.notificationDataLoaded.value == true && controller.notificationList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: ResponsiveHelper.isTab(Get.context)?30.w:50.w,
                    child: CustomButtons.button(
                      onTap: controller.readAll,
                      customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                      margin: EdgeInsets.only(top: 10.0.w, right: 10.w),
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
                      text: "Read All",
                      fontSize: 15
                    ),
                  )
                ],
              ),
              Expanded(child: RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: Scrollbar(
                  controller: controller.scrollController, // Attach the ScrollController
                  thumbVisibility: true, // Makes the scrollbar always visible
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    controller: controller.scrollController,
                    itemCount: controller.notificationList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == controller.notificationList.length - 1 &&
                          controller.isMoreDataAvailable.value == true &&
                          controller.notificationList.length > 19) {
                        return const Center(child: CupertinoActivityIndicator());
                      }
                      BookingDetailsModel notification = controller.notificationList[index];
                      return NotificationWidget(
                        notification: notification,
                      );
                    },
                  ),
                ),
              ))
            ],
          );
        }
      }),
    );
  }
}

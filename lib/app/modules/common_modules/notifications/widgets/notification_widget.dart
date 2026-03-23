import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';

import '../../../../helpers/responsive_helper.dart';

class NotificationWidget extends StatelessWidget {
  final BookingDetailsModel notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.find<NotificationsController>()
          .updateNotification(notification: notification, readStatus: true),
      child: Container(
        margin: EdgeInsets.only(top: 15.0.w),
        padding: EdgeInsets.symmetric(horizontal: 15.0.w),
        decoration: BoxDecoration(
            color: notification.readStatus == true
                ? MyColors.noColor
                : MyColors.primaryLight.withOpacity(0.2)),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('${notification.text}',
              style: Get.width > 600
                  ? MyColors.l111111_dwhite(context).semiBold9
                  : MyColors.l111111_dwhite(context).semiBold17),
          leading: CircleAvatar(
            radius: Get.width > 600 ? 22 : 18,
            backgroundColor: MyColors.c_C6A34F,
            backgroundImage: AssetImage(MyAssets.adminDefault),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 5.w),
            child: Text(
                '${DateFormat.yMMMMd().format(notification.createdAt!)}, ${DateFormat.jm().format(notification.createdAt!)}',
                style: TextStyle(
                    fontSize: Get.width > 600 ? 7.sp : 14,
                    fontStyle: FontStyle.italic,
                    color: MyColors.l111111_dwhite(context))),
          ),
          trailing: GestureDetector(
              onTap: () => Get.find<NotificationsController>()
                  .deleteNotification(notificationId: notification.id ?? ""),
              child: Image.asset(MyAssets.delete, width: ResponsiveHelper.isTab(Get.context)?15.w:25.w, height: ResponsiveHelper.isTab(Get.context)?15.w:25.w)),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';

class NotificationWidget extends StatelessWidget {
  final BookingDetailsModel notification;
  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.find<NotificationsController>().updateNotification(id: notification.id ?? '', readStatus: true);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: ListTile(
          title: Text(
            '${notification.text}',
            style: TextStyle(
                fontWeight: notification.readStatus == false ? FontWeight.bold : FontWeight.normal,
                color: notification.readStatus == true ? MyColors.c_7B7B7B : MyColors.l111111_dwhite(context),
                fontSize: 14),
          ),
          leading: const CircleAvatar(
            radius: 15,
            backgroundColor: MyColors.c_C6A34F,
            child: Icon(CupertinoIcons.bell, color: MyColors.c_FFFFFF, size: 18),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
                '${DateFormat.yMMMMd().format(notification.createdAt!)}, ${DateFormat.jm().format(notification.createdAt!)}',
                style: TextStyle(fontStyle: FontStyle.italic, color: MyColors.l111111_dwhite(context))),
          ),
        ),
      ),
    );
  }
}

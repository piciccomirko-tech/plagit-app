import 'dart:convert';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';
import '../../routes/app_pages.dart';
import '../utils/exports.dart';

class NotificationClickHelper {
  static void goToRoute(String? payload) {
    if (payload != null) {
      Map<String, dynamic> data = jsonDecode(payload);

      if (data["click_action"] == MyStrings.payloadScreen.clientEmployeeChat) {
        Get.toNamed(Routes.clientEmployeeChat, arguments: {
          MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
          MyStrings.arg.fromId: data[MyStrings.arg.fromId],
          MyStrings.arg.toId: data[MyStrings.arg.toId],
          MyStrings.arg.clientId: data[MyStrings.arg.clientId],
          MyStrings.arg.employeeId: data[MyStrings.arg.employeeId],
        });
      } else if (data["click_action"] == MyStrings.payloadScreen.supportChat) {
        Get.toNamed(Routes.supportChat, arguments: {
          MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
          MyStrings.arg.fromId: data[MyStrings.arg.fromId],
          MyStrings.arg.toId: data[MyStrings.arg.toId],
          MyStrings.arg.supportChatDocId: data[MyStrings.arg.supportChatDocId],
        });
      } else {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        if (Get.isRegistered<EmployeeHomeController>()) {
          Get.find<EmployeeHomeController>().homeMethods();
        } else if (Get.isRegistered<AdminHomeController>()) {
          Get.find<AdminHomeController>().homeMethods();
        } else if (Get.isRegistered<ClientHomeController>()) {
          Get.find<ClientHomeController>().homeMethods();
        }
      }
    } else {
      Get.delete<NotificationsController>();
      Get.toNamed(Routes.notifications);
      if (Get.isRegistered<EmployeeHomeController>()) {
        Get.find<EmployeeHomeController>().homeMethods();
      } else if (Get.isRegistered<AdminHomeController>()) {
        Get.find<AdminHomeController>().homeMethods();
      } else if (Get.isRegistered<ClientHomeController>()) {
        Get.find<ClientHomeController>().homeMethods();
      }
    }
  }
}

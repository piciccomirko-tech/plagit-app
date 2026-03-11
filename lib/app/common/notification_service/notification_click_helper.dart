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

      final String clickAction = data["click_action"] ?? "";

      // Navigate to client-employee chat
      //if (clickAction == MyStrings.payloadScreen.clientEmployeeChat) {
        //Get.delete<NotificationsController>();
        //Get.toNamed(
          //Routes.clientEmployeeChat,
          //arguments: {
            //MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
            //MyStrings.arg.fromId: data[MyStrings.arg.fromId],
            //MyStrings.arg.toId: data[MyStrings.arg.toId],
            //MyStrings.arg.clientId: data[MyStrings.arg.clientId],
            //MyStrings.arg.employeeId: data[MyStrings.arg.employeeId],
          //},
        //);

      // Navigate to support chat
      // } else if (clickAction == MyStrings.payloadScreen.supportChat) {
        //Get.delete<NotificationsController>();
        //Get.toNamed(
          //Routes.supportChat,
          //arguments: {
            //MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
            //MyStrings.arg.fromId: data[MyStrings.arg.fromId],
            //MyStrings.arg.toId: data[MyStrings.arg.toId],
            //MyStrings.arg.supportChatDocId: data[MyStrings.arg.supportChatDocId],
          //},
        //);

      // Navigate to booking requests (for employees - new job offer)
      if (clickAction == "booking_request") {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        if (Get.isRegistered<EmployeeHomeController>()) {
          Get.find<EmployeeHomeController>().homeMethods();
        }

      // Navigate to booking confirmation (for clients)
      } else if (clickAction == "booking_confirmed") {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        if (Get.isRegistered<ClientHomeController>()) {
          Get.find<ClientHomeController>().getMessages();
        }

      // Navigate to payment notification
      } else if (clickAction == "payment_received") {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        if (Get.isRegistered<EmployeeHomeController>()) {
          Get.find<EmployeeHomeController>().homeMethods();
        }

      // Navigate to shift reminder
      } else if (clickAction == "shift_reminder") {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        _refreshHomeForAllUserTypes();

      // Default: go to notifications screen
      } else {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        _refreshHomeForAllUserTypes();
      }
    }
  }

  // Helper to refresh home screen for whichever user type is logged in
  static void _refreshHomeForAllUserTypes() {
    if (Get.isRegistered<EmployeeHomeController>()) {
      Get.find<EmployeeHomeController>().homeMethods();
    } else if (Get.isRegistered<AdminHomeController>()) {
      Get.find<AdminHomeController>().homeMethods();
    } else if (Get.isRegistered<ClientHomeController>()) {
      Get.find<ClientHomeController>().getMessages();
    }
  }
}

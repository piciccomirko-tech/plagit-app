import 'dart:convert';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import '../../modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import '../../modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import '../../modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import '../../modules/common_modules/social_post_details/controllers/social_post_details_controller.dart';
import '../../modules/employee/employee_root/controllers/employee_root_controller.dart';
import '../../routes/app_pages.dart';
import '../utils/exports.dart';

class NotificationClickHelper {
  static void goToRoute(String? payload) {
    if (payload != null) {
      Map<String, dynamic> data = jsonDecode(payload);

      if (data["click_action"] == MyStrings.payloadScreen.clientCandidateChat) {
        /* Get.toNamed(Routes.clientEmployeeChat, arguments: {
          MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
          MyStrings.arg.fromId: data[MyStrings.arg.fromId],
          MyStrings.arg.toId: data[MyStrings.arg.toId],
          MyStrings.arg.clientId: data[MyStrings.arg.clientId],
          MyStrings.arg.employeeId: data[MyStrings.arg.employeeId],
        });*/
      } else if (data["click_action"] == MyStrings.payloadScreen.supportChat) {
        /* Get.toNamed(Routes.supportChat, arguments: {
          MyStrings.arg.receiverName: data[MyStrings.arg.receiverName],
          MyStrings.arg.fromId: data[MyStrings.arg.fromId],
          MyStrings.arg.toId: data[MyStrings.arg.toId],
          MyStrings.arg.supportChatDocId: data[MyStrings.arg.supportChatDocId],
        });*/
      } else {
        Get.delete<NotificationsController>();
        Get.toNamed(Routes.notifications);
        if (Get.isRegistered<EmployeeHomeController>()) {
          Get.find<EmployeeHomeController>().homeMethods();
        } else if (Get.isRegistered<AdminHomeController>()) {
          Get.find<AdminHomeController>().getMessages();
        } else if (Get.isRegistered<ClientHomeController>()) {
          Get.find<ClientHomeController>().getMessages();
        }
      }
    } else {
      Get.delete<NotificationsController>();
      Get.toNamed(Routes.notifications);
      if (Get.isRegistered<EmployeeHomeController>()) {
        Get.find<EmployeeHomeController>().homeMethods();
      } else if (Get.isRegistered<AdminHomeController>()) {
        Get.find<AdminHomeController>().getMessages();
      } else if (Get.isRegistered<ClientHomeController>()) {
        Get.find<ClientHomeController>().getMessages();
      }
    }
  }

  static void goToNewRoute(String? payload) async {
    if (payload != null) {
      Map<String, dynamic> data = jsonDecode(payload);
      if (data["type"] == "background_service_payload") {
        if (Get.isRegistered<EmployeeHomeController>()) {
          if (Get.currentRoute == Routes.clientPremiumRoot) {
            Get.find<EmployeeRootController>().selectedIndex.value = 0;
            Get.find<EmployeeHomeController>().selectTab(1);
            Get.find<EmployeeHomeController>()
                .commonSocialFeedController
                .getSocialPost();
          } else {
            Get.offAllNamed(Routes.employeeRoot);
            await Future.delayed(const Duration(seconds: 1));
            Get.find<EmployeeHomeController>().selectTab(1);
          }
        } else if (Get.isRegistered<AdminHomeController>()) {
          Get.find<AdminHomeController>().getMessages();
        } else if (Get.isRegistered<ClientHomeController>()) {
          if (Get.currentRoute == Routes.clientPremiumRoot) {
            Get.find<ClientPremiumRootController>().selectedIndex.value = 0;
            Get.find<ClientHomePremiumController>().selectTab(1);
            Get.find<ClientHomePremiumController>()
                .commonSocialFeedController
                .getSocialPost();
          } else {
            Get.offAllNamed(Routes.clientPremiumRoot);
            await Future.delayed(const Duration(seconds: 1));
            Get.find<ClientHomePremiumController>().selectTab(1);
          }
        }
      } else if (data["type"] == "social-post") {
        try {
          Get.toNamed(Routes.socialPostDetails, arguments: data["id"]);
          Get.put<SocialPostDetailsController>(SocialPostDetailsController())
              .getSocialPostInfoByPostId(data["id"]);
        } catch (e) {
          debugPrint('Message redirection error');
          debugPrint(e.toString());
        }
      } else {
        Map<String, dynamic> data = jsonDecode(payload);

        if (data["conversationId"] != null) {
          try {
            // if (Get.isRegistered<EmployeeHomeController>()) {
            //   Get.toNamed(Routes.employeeRoot);
            // } else if (Get.isRegistered<AdminHomeController>()) {
            //   Get.toNamed(Routes.adminRoot);
            // } else if (Get.isRegistered<ClientHomeController>()) {
            //   Get.toNamed(Routes.clientPremiumRoot);
            // }
            Get.toNamed(Routes.liveChat,
                arguments: LiveChatDataTransferModel(
                    id: data["conversationId"],
                    role: data["senderRole"] ?? "",
                    toName: data["senderRole"] != 'SUPER_ADMIN' &&
                            data["senderRole"] != 'ADMIN'
                        ? data["senderName"]
                        : "Support",
                    toId: data["senderId"] ?? "",
                    toProfilePicture:
                        "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
          } catch (e) {
            debugPrint('Message redirection error');
            debugPrint(e.toString());
          }
        }
        // else if (data["click_action"] == MyStrings.payloadScreen.supportChat) {
        // }
        else {
          Get.delete<NotificationsController>();
          Get.toNamed(Routes.notifications);
          if (Get.isRegistered<EmployeeHomeController>()) {
            Get.find<EmployeeHomeController>().homeMethods();
          } else if (Get.isRegistered<AdminHomeController>()) {
            Get.find<AdminHomeController>().getMessages();
          } else if (Get.isRegistered<ClientHomeController>()) {
            Get.find<ClientHomeController>().getMessages();
          }
        }
      }
    } else {
      Get.delete<NotificationsController>();
      Get.toNamed(Routes.notifications);
      if (Get.isRegistered<EmployeeHomeController>()) {
        Get.find<EmployeeHomeController>().homeMethods();
      } else if (Get.isRegistered<AdminHomeController>()) {
        Get.find<AdminHomeController>().getMessages();
      } else if (Get.isRegistered<ClientHomeController>()) {
        Get.find<ClientHomeController>().getMessages();
      }
    }
  }
}

import 'dart:developer';

import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as skt;

import '../../modules/client/client_dashboard/controllers/client_dashboard_controller.dart';
import '../../modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import '../../routes/app_pages.dart';
import '../utils/exports.dart';

class SocketController extends GetxController {
  skt.Socket? socket;
  Rx<SocketLocationModel> socketLocationModel = SocketLocationModel().obs;

  @override
  void onInit() {
    connectToSocket();
    super.onInit();
  }

  @override
  void onClose() {
    socket?.disconnect();
    socket?.dispose();
    super.onClose();
  }

  void connectToSocket() {
    socket = skt.io("wss://server.plagit.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    _listenToCheckout();
    _listenToNewSocialPost();
    _listenToNewMessage();
    _listenToJobPosts();
  }

  void _listenToJobPosts() {
    log("sock job post listing");
    socket?.on('job', (data) {
      try {
         log("pre job data : $data");
        // if (data != null) {
          // if (data['positionId'] != null && data['positionId'].isNotEmpty) {
           // Parse the JSON string into a Map
        // Directly cast `data` to `Map<String, dynamic>` if it's already in the correct format
      // Decode the JSON string into a Map
     // Check if data is already a Map
      if (data is Map<String, dynamic>) {
        log("Processing job data: $data");
  
          if (Get.find<AppController>().user.value.isClient == true) {
             final controller =  Get.find<ClientHomePremiumController>();
            // Get.find<ClientHomePremiumController>().jobPostDataLoaded.value=true;
            // Get.find<ClientHomePremiumController>().myJobPostDataLoaded.value=true;
            controller.getJobPosts(isSocketCall: true); 
            controller.getMyJobPosts(isSocketCall: true);
          } else if (Get.find<AppController>().user.value.isEmployee == true) {
            final controller=   Get.find<EmployeeHomeController>();
           controller.getJobPosts(isSocketCall: true);
// Get.find<ClientHomePremiumController>().getMyJobPosts();
          } else if (Get.find<AppController>().user.value.isAdmin == true) {
            final controller=  Get.find<AdminHomeController>();
              controller.getAdminJobPosts(isSocketCall: true);
          }
          Get.find<IndividualSocialFeedsController>().getMyJobPosts(isSocketCall:true);
          log("job data : $data");
        }
      } catch (e) {
        log("Error decoding job data: $e");
      }
    });
  }

  void _listenToCheckout() {
  //  log("sock listing");
    socket?.on('notification', (data) {
      try {
        // Since data is already a Map, access it directly
        final userInfo = data['userInfo'] as Map<String, dynamic>?;

        // Safely access _id
        final userId = userInfo?['_id'];
        final eventTitle = data?['title'];
        final eventBody = data?['body'];
     //   log("ID: $userId");
  //      log("app ID: ${Get.find<AppController>().user.value.userId}");
   //     log("title : ${eventTitle}");
        if (userId != null &&
            userId == Get.find<AppController>().user.value.userId &&
            eventTitle == 'Check out') {
      //    log("ID: $userId");
      //    log("title : $eventTitle");
          // Notify other controllers if necessary
          Get.find<ClientDashboardController>().fetchTodayEmployees(
            startDate: DateTime.now(),
            endDate: DateTime.now(),
          );
        } else if (userId != null &&
            userId == Get.find<AppController>().user.value.userId &&
            eventTitle == 'Checkin') {
          Utils.showSnackBar(message: "$eventBody", isTrue: true);
        } else {
    //      log("ID not found in notification data.");
        }
      //  log("Notification  received: $data");
      } catch (e) {
     //   log("Error decoding notification data: $e");
      }
    });
  }

  void _listenToNewMessage() {
    socket?.on('new_message', (data) async {
      try {
        for (int i = 0; i < data['message']['receiverDetails'].length; i++) {
          if ("${data['message']['receiverDetails'][i]['receiverId']}" ==
              Get.find<AppController>().user.value.userId) {
            Get.rawSnackbar(
                mainButton: TextButton(
                  onPressed: () {
                    Get.toNamed(Routes.chatIt); // Navigate to the desired route
                  },
                  child: Text(
                    MyStrings.details.tr.toUpperCase(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                        color: Colors.white,
                        fontFamily: "Montserrat"),
                  ),
                ),
                snackStyle: SnackStyle.FLOATING,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(10.0),
                titleText: Text(
                  MyStrings.newMessage.tr.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontFamily: "Montserrat"),
                ),
                messageText: Text(
                  "${data['message']['senderDetails']['name']}: ${data['message']['text']}",
                  style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.white,
                      fontFamily: "Montserrat"),
                ),
                backgroundColor: MyColors.c_C6A34F,
                borderRadius: 10.0);

            ///Refresh related chat list and unread message
            Get.find<AppController>().user.value.isClient
                ? Get.find<ClientHomeController>().getMessages()
                : Get.find<AppController>().user.value.isAdmin
                    ? Get.find<AdminHomeController>().getUnreadMessages()
                    : Get.find<AppController>().user.value.isEmployee
                        ? Get.find<EmployeeHomeController>().getUnreadMessages()
                        : null;

            Get.find<ChatItController>().refreshConversationListOnSocketEvent();
          }
        }
      } catch (e) {
        log("Error decoding notification data: $e");
      }
    });
  }

  void _listenToNewSocialPost() {
    socket?.on('social_post', (data) async {
      try {
        if (Get.find<AppController>().user.value.isClient) {
          Get.find<ClientHomePremiumController>().isNewPostAvailable(true);
        }
        else if (Get.find<AppController>().user.value.isEmployee) {
          Get.find<EmployeeHomeController>().isNewPostAvailable(true);
        } else if (Get.find<AppController>().user.value.isAdmin) {
          Get.find<AdminHomeController>().isNewPostAvailable(true);
        }
      } catch (e) {
        log("Error refreshing Social Feed: $e");
      }
    });
  }
}

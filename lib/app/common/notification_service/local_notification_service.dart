import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import '../../modules/admin/admin_home/controllers/admin_home_controller.dart';
import '../utils/exports.dart';
import 'notification_click_helper.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@drawable/icon_notification"),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentSound: true,
      ),
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _notificationsPlugin.initialize(
      initializationSettings,
    /*  onDidReceiveBackgroundNotificationResponse: (NotificationResponse notificationResponse) {
        // when app running click
        if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
          NotificationClickHelper.goToRoute(notificationResponse.payload);
        }
      },*/
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        if (kDebugMode) {
          print("🔔 Notification Clicked!");
        }
        if (details.payload != null) {
          if (kDebugMode) {
            print("📩 Clicked Notification Payload: ${details.payload}");
          }
          NotificationClickHelper.goToNewRoute(details.payload);
        } else {
          if (kDebugMode) {
            print("⚠️ No Payload Found!");
          }
        }
      },
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage? message) {
        if (message != null) {
          // NotificationClickHelper.goToRoute(jsonEncode(message.data));
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        if (kDebugMode) {
          print("FirebaseMessaging.onMessage.listen (Foreground)");
        }
        if (message.notification != null) {
          // print(message.notification?.title);
          // print(message.notification?.body);f
          // print("message.data ${message.data}");

          if ((message.notification?.title ?? "").toLowerCase().contains("employee request")) {
            if (Get.isRegistered<AppController>()) {
              if (Get.find<AppController>().user.value.isAdmin) {
                if (Get.isRegistered<AdminHomeController>()) {
                  Get.find<AdminHomeController>().reloadPage();
                }
              }
            }
          }

          LocalNotificationService.showNotification(message);
          if (Get.isRegistered<EmployeeHomeController>()) {
            Get.find<EmployeeHomeController>().homeMethods();
          } else if (Get.isRegistered<AdminHomeController>()) {
            Get.find<AdminHomeController>().getMessages();
          } else if (Get.isRegistered<ClientHomeController>()) {
            Get.find<ClientHomeController>().getMessages();
          }
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        if (kDebugMode) {
          print("FirebaseMessaging.onMessageOpenedApp.listen");
        }
        if (message.notification != null) {
          debugPrint('Push Notification data');
          debugPrint(jsonEncode(message.data));
          NotificationClickHelper.goToNewRoute(jsonEncode(message.data));
        }
      },
    );
  }

  // @pragma('vm:entry-point')
  // static void notificationTapBackground(NotificationResponse details) {
  //   print("🔔 Notification tapped in background!");
  //   print("🔔 Payload: ${details.payload}");
  //   // Handle background notification tap
  // }

  static void showNotification(RemoteMessage message) async {
    try {
      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final String payloadData = jsonEncode(message.data);
      if (kDebugMode) {
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        print('full message: ${message.toMap()}');
      }

      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "mh_fcm_id",
          "mh_fcm_channel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification?.title ?? "Greetings",
        message.notification?.body ?? "Thanks for using Plagit",
        notificationDetails,
        payload: payloadData, // Ensure payload is properly set
      );

      if (kDebugMode) {
        print("✅ Local Notification Triggered!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error in showNotification: $e");
      }
    }
  }
  static void dismissAllNotifications() {
    _notificationsPlugin.cancelAll();
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mh/firebase_options.dart';
import 'app/common/background_service/background_upload_service.dart';
import 'app/common/deep_link_service/deep_link_service.dart';
import 'app/common/notification_service/local_notification_service.dart';
import 'app/common/utils/initializer.dart';
import 'plag_it.dart';
// import 'app/modules/common_modules/notifications/controllers/notifications_controller.dart';

// final NotificationsController notificationsController =
//     Get.find<NotificationsController>();

String userProfilePic = '';

Map<String, dynamic>? storedNotification;

bool isFlutterLocalNotificationsInitialized = false;
late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await setupFlutterNotifications();
  showFlutterNotification(message);

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    // flutterLocalNotificationsPlugin.show(
    //   notification.hashCode,
    //   notification.title,
    //   notification.body,
    //   NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       channel.id,
    //       channel.name,
    //       channelDescription: channel.description,
    //       // TODO add a proper drawable resource to android, for now using
    //       //      one that already exists in example app.
    //       icon: 'launch_background',
    //       channelShowBadge: true ,
    //
    //     ),
    //   ),
    // );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    storedNotification = initialMessage.data;
  }

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    if (kDebugMode) {
      print("=============== REFRESHED FCM TOKEN =================");
      print(token);
    }
  });

  // FirebaseMessaging.instance.getToken().then((String? value) {
  //   if (kDebugMode) {
  //     print("=============== FCM TOKEN =================");
  //     print(value);
  //   }
  // });

  // Register background handler before initializing
  // await FlutterLocalNotificationsPlugin().initialize(
  //   const InitializationSettings(
  //     android: AndroidInitializationSettings("@drawable/icon_notification"),
  //     iOS: DarwinInitializationSettings(
  //       requestAlertPermission: true,
  //       requestBadgePermission: true,
  //       requestSoundPermission: true,
  //       defaultPresentSound: true,
  //     ),
  //   ),
  //   onDidReceiveBackgroundNotificationResponse: BackgroundUploadService.notificationTapBackground,
  // );

  await BackgroundUploadService.init();
  await Get.putAsync<DeepLinkService>(() async => DeepLinkService());
  // await Get.putAsync<  LocationService>(() async => LocationService());

  // if (await FlutterAppIconBadge.isAppBadgeSupported()) {
  //   FlutterAppIconBadge.updateBadge(notificationsController.unreadCount.value);
  // }

  LocalNotificationService.initialize();
  Initializer.instance.init().then((value) async {
    runApp(
      PlagIt(),
    );
  });
}

/// ERROR CODE
/// 1000 -> type conversion
/// 1001 -> unknown api error [ApiErrorHandle]
/// 1002 -> location service unavailable
/// 1002 -> location

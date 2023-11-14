import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app/common/notification_service/local_notification_service.dart';
import 'app/common/utils/initializer.dart';
import 'app/mirko_hospitality.dart';


Future<void> backgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("=============== backgroundHandler =================");
    print(message.data.toString());
    print(message.notification!.title);
    print("=============== backgroundHandler =================");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
    if (kDebugMode) {
      print("=============== REFRESHED FCM TOKEN =================");
      print(token);
    }
    // NotificationRepository().saveUUIDAndFcmToken(token : token);
  });

  FirebaseMessaging.instance.getToken().then((String? value) {
    if (kDebugMode) {
      print("=============== FCM TOKEN =================");
      print(value);
    }
  });

  LocalNotificationService.initialize();

  Initializer.instance.init().then((value) {
    runApp(const MirkoHospitality());
  });

  // Initializer.instance.init(() {
  //   // runApp(DevicePreview(
  //   //   enabled: !kReleaseMode,
  //   //   builder: (context) => const MirkoHospitality(),
  //   // ));
  //   runApp(const MirkoHospitality());
  // });
}


/// ERROR CODE
/// 1000 -> type conversion
/// 1001 -> unknown api error [ApiErrorHandle]
/// 1002 -> location service unavailable
/// 1002 -> location
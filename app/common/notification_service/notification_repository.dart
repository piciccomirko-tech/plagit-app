// import 'dart:convert';
// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:billmatez/config/app_urls.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../config/shared_preference_helper.dart';
// import '../config/user_shared_preference.dart';
//
// class NotificationRepository {
//   Dio dio = Dio();
//
//   Future sendUUIDToApi({required String token, String? uuid}) async {
//     var authToken = await UserSharedPreference.getString(SharedPreferenceHelper.accessToken);
//
//     final response = await dio.post(
//       device,
//       data: json.encode({
//         "token": token,
//         "platform": Platform.isAndroid ? "android" : "ios",
//         "uuid": uuid,
//       }),
//       options: Options(
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Vary': 'Accept',
//           'Authorization': 'Bearer $authToken'
//         },
//
//         // followRedirects: false,
//       ),
//     );
//     return response;
//   }
//
//   Future<void> saveUUIDAndFcmToken({String? token}) async {
//
//     // if token is null try to collect token
//     if (token == null) {
//       await FirebaseMessaging.instance.getToken().then((fcmToken) async {
//         token = fcmToken;
//       });
//     }
//
//     if (kDebugMode) {
//       print("=============== FCM TOKEN =================");
//       print(token);
//     }
//
//     // if token is null return
//     if (token == null) return;
//
//
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("fcm", token!);
//
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//
//     String? deviceIdentifier;
//
//
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo build = await deviceInfo.androidInfo;
//       // deviceName = build.model;
//       // deviceVersion = build.version.toString();
//
//       deviceIdentifier = build.androidId ?? build.id; //UUID for Android
//     } else if (Platform.isIOS) {
//       IosDeviceInfo data = await deviceInfo.iosInfo;
//       // deviceName = data.name;
//       // deviceVersion = data.systemVersion;
//       deviceIdentifier = data.identifierForVendor; //UUID for iOS
//     }
//
//     try {
//       Response response = await sendUUIDToApi(token: token!, uuid: deviceIdentifier);
//       print("update fcm in db -> Status code: ${response.statusCode}");
//     } on DioError catch (e) {
//       print("update fcm in db ERROR -> ${e.response?.statusCode}");
//       print("update fcm in db ERROR -> ${e.response?.statusMessage}");
//     }
//   }
// }

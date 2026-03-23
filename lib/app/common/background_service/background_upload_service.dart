import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mh/app/repository/chunked_upload_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/admin/admin_home/controllers/admin_home_controller.dart';
import '../../modules/client/client_home/controllers/client_home_controller.dart';
import '../../modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import '../../modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import '../../modules/common_modules/create_post/models/post_upload_model.dart';
import '../../modules/employee/employee_home/controllers/employee_home_controller.dart';
import '../../modules/employee/employee_root/controllers/employee_root_controller.dart';
import '../../routes/app_pages.dart';

class BackgroundUploadService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const String _channelId = 'upload_channel';
  static const String _channelName = 'Upload Progress';

  static final _uploadService = ChunkedUploadRepo();

  static Future<void> init() async {
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true, // Add permission requests
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          if (kDebugMode) {
            print("🔔 iOS notification received: $payload");
          }
          // Handle iOS foreground notification
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
        });
    var initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        if (details.payload != null) {
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
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Shows upload progress',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: false,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Upload Started',
        initialNotificationContent: 'Preparing upload...',
        foregroundServiceNotificationId: 1,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> startUpload(PostUpload post, String token,
      {String? postId}) async {
    if (kIsWeb) return;

    try {
      if (kDebugMode) {
        print('Starting upload process...');
      }

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final prefs = await SharedPreferences.getInstance();
      final postData = {
        ...post.toJson(),
        'postId': postId,
      };
      await prefs.setString('pending_upload', jsonEncode(postData));
      await prefs.setString('bearerToken', token);

      await showNotification(
        'Starting Upload',
        'Preparing files...',
        progress: 0,
      );

      final service = FlutterBackgroundService();
      await service.startService();

      if (kDebugMode) {
        print('Background service started');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error starting upload: $e');
      }
      await showNotification(
        'Upload Failed',
        'Failed to start upload',
        isError: true,
      );
      rethrow;
    }
  }

  static Future<void> showNotification(String title, String message,
      {int progress = 0, bool isError = false, String? postId}) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Shows upload progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: !isError && progress < 100,
      maxProgress: 100,
      progress: progress,
      ongoing: !isError && progress < 100,
      autoCancel: isError || progress >= 100,
      enableVibration: true,
      playSound: true,
      channelShowBadge: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      fullScreenIntent: true,
      category: AndroidNotificationCategory.social,
    );
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      threadIdentifier: _channelId,
    );
    await _notifications.show(
      0,
      title,
      message,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({'type': 'background_service_payload'}),
    );
  }

  static Future<void> showProgressNotification(int progress,
      {String? message}) async {
    final androidDetails = AndroidNotificationDetails(
      'upload_channel',
      'Upload Progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      ongoing: progress < 100,
      autoCancel: progress >= 100,
    );

    await _notifications.show(
      0,
      progress >= 100 ? 'Upload Complete' : 'Uploading Post',
      message ?? 'Upload in progress: $progress%',
      NotificationDetails(android: androidDetails),
    );
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(NotificationResponse details) {
    if (kDebugMode) {
      print("🔔 Notification tapped in background!");
      print("🔔 Payload: ${details.payload}");
    }
    // Handle background notification tap
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (kDebugMode) {
    print('Background service starting...');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final postJson = prefs.getString('pending_upload');
    final token = prefs.getString('bearerToken');

    if (kDebugMode) {
      print('android amskmkmskdmk $token');
    }
    if (postJson == null) {
      if (kDebugMode) {
        print('No pending upload found');
      }
      service.stopSelf();
      return;
    }

    if (kDebugMode) {
      print('Found pending upload, starting process...');
    }
    final postData = jsonDecode(postJson);
    final post = PostUpload.fromJson(postData);
    final postId = postData['postId'] as String?;

    await BackgroundUploadService.showNotification(
      'Starting Upload',
      'Preparing files...',
      progress: 0,
    );

    // final files = post.mediaFiles.map((path) => File(path)).toList();

    try {
      await BackgroundUploadService._uploadService.uploadMultipleFiles(
        post.mediaFiles,
        onProgress: (progress) async {
          await BackgroundUploadService.showNotification(
            'Uploading',
            'Progress: ${progress.round()}%',
            progress: progress.round(),
          );
        },
        content: post.caption,
        token: token.toString(),
        postId: postId,
      );

      if (kDebugMode) {
        print('All files uploaded successfully');
      }
      await BackgroundUploadService.showNotification(
          'Upload Complete',
          postId != null
              ? 'Your post has been updated successfully!'
              : 'Your post has been uploaded successfully!',
          progress: 100,
          postId: postId);
      await prefs.remove('pending_upload');
      service.stopSelf();
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading files: $e');
      }
      await BackgroundUploadService.showNotification(
        'Upload Failed',
        'Failed to upload. Please try again.',
        isError: true,
      );
      await prefs.remove('pending_upload');
      service.stopSelf();
      return;
    }

    await prefs.remove('pending_upload');
    service.stopSelf();
  } catch (e) {
    if (kDebugMode) {
      print('Service error: $e');
    }
    await BackgroundUploadService.showNotification(
      'Upload Failed',
      'An error occurred. Please try again.',
      isError: true,
    );
    service.stopSelf();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  if (kDebugMode) {
    print('iOS background service starting...');
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final postJson = prefs.getString('pending_upload');
    final token = prefs.getString('bearerToken');

    if (kDebugMode) {
      print('iOS amskmkmskdmk $token');
    }

    if (postJson == null) {
      if (kDebugMode) {
        print('No pending upload found for iOS');
      }
      return false;
    }

    if (kDebugMode) {
      print('Found pending upload for iOS, starting process...');
    }
    final postData = jsonDecode(postJson);
    final post = PostUpload.fromJson(postData);
    final postId = postData['postId'] as String?;

    await BackgroundUploadService.showNotification(
      'Starting Upload',
      'Preparing files...',
      progress: 0,
    );

    // final files = post.mediaFiles.map((path) => File(path)).toList();

    try {
      await BackgroundUploadService._uploadService.uploadMultipleFiles(
        post.mediaFiles,
        onProgress: (progress) async {
          await BackgroundUploadService.showNotification(
            'Uploading',
            'Progress: ${progress.round()}%',
            progress: progress.round(),
          );
        },
        content: post.caption,
        token: token.toString(),
        postId: postId,
      );

      if (kDebugMode) {
        print('All files uploaded successfully on iOS');
      }
      await BackgroundUploadService.showNotification(
        'Upload Complete',
        postId != null
            ? 'Your post has been updated successfully!'
            : 'Your post was uploaded successfully!',
        progress: 100,
      );

      await prefs.remove('pending_upload');
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading files on iOS: $e');
      }
      await BackgroundUploadService.showNotification(
        'Upload Failed',
        'Failed to upload. Please try again.',
        isError: true,
      );
      await prefs.remove('pending_upload');
      return false;
    }
  } catch (e) {
    if (kDebugMode) {
      print('iOS service error: $e');
    }
    await BackgroundUploadService.showNotification(
      'Upload Failed',
      'An error occurred. Please try again.',
      isError: true,
    );
    return false;
  }
}

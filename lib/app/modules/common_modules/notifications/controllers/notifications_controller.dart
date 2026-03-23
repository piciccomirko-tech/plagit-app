import 'package:dartz/dartz.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../../main.dart';
import '../../../../models/client_edit_profile.dart';
import '../../../../models/social_feed_response_model.dart';

class NotificationsController extends GetxController {
  final ApiHelper _apiHelper = Get.find();
  RxList<BookingDetailsModel> notificationList = <BookingDetailsModel>[].obs;
  RxBool notificationDataLoaded = false.obs;
  RxBool isDataProcessing = false.obs;
  RxBool isMoreDataAvailable = true.obs;
  ScrollController scrollController = ScrollController();
  int page = 1;
  BuildContext? context;
  RxInt unreadCount = 0.obs;

  @override
  void onInit() async {
    await getNotificationList();
    paginateNotification();
    super.onInit();
  }

  Future<void> getNotificationList() async {
    isDataProcessing.value = true;
    Either<CustomError, NotificationResponseModel> response =
        await _apiHelper.getNotifications(page: 1);
    isDataProcessing.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(
          Get.context!, customError..onRetry = getNotificationList);
    }, (NotificationResponseModel responseModel) {
      if (responseModel.status == 'success' &&
          responseModel.statusCode == 200) {
        notificationList.value = responseModel.notifications ?? [];
        notificationList.refresh();
        _countUnread();
        notificationDataLoaded.value = true;

        FlutterAppBadgeControl.isAppBadgeSupported().then((value) {
          FlutterAppBadgeControl.updateBadgeCount(unreadCount.value);
        });
      }
    });
  }

  void updateNotification(
      {required bool readStatus, required BookingDetailsModel notification}) {
    CustomLoader.show(context!);

    NotificationUpdateRequestModel notificationUpdateRequestModel =
        NotificationUpdateRequestModel(
            id: notification.id ?? "",
            fromWhere: 'notifications',
            readStatus: readStatus);
    _apiHelper
        .updateNotification(
            notificationUpdateRequestModel: notificationUpdateRequestModel)
        .then((Either<CustomError, NotificationUpdateResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (NotificationUpdateResponseModel responseModel) async {
        if (responseModel.status == 'success' &&
            responseModel.statusCode == 200) {
          setupFlutterNotifications();
          await flutterLocalNotificationsPlugin.cancelAll();
          getNotificationList();
          if (notification.appRoute != null) {
            if (notification.appRoute == "/client-home") {
              Get.offAllNamed(Routes.clientPremiumRoot);
            } else if (notification.appRoute == "/admin-home") {
              Get.offAllNamed(Routes.adminHome);
            } else if (notification.appRoute == "/client-payment-and-invoice") {
              Get.toNamed(notification.appRoute ?? "",
                  arguments: 'notification');
            } else if (notification.appRoute == "/social-post_details") {
              if (containArgument(url: "${notification.webRoute}")) {
                Get.toNamed(notification.appRoute ?? "",
                    arguments:
                        extractArgument(url: "${notification.webRoute}"));
              }
            } else if (notification.appRoute == "/job-post-details") {
              if (containArgument(url: "${notification.webRoute}")) {
                Get.toNamed(
                  notification.appRoute ?? "",
                  arguments: {
                    'jobPostId':
                        extractArgument(url: "${notification.webRoute}"),
                    'isMyJobPost': true, // or false, depending on your logic
                  },
                );
              }
            } else if (notification.appRoute == "/client-edit-profile") {
              Get.toNamed(Routes.clientEditProfile);
            } else if (notification.appRoute == "/employee-edit-profile") {
              Get.toNamed(Routes.employeeEditProfile);
            } else if (notification.appRoute == "/individual-social_feeds") {
              getClientUserDetails(notification);
            } else if (notification.appRoute == "/employee-details") {
              Get.toNamed(Routes.employeeDetails,
                  arguments: {'employeeId': notification.createdBy ?? ""});
            } else {
              Get.toNamed("${notification.appRoute}");
            }
          }
        }
      });
    });
  }

  void getClientUserDetails(BookingDetailsModel notificationnn) {
    CustomLoader.show(context!);
    _apiHelper
        .clientDetails(notificationnn.createdBy ?? '')
        .then((Either<CustomError, ClientEditProfileModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ClientEditProfileModel responseModel) {
        if (responseModel.status == 'success') {
          Get.toNamed(Routes.individualSocialFeeds,
              arguments: SocialUser(
                  id: notificationnn.createdBy,
                  name: "${responseModel.details?.restaurantName}",
                  positionId: responseModel.details?.positionId ?? '',
                  email: responseModel.details?.email ?? '',
                  role: responseModel.details?.role,
                  profilePicture: responseModel.details?.profilePicture ?? '',
                  countryName: responseModel.details?.countryName ?? ''));
        } else {}
      });
    });
  }

  void _countUnread() {
    unreadCount.value = 0;
    for (var i in notificationList) {
      if (i.readStatus == false) {
        unreadCount.value += 1;
      }
    }
  }

  void paginateNotification() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        page++;
        await getMoreNotifications();
      }
    });
  }

  Future<void> getMoreNotifications() async {
    try {
      Either<CustomError, NotificationResponseModel> response =
          await _apiHelper.getNotifications(page: page);
      response.fold((CustomError customError) {
        Utils.errorDialog(
            Get.context!, customError..onRetry = getNotificationList);
      }, (NotificationResponseModel responseModel) {
        if (responseModel.status == 'success' &&
            responseModel.statusCode == 200) {
          if (responseModel.notifications!.isNotEmpty) {
            isMoreDataAvailable.value = true;
          } else {
            isMoreDataAvailable.value = false;
          }
          notificationList.addAll(responseModel.notifications ?? []);
          _countUnread();
        }
      });
    } catch (e) {
      isMoreDataAvailable.value = false;
    }
  }

  void deleteNotification({required String notificationId}) {
    CustomLoader.show(context!);
    _apiHelper
        .deleteNotification(notificationId: notificationId)
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseModel) {
        if (responseModel.status == 'success') {
          getNotificationList();
          Utils.showSnackBar(
              message: responseModel.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(
              message: responseModel.message ?? "Failed to delete notification",
              isTrue: false);
        }
      });
    });
  }

  void readAll() {
    CustomLoader.show(context!);
    _apiHelper
        .readAllNotification()
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseModel) async {
        if (responseModel.status == 'success') {
          getNotificationList();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0.0);
    });

          Utils.showSnackBar(
              message: responseModel.message ?? "", isTrue: true);
          FlutterAppBadgeControl.removeBadge();
          setupFlutterNotifications();
          await flutterLocalNotificationsPlugin.cancelAll();
        } else {
          Utils.showSnackBar(
              message:
                  responseModel.message ?? "Failed to read all notification",
              isTrue: false);
        }
      });
    });
  }


  Future<void> onRefresh() async {
    notificationDataLoaded.value = false;
    await getNotificationList();
  }

  // Global function to extract job_id from a given string
  String extractArgument({required String url}) {
    RegExp regExp = RegExp(r"[a-f0-9]{24}");
    RegExpMatch? match = regExp.firstMatch(url);

    if (match != null) {
      return match.group(0)!; // Non-nullable job_id
    } else {
      throw Exception('Job ID not found in the provided string');
    }
  }

// Check if the URL has a valid job_id
  bool containArgument({required String url}) {
    // Check if the string contains a job_id before calling the function
    if (RegExp(r"[a-f0-9]{24}").hasMatch(url)) {
      return true;
    } else {
      return false;
    }
  }
}

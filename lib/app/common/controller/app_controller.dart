import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/admin.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../main.dart';
import '../../enums/user_type.dart';
import '../../models/client.dart';
import '../../models/commons.dart';
import '../../models/dropdown_item.dart';
import '../../models/employee.dart';
import '../../models/employee_full_details.dart';
import '../../models/followers_response_model.dart';
import '../../models/user.dart';
import '../../modules/client/common/shortlist_controller.dart';
import '../../modules/common_modules/splash/controllers/splash_controller.dart';
import '../../routes/app_pages.dart';
import '../deep_link_service/deep_link_service.dart';
import '../local_storage/storage_helper.dart';
import 'dart:convert';

import '../notification_service/local_notification_service.dart';

class AppController extends GetxService {
  var myFollowingList = <Following>[].obs;
  var currentUserEmail = ''.obs;
  var currentUserIsAlter = false.obs;
  Rx<Commons>? commons = Commons().obs;

  RxList<DropdownItem> employeeSearchList = <DropdownItem>[].obs;
  RxList<DropdownItem> allActivePositions = <DropdownItem>[].obs;
  RxList<DropdownItem> skills = <DropdownItem>[].obs;

  // i dont know why MediaQuery.of(context).viewInsets.bottom not work in bottom sheet on this project
  // that's why store MediaQuery.of(context).viewInsets.bottom (basically keyboard height) in a observable variable
  RxDouble bottomPadding = 0.0.obs;

  Rx<User> user = User(
    userType: UserType.guest,
  ).obs;

  void setTokenFromLocal() async {
    await _updateUserModel();
  }

  Future<void> fetchAndUpdateUserData(String userId) async {
    try {
      final Either<CustomError, EmployeeFullDetails> response =
          await Get.find<ApiHelper>().employeeFullDetails(
              userId); // handle all user types - admin/client/employee

      response.fold(
        (error) {
          log("Failed to fetch updated employee profile: ${error.msg}");
          // Utils.showSnackBar(
          //   message: "Error refreshing employee data: ${error.msg}",
          //   isTrue: false,
          // );
        },
        (employeeDetails) {
          log("newly fetched data: ${employeeDetails.details}");
          // Update the User model with the fetched details
          if (user.value.isEmployee) {
            user.value.employee =
                Employee.fromJson(employeeDetails.details!.toJson());
            log("emp being updated: ${Employee.fromJson(employeeDetails.toJson())}");
            log("emp being updated: ${employeeDetails.toJson()}");
            // user.value.employee=employeeDetails.toJson() as Employee?;
            log("emp being country: ${user.value.employee?.countryName}");
          } else if (user.value.isClient) {
            log("clnt being updated: ${Employee.fromJson(employeeDetails.details!.toJson())}");
            user.value.client =
                Client.fromJson(employeeDetails.details!.toJson());
            log("clnt being country: ${user.value.client?.countryName}");
          } else if (user.value.isAdmin) {
            user.value.admin =
                Admin.fromJson(employeeDetails.details!.toJson());
          }

          user.refresh(); // Notify observers
          log("Employee profile updated successfully in AppController.");
        },
      );
    } catch (e) {
      log("Error fetching updated employee profile: $e");
      Utils.showSnackBar(
        message: "Error fetching updated employee profile. Please try again.",
        isTrue: false,
      );
    }
  }

  Future<void> refreshUserProfile() async {
    if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
      if (!_isTokenExpire()) {
        // Decode the token and refresh the user model
        if (user.value.userType == UserType.client) {
          Client temp =
              Client.fromJson(JwtDecoder.decode(StorageHelper.getToken));
          user.value.client = temp;
        } else if (user.value.userType == UserType.employee) {
          Employee temp =
              Employee.fromJson(JwtDecoder.decode(StorageHelper.getToken));
          user.value.employee = temp;
        } else if (user.value.userType == UserType.admin) {
          Admin temp =
              Admin.fromJson(JwtDecoder.decode(StorageHelper.getToken));
          user.value.admin = temp;
        }
        user.refresh(); // Refresh the observable to trigger UI updates
      } else {
        Logcat.msg("Token Expired");
        Get.offAllNamed(Routes.login);
      }
    }
  }

  Future<void> _updateUserModel() async {
    if (StorageHelper.hasToken && StorageHelper.getToken.isNotEmpty) {
      if (!_isTokenExpire()) {
        Client temp =
            Client.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        if (temp.role == "CLIENT") {
          // final Either<CustomError, CommonResponseModel> responseData = await Get.find<ApiHelper>().checkSubscription();
          //
          // responseData.fold((CustomError customError) {
          //   user.value.userType = UserType.client;
          // }, (CommonResponseModel response) {
          //   if (response.status == "success") {
          //     user.value.userType = UserType.premiumClient;
          //   } else {
          //     user.value.userType = UserType.client;
          //   }
          // });
          user.value.userType = UserType.client;
          user.value.client = temp;
        } else if (temp.role == "EMPLOYEE") {
          // log("employeeeeeeeeeeeeeeeeee");
          user.value.userType = UserType.employee;
          //  log("emp data: ${ Employee.fromJson(JwtDecoder.decode(StorageHelper.getToken)).toJson()}");
          user.value.employee =
              Employee.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        } else if (temp.role == "ADMIN") {
          user.value.userType = UserType.admin;
          user.value.admin =
              Admin.fromJson(JwtDecoder.decode(StorageHelper.getToken));
        } else {
          user.value.userType = UserType.guest;
        }
        user.refresh();
        if (user.value.isGuest) {
          _updateFCMToken(isLogin: false);
          Get.offAndToNamed(Routes.loginRegisterHints);
        } else {
          _updateFCMToken();
          activeShortlistService();

          // Always navigate to home screen first
          Get.offAndToNamed(user.value.userType!.homeRoute);

          // Check if we have notification data
          if (storedNotification != null) {
            // Add delay to ensure home screen is loaded
            await Future.delayed(const Duration(milliseconds: 100), () {
              if (storedNotification!['type'].toString() == "social-post") {
                Get.toNamed("/social-post_details",
                    arguments: storedNotification!["id"].toString());

                storedNotification = null;
              }
            });
          }

          // Mark deep link service as initialized
          final deepLinkService = Get.find<DeepLinkService>();
          deepLinkService.markInitialized();
        }
      } else {
        Logcat.msg("Token Expired, trying to renew");
        refreshToken();
        // Get.offAllNamed(Routes.login);
      }
    } else {
      Logcat.msg("User Token not found in local");
      Get.offAndToNamed(Routes.loginRegisterHints);
    }
  }

  refreshToken() async {
    try {
      var result = await Get.find<ApiHelper>()
          .getRefreshToken(currentRefreshToken: StorageHelper.getRefreshToken);
      result.fold(
        (failure) {},
        (result) async {
          if (result.statusCode == 200) {
            // print(result.token);
            await StorageHelper.setToken(result.token?.accessToken ?? '');
            await StorageHelper.setRefreshToken(
                result.token?.refreshToken ?? '');

            // print('after refresh token ');
            // print(JwtDecoder.getExpirationDate(StorageHelper.getToken));
            // print(JwtDecoder.getRemainingTime(StorageHelper.getToken));
            // print(JwtDecoder.getTokenTime(StorageHelper.getToken));

            await afterSuccessLogin(result.token?.accessToken ?? '');
            await updateRefreshToken(result.token?.refreshToken ?? '');
            await _fetchSavedPost();
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _fetchSavedPost() async {
    var result = await Get.find<ApiHelper>().getSavedPost();
    result.fold(
      (failure) {},
      (skills) {
        savedPostList.clear();
        savedPostList.addAll(skills);
      },
    );
  }

  bool _isTokenExpire() => JwtDecoder.isExpired(StorageHelper.getToken);

  Future<void> afterSuccessLogin(String token) async {
    await updateToken(token);

    _updateFCMToken();

    if (user.value.userType == null) {
    } else {
      activeShortlistService();
      debugPrint('user.value.userType!.homeRoute');
      debugPrint(user.value.userType!.homeRoute);
      Get.offAllNamed(user.value.userType!.homeRoute);
    }
  }

  Future<void> updateToken(String token) async {
    // update token on local
    await StorageHelper.setToken(token);

    // update user model for globally
    await _updateUserModel();
  }

  Future<void> updateRefreshToken(String refreshToken) async {
    await StorageHelper.setRefreshToken(refreshToken);
  }

  void setPositions(List<DropdownItem>? positions) {
    allActivePositions.value =
        (positions ?? []).where((position) => position.active == true).toList();
    allActivePositions.refresh();
  }

  void setCommons(Commons commons) {
    this.commons?.value = commons;
    this.commons?.refresh();

    skills.value = commons.skills ?? [];
    skills.refresh();
    String jsonString = '''
  [
    {
      "_id": "0",
      "name": "Dashboard",
      "active": true,
      "logo": "assets/images/mh_employees.png"
    },
    {
      "_id": "1",
      "name": "Calendar",
      "active": true,
      "logo": "assets/icons/calender2.png"
    },
    {
      "_id": "2",
      "name": "Job Post",
      "active": true,
      "logo": "assets/images/exp.png"
    },
    {
      "_id": "3",
      "name": "Payment",
      "active": true,
      "logo": "assets/icons/payments.png"
    },
    {
      "_id": "5",
      "name": "Booked history",
      "active": true,
      "logo": "assets/icons/booked_history.png"
    },
    {
      "_id": "6",
      "name": "Hired history",
      "active": true,
      "logo": "assets/icons/hired_history.png"
    },
    {
      "_id": "7",
      "name": "Social feed",
      "active": true,
      "logo": "assets/icons/social_post.png"
    },
    {
      "_id": "8",
      "name": "Chat it",
      "active": true,
      "logo": "assets/images/mh_employees.png"
    }
  ]
''';

    List<dynamic> jsonList = json.decode(jsonString);

    List<DropdownItem> tempList = jsonList.map((jsonItem) {
      return DropdownItem.fromJson(jsonItem);
    }).toList();
    employeeSearchList.value = tempList;
    employeeSearchList.refresh();
  }

  /// call when
  /// login success - done
  /// register success
  /// after splash - done
  void activeShortlistService() {
    Get.put(ShortlistController());

    if (user.value.isClient) {
      Get.find<ShortlistController>().fetchShortListEmployees();
    }
  }

  Future<void> enterAsGuestMode() async {
    await StorageHelper.setToken("");
    activeShortlistService();
    Get.toNamed(Routes.mhEmployees);
  }

  Future<void> onLogoutClick() async {
    CustomLoader.show(Get.context!);

/*    Get.find<SocketController>().socket?.disconnected;
    Get.find<SocketController>().socket?.dispose();*/

    if (Get.isRegistered<ShortlistController>()) {
      Get.find<ShortlistController>().removeAllSelected();
    }

    await _updateFCMToken(isLogin: false);

    LocalNotificationService.dismissAllNotifications();
    await Get.find<ApiHelper>()
        .logout(currentRefreshToken: StorageHelper.getRefreshToken);
    CustomLoader.hide(Get.context!);

    StorageHelper.removeToken;

    user.value = User(userType: UserType.guest);
    user.refresh();

    Get.offAllNamed(Routes.loginRegisterHints);
  }

  bool hasPermission() {
    if (user.value.isGuest) {
      Get.toNamed(Routes.login);
      return false;
    }

    return true;
  }

  void setMyFollowingList(List<Following> myFollowing) {
    myFollowingList.value = myFollowing;
    myFollowingList.refresh();
    debugPrint('my following list size ${myFollowingList.length}');
  }

  bool isFollowing(String userId) {
    return myFollowingList.any((item) => item.id == userId);
  }

  bool isNotification(String userId) {
    // Find the employee (or user) with the given userId
    var employee = myFollowingList.firstWhere(
      (item) => item.id == userId,
      orElse: () => Following(
          id: userId, notifications: null), // return a default Following object
    );

    // Access the notifications field and return its value, defaulting to false if null
    return employee.notifications ?? false;
  }

  Future<void> _updateFCMToken({bool isLogin = true}) async {
    if (Get.isRegistered<ApiHelper>()) {
      await Get.find<ApiHelper>().updateFcmToken(isLogin: isLogin);
    }
  }
}

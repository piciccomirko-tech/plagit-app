import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/logcat.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/followers_response_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeProfileController extends GetxController {
  final ApiHelper _apiHelper = Get.find();
  RxInt totalSocialPost = 0.obs;
  RxBool totalSocialPostDataLoaded = false.obs;

  RxBool followersLoading = false.obs;
  Rx<Result> employeeFollowers = Result().obs;
  var selectedIndex = 0.obs;
  RxBool loadingFollow = false.obs;
  final AppController appController = Get.find<AppController>();
  String employeeId = '';

  @override
  void onInit() {
    getSocialFeeds();
    _getFollowers();
    super.onInit();
  }

  Future<void> _getFollowers() async {
    followersLoading.value = true;
    Either<CustomError, FollowersResponseModel> response =
        await _apiHelper.employeeFollowersDetails(
      Get.find<AppController>().user.value.userId,
    );
    followersLoading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (FollowersResponseModel r) {
      if (r.status == "success" && r.statusCode == 200 && r.result != null) {
        employeeFollowers.value = r.result!;
        employeeFollowers.refresh();

        if (kDebugMode) {
          print("Followers: ${r.result?.followers?.length}");
        }
      }
    });
  }

  void getSocialFeeds({bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      totalSocialPostDataLoaded.value = true;
    } else {
      totalSocialPostDataLoaded.value = false;
    }
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: Get.find<AppController>().user.value.userId,
                limit: 10,
                page: 1,
                socialFeedType: SocialFeedType.self));
    responseData.fold((CustomError customError) {},
        (SocialFeedResponseModel response) {
      if (response.status == "success") {
        totalSocialPost.value = response.socialFeeds?.total ?? 0;
        totalSocialPost.refresh();
        if (isSocketCall == false) totalSocialPostDataLoaded.value = false;
      }
    });
  }

  Future<void> followUnfollow(String id, int index) async {
    if (loadingFollow.value == true) {
      return;
    }
    selectedIndex.value = index;
    loadingFollow(true);
    Map<String, dynamic> data = {
      "followUserId": id,
    };

    await _apiHelper.followUnfollow(data).then((response) {
      response.fold((CustomError customError) {
        log("errrr=> $customError");
      }, (r) async {
        if ([200, 201].contains(r.statusCode)) {
          Utils.showSnackBar(message: (r.body)['result'], isTrue: true);

          var _id = appController.user.value.isAdmin
              ? appController.user.value.admin!.id!
              : appController.user.value.isEmployee
                  ? appController.user.value.employee!.id!
                  : appController.user.value.client!.id!;
          Either<CustomError, FollowersResponseModel> responseData =
              await _apiHelper.employeeFollowersDetails(_id);

          responseData.fold((CustomError customError) {
            Utils.showSnackBar(message: customError.msg, isTrue: true);
          }, (FollowersResponseModel response) {
            if (response.status == "success") {
              _getFollowers();
              appController
                  .setMyFollowingList(response.result!.following ?? []);
              loadingFollow(false);
              appController.isFollowing(_id);
            }
          });
        }
      });
    });
  }
}

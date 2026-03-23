import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/repost_request_model.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_post_report_request_model.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../../employee/employee_home/models/common_response_model.dart';

class ClientSavedPostController extends GetxController {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();

  RxList<SavedPostModel> savedPostList = <SavedPostModel>[].obs;
  RxBool savedPostDataLoaded = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;

  @override
  void onInit() {
    super.onInit();
    // scrollController = ScrollController();
    getSavedPost();
  }

  Future<void> getSavedPost() async {
    var responseData = await _apiHelper.getSavedPost();
    savedPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (response) {
      // if (response.status == "success") {
      savedPostList.value = response ?? [];
      // }
    });
    savedPostList.refresh();
  }

  void addReport(
      {required SocialPostReportRequestModel socialPostReportRequestModel}) {
    _apiHelper
        .addReport(socialPostReportRequestModel: socialPostReportRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status == "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      });
    });
  }

  Future<void> repost({required RepostRequestModel repostRequestModel}) async {
    Get.back();
    CustomLoader.show(context!);
    Either<CustomError, CommonResponseModel> responseData = await _apiHelper
        .repostSocialPost(repostRequestModel: repostRequestModel);
    CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CommonResponseModel response) {
      if (response.status == "success") {
        // socialCurrentPage.value = 1;
        // getSocialFeeds();
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   scrollController.jumpTo(0.0);
        // });
      }
    });
  }

  void reactPost({required String postId, required int index}) {
    if (_isReacting) return; // Prevent further calls if already in progress
    _isReacting = true; // Set the flag to true
    _apiHelper
        .reactPost(postId: postId)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status != "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      })?.whenComplete(() {
        // getSocialFeeds();
        _isReacting = false;
      });
    });
  }

  void blockUserAndRefreshSocialFeed({required String userId}) {
    if (_isBlocking) return; // Prevent further calls if already in progress
    _isBlocking = true; // Set the flag to true
    CustomLoader.show(context!);
    _apiHelper.blockUnblockUser(userId: userId, action: 'BLOCK').then(
        (Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      onRefresh();
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (UserBlockUnblockResponseModel response) async {
        if (response.statusCode == 200) {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        }
      })?.whenComplete(() {
        _isBlocking = false; // Reset the flag after the API call completes
      });
    });
  }

  Future<void> followUnfollow(String id) async {
    Map<String, dynamic> data = {
      "followUserId": id,
    };

    await _apiHelper.followUnfollow(data).then((response) {
      response.fold((CustomError customError) {
        log("errrr=> ${customError}");
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
            Utils.errorDialog(context!, customError);
          }, (FollowersResponseModel response) {
            if (response.status == "success") {
              appController
                  .setMyFollowingList(response.result!.following ?? []);
            }
          });
        }
      });
    });
  }

  Future<void> onRefresh() async {
    savedPostDataLoaded.value = false;
    await getSavedPost();
  }
}

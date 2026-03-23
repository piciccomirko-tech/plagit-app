import 'package:dartz/dartz.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_info_response_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../models/user_block_unblock_response_model.dart';
import '../../common_social_feed/controllers/common_social_feed_controller.dart';

class SocialPostDetailsController extends GetxController {
  BuildContext? context;

  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();
  Rx<SocialPostModel> socialPostInfo = SocialPostModel().obs;
  RxBool socialPostInfoDataLoading = true.obs;
  RxBool noDataFound = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;
  String socialPostId = "";

  final ApiHelper _apiHelper = Get.find<ApiHelper>();

  @override
  void onInit() {
    socialPostId = Get.arguments ?? "";
    _getSocialPostInfo();
    super.onInit();
  }

  Future<void> _getSocialPostInfo() async {
    Either<CustomError, SocialFeedInfoResponseModel> responseData =
        await _apiHelper.getSocialPostDetails(socialPostId: socialPostId);
    socialPostInfoDataLoading.value = false;

    responseData.fold((CustomError customError) {
      noDataFound.value = true;
      Utils.errorDialog(context!, customError);
    }, (response) async {
      if (response.status == "success" && response.socialFeed != null) {
        socialPostInfo.value = response.socialFeed!;
      } else {
        noDataFound.value = true;
      }
    });
  }

  Future<void> _postIncreasePostViewCount() async {
    await _apiHelper.increasePostView(socialPostId: socialPostId);
  }

  //Method For Finding Posts by ID
  Future<void> getSocialPostInfoByPostId(postId) async {
    socialPostInfoDataLoading(true);
    socialPostId = postId;
    _getSocialPostInfo();
    _postIncreasePostViewCount();
  }

  void reactPost() {
    if (_isReacting) return; // Prevent further calls if already in progress
    _isReacting = true; // Set the flag to true
    _apiHelper
        .reactPost(postId: socialPostId)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status == "success") {
          _getSocialPostInfo();
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      })?.whenComplete(() {
        _isReacting = false; // Reset the flag after the API call completes
      });
    });
  }

  void addReport(
      {required SocialPostReportRequestModel socialPostReportRequestModel}) {
    _apiHelper
        .addReport(socialPostReportRequestModel: socialPostReportRequestModel)
        .then((responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status == "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(
              message: "Failed to report this post. Please try again later.",
              isTrue: false);
        }
      });
    });
  }

  void blockUserAndRefreshSocialFeed({required String userId}) {
    if (_isBlocking) return; // Prevent further calls if already in progress
    _isBlocking = true; // Set the flag to true
    CustomLoader.show(context!);
    _apiHelper.blockUnblockUser(userId: userId, action: 'BLOCK').then(
        (Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      CustomLoader.hide(context!);
      _updateSocialPosts();
      Get.back();
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
        _updateSocialPosts();
        Get.back();
      }
    });
  }

  void _updateSocialPosts() {
    if (Get.isRegistered<ClientHomePremiumController>()) {
      Get.find<ClientHomePremiumController>().socialPostDataLoaded.value =
          false;
      Get.find<ClientHomePremiumController>().getSocialFeeds();
    } else if (Get.isRegistered<EmployeeHomeController>()) {
      Get.find<EmployeeHomeController>().socialPostDataLoaded.value = false;
      Get.find<EmployeeHomeController>().getSocialFeeds();
    } else if (Get.isRegistered<AdminHomeController>()) {
      Get.find<AdminHomeController>().socialPostDataLoaded.value = false;
      Get.find<AdminHomeController>().getSocialFeeds();
    }
  }
}

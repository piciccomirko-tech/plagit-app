import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../models/user_block_unblock_response_model.dart';
import '../../common_social_feed/controllers/common_social_feed_controller.dart';

class MySocialFeedController extends GetxController {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  final CommonSocialFeedController commonSocialFeedController =
  Get.find<CommonSocialFeedController>();

  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;

  RxInt currentPage = 1.obs;
  late ScrollController scrollController;
  RxBool moreDataAvailable = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    getSocialFeeds();
  }

  @override
  void onReady() {
    super.onReady();
    paginateTask();
  }

  Future<void> getSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: Get.find<AppController>().user.value.userId,
                limit: 10,
                page: 1,
                socialFeedType: SocialFeedType.self));
    socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        socialPostList.value = response.socialFeeds?.posts ?? [];
      }
    });
    socialPostList.refresh();
  }

  Future<void> deletePost({required String postId}) async {
    CustomLoader.show(context!);
    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.deleteSocialPost(postId: postId);
    CustomLoader.hide(context!);

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CommonResponseModel response) async {
      if (response.status == "success") {
        socialPostDataLoaded.value = false;
        await getSocialFeeds();
        WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0.0);
    });
        currentPage.value = 1;
        Utils.showSnackBar(message: response.message ?? "", isTrue: true);
      } else {
        Utils.showSnackBar(message: response.message ?? "", isTrue: false);
      }
    });
  }

  Future<void> inActivePost(
      {required String postId, required bool active}) async {
    CustomLoader.show(context!);
    Either<CustomError, CommonResponseModel> responseData =
        await _apiHelper.inactiveSocialPost(postId: postId, active: active);
    CustomLoader.hide(context!);

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CommonResponseModel response) async {
      if (response.status == "success") {
        await getSocialFeeds();
        Utils.showSnackBar(message: response.message ?? "", isTrue: true);
      } else {
        Utils.showSnackBar(message: response.message ?? "", isTrue: false);
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
        _isReacting = false; // Reset the flag after the API call completes
      });
    });
  }

  void blockUserAndRefreshSocialFeed({required String userId}) {
    if (_isBlocking) return; // Prevent further calls if already in progress
    _isBlocking = true; // Set the flag to true
    CustomLoader.show(context!);
    _apiHelper
        .blockUnblockUser(userId: userId, action: 'BLOCK')
        .then((Either<CustomError, UserBlockUnblockResponseModel> responseData) {
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
          Utils.showSnackBar(message: "Failed to report this post. Please try again later.", isTrue: false);
        }
      });
    });
  }

  void paginateTask() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadNextPage();
      }
    });
  }

  void loadNextPage() async {
    currentPage.value++;
    await _getMoreSocialFeeds();
  }

  Future<void> _getMoreSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: Get.find<AppController>().user.value.userId,
                limit: 10,
                page: currentPage.value,
                socialFeedType: SocialFeedType.self));
    socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      moreDataAvailable.value = false;
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        if ((response.socialFeeds?.posts ?? []).isNotEmpty) {
          moreDataAvailable.value = true;
        } else {
          moreDataAvailable.value = false;
        }
        socialPostList.addAll(response.socialFeeds?.posts ?? []);
      }
    });
    socialPostList.refresh();
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
        getSocialFeeds();
        currentPage.value = 1;
         WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0.0);
    });
      }
    });
  }

  Future<void> onRefresh() async {
    socialPostDataLoaded.value = false;
    currentPage.value = 1;
    await getSocialFeeds();
  }
}

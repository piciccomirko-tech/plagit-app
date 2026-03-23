import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:dartz/dartz.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../models/user_profile.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../../../employee/employee_home/models/home_tab_model.dart';
import '../../common_social_feed/controllers/common_social_feed_controller.dart';

class UserProfileController extends GetxController {
  Rx<SocialUser> socialUser = SocialUser().obs;
  String userId = '';
  Rx<Result> employeeFollowers = Result().obs;
  BuildContext? context;

  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();

  Rx<UserModel> employee = UserModel().obs;

  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;
  RxInt socialCurrentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreSocialPostsAvailable = false.obs;
  RxBool loading = false.obs;
  RxBool loadingUserDetails = true.obs;
  RxBool loadingFollowers = true.obs;
  RxBool loadingFollow = false.obs;
  RxBool loadingToggleNotification = false.obs;
  var selectedIndex = 0.obs;
  bool _isReacting = false;
  bool _isBlocking = false;
  // late String individualUserRole;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();

  RxList<HomeTabModel> clientTabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.jobHistory, isSelected: false, hasUpdate: false),
  ].obs;

  RxList<HomeTabModel> candidateTabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.profile, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: false, hasUpdate: false),
  ].obs;

  RxInt selectedTabIndex = 0.obs;
  RxList<Job> myJobPostList = <Job>[].obs;
  RxBool myJobPostDataLoaded = false.obs;
// Pagination Variables
  RxInt myJobCurrentPage = 1.obs;
  final int itemsMyJobPerPage = 6; // Items per page
  RxInt totalMyJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalMyJobPosts = 0.obs; // Total items fetched from the API

  @override
  void onInit() {
    userId = Get.arguments ?? "";
    if (kDebugMode) {
      print("Loading info for $userId");
    }
    _getUserInfo();
    getSocialFeeds();
    getMyJobPosts();
    _getFollowers();
    // individualUserRole = socialUser.value.role ?? 'CLIENT';
    // if (individualUserRole.toLowerCase() == "employee") tabs.removeAt(1);
    super.onInit();
  }

  //Method to load data like init method if the controller is registered
  void onlyLoadData(arguments) {
    socialUser = arguments;
    // individualUserRole = socialUser.value.role ?? 'CLIENT';
    // if (individualUserRole.toLowerCase() == "employee") tabs.removeAt(1);
    _getUserInfo();
    getSocialFeeds();
    getMyJobPosts();
    _getFollowers();
  }

  @override
  void onReady() {
    super.onReady();
    paginateTask();
  }

  Future<void> onBookNowClick() async {
    if (!appController.hasPermission()) return;
    Get.toNamed(Routes.calender,
        arguments: [employee.value.id ?? '', '', null]);
  }

  Future<void> _getFollowers() async {
    loadingFollowers.value = true;
    Either<CustomError, FollowersResponseModel> response =
        await _apiHelper.employeeFollowersDetails(userId);
    loadingFollowers.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (FollowersResponseModel r) {
      if (r.status == "success" && r.statusCode == 200 && r.result != null) {
        employeeFollowers.value = r.result!;
        employeeFollowers.refresh();
      }
    });
  }

  Future<void> _getUserInfo() async {
    loadingUserDetails(true);
    Either<CustomError, UserProfileModel> response =
        await _apiHelper.userProfile(userId);

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (UserProfileModel r) {
      if (r.status == "success" && r.statusCode == 200 && r.details != null) {
        employee.value = r.details!;
        socialUser.value = employeeToSocialUser(r.details!);
        employee.refresh();
      }
    });

    loadingUserDetails(false);
  }

  SocialUser employeeToSocialUser(UserModel employee) {
    return SocialUser(
      id: employee.id,
      name: employee.name ?? employee.restaurantName,
      positionId: employee.positionId,
      positionName: employee.positionName,
      email: employee.email,
      role: employee.role,
      profilePicture: employee.profilePicture,
      countryName: employee.countryName,
    );
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
              _getFollowers();
              appController
                  .setMyFollowingList(response.result!.following ?? []);
              loadingFollow(false);
              appController.isFollowing(userId);
            }
          });
        }
      });
    });
  }

  Future<void> toggleNotification(String id) async {
    if (loadingToggleNotification.value == true) {
      return;
    }
    loadingToggleNotification(true);
    Map<String, dynamic> data = {
      "followUserId": id,
    };

    await _apiHelper.toggleNotification(data).then((response) {
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
              _getFollowers();
              appController
                  .setMyFollowingList(response.result!.following ?? []);
              loadingToggleNotification(false);
              appController.isFollowing(userId);
            }
          });
        }
      });
    });
  }

  void selectCandidateTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < candidateTabs.length; i++) {
      candidateTabs[i].isSelected = i == index;
    }
    candidateTabs.refresh(); // Notify listeners about the update
  }

  void selectClientTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < clientTabs.length; i++) {
      clientTabs[i].isSelected = i == index;
    }
    clientTabs.refresh(); // Notify listeners about the update
  }

  void onJobDetailsClick(
          {required String jobPostId, bool isMyJobPost = false}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);
  void onFullViewClick({required String jobPostId, bool? isMyJobPost}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: {
        "jobPostId": jobPostId,
        'isMyJobPost': isMyJobPost,
      });
  void goToMyJobNextPage() {
    if (myJobCurrentPage.value < totalMyJobPosts.value) {
      myJobCurrentPage.value++;
      getMyJobPosts(
          page: myJobCurrentPage.value); // Load data for the next page
    }
  }

  void goToMyJobPreviousPage() {
    if (myJobCurrentPage.value > 1) {
      myJobCurrentPage.value--;
      getMyJobPosts(
          page: myJobCurrentPage.value); // Load data for the previous page
    }
  }

  void updateTotalMyJobPostPages() {
    totalMyJobPosts.value = (totalMyJobPosts.value / itemsMyJobPerPage).ceil();
  }

  Future<void> getMyJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      myJobPostDataLoaded.value = true;
    } else {
      myJobPostDataLoaded.value = false;
    }
    // log("Fetching My Job Posts for Page: $page"); // Debugging
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
            page: page,
            isMyJobPost:
                false, // Ensure this parameter filters only "my job posts"
            userType: "user_view",
            status: "PUBLISHED", //doesnt matter if isMyJobpost is true
            limit:
                itemsMyJobPerPage, // Adjust to match API's limit parameter if applicable
            jobPostForUserId: userId);
    if (isSocketCall == false) myJobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        myJobPostList.value = response.jobs ?? [];
        totalMyJobPosts.value = response.total ?? 0; // Update total items count
        grossTotalMyJobPosts.value =
            response.total ?? 0; // Update total items count
        updateTotalMyJobPostPages(); // Recalculate total pages
        log("Loaded alt ${response.jobs?.length ?? 0} jobs for page $page"); // Debugging
      } else {
        log("Failed to load alt Job Posts for Page: $page"); // Debugging
      }
    });
    myJobPostList.refresh();
  }

  Future<void> getSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: userId,
                limit: 10,
                page: 1,
                socialFeedType: SocialFeedType.self));
    socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        socialPostList.value = (response.socialFeeds?.posts ?? [])
            .where((post) => post.active == true)
            .toList();
      }
    });
    socialPostList.refresh();
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
    socialCurrentPage.value++;
    await _getMoreSocialFeeds();
  }

  Future<void> _getMoreSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: userId,
                limit: 10,
                page: socialCurrentPage.value,
                socialFeedType: SocialFeedType.self));
    socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      moreSocialPostsAvailable.value = false;
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        if ((response.socialFeeds?.posts ?? []).isNotEmpty) {
          moreSocialPostsAvailable.value = true;
        } else {
          moreSocialPostsAvailable.value = false;
        }
        socialPostList.addAll((response.socialFeeds?.posts ?? [])
            .where((post) => post.active == true)
            .toList());
      }
    });
    socialPostList.refresh();
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
      })?.whenComplete(() =>
              _isReacting = false // Reset the flag after the API call completes
          );
    });
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
    }, (CommonResponseModel response) async {
      if (response.status == "success") {
        getSocialFeeds();
        socialCurrentPage.value = 1;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(0.0);
        });
      }
    });
  }

  void blockUserAndRefreshSocialFeed({required String userId}) {
    if (_isBlocking) return; // Prevent further calls if already in progress
    _isBlocking = true; // Set the flag to true
    CustomLoader.show(context!);
    _apiHelper.blockUnblockUser(userId: userId, action: 'BLOCK').then(
        (Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      getSocialFeeds();
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
}

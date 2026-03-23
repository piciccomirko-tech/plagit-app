import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/custom_menu.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/models/unread_message_response_model.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';
import '../../../../../main.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/create_job_post/models/create_job_post_request_model.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';

class AdminHomeController extends GetxController {
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();
  // final ClientHomePremiumController clientHomePremiumController =
  //     Get.find<ClientHomePremiumController>();
  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  // unread msg track
  RxInt unreadMessageCount = 0.obs;
  RxBool unreadMessageLoading = true.obs;

  RxList<Map<String, dynamic>> employeeChatDetails =
      <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> clientChatDetails = <Map<String, dynamic>>[].obs;
  RxList<String> chatUserIds = <String>[].obs;

  Rx<EmployeeFullDetails> admin = EmployeeFullDetails().obs;
  RxBool adminDataLoading = false.obs;
  RxString socialFeedTitle = MyStrings.socialFeed.tr.obs;
  RxString jobPostsTitle = MyStrings.jobPosts.tr.obs;

  var isNewPostAvailable = false.obs;

  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.jobPosts, isSelected: false, hasUpdate: false),
  ].obs;
  RxInt selectedTabIndex = 0.obs;

  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;
  RxInt socialCurrentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreSocialDataAvailable = true.obs;
  RxBool isLoadingMoreSocialPost = false.obs;

  RxList<Job> jobPostList = <Job>[].obs;
  RxBool jobPostDataLoaded = false.obs;
  RxInt jobCurrentPage = 1.obs;
  RxBool moreJobPostsAvailable = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;
// Pagination Variables for all job posts
  RxInt allJobCurrentPage = 1.obs;
  final int itemsAllJobPerPage = 6; // Items per page
  RxInt totalAllJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalAllJobPosts = 0.obs; // Total items fetched from the API
  @override
  void onInit() async {
    await homeMethods();
    await getAdminJobPosts();
    super.onInit();
  }

  @override
  void onReady() {
    commonSocialFeedController.paginateTask(scrollController);
    super.onReady();
  }

  void onRequestClick() {
    Get.toNamed(Routes.adminClientRequest);
  }

  void onAdminDashboardClick() {
    Get.toNamed(Routes.adminDashboard);
  }

  Future<void> reloadPage(
      {bool needToJumpTop = false, bool fromHome = false}) async {
    socialCurrentPage.value = 1;
    jobCurrentPage.value = 1;
    socialPostDataLoaded.value = false;
    await homeMethods(needToJumpTop: needToJumpTop, fromHome: fromHome);
    await getAdminJobPosts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(0.0);
    });
  }

  Future<void> homeMethods(
      {bool refresh = false,
      bool refreshLoader = false,
      bool needToJumpTop = false,
      bool fromHome = false}) async {
    // isNewPostAvailable(false);
    notificationsController.getNotificationList();
    await _getAdminDetails();
    if (refresh) {
      commonSocialFeedController.currentSocialPage(1);
    }
    commonSocialFeedController.getSocialPost(
        refresh: refresh,
        refreshLoader: refreshLoader,
        needToJumpTop: needToJumpTop,
        fromHome: fromHome);

    await getUnreadMessages();
    if (!refreshLoader && needToJumpTop) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(0.0);
      });
    }
  }

  void getMessages() {
    getUnreadMessages();
    getAdminJobPosts();
    notificationsController.getNotificationList();
  }

  void onJobDetailsClick(
          {required String jobPostId, bool isMyJobPost = false}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);

  void onEditClick({required Job jobRequest}) =>
      Get.toNamed(Routes.createJobPost,
          arguments: CreateJobPostRequestModel(
            id: jobRequest.id ?? "",
            positionId: jobRequest.positionId?.id ?? "",
            clientId: appController.user.value.admin?.id ?? "",
            // minRatePerHour: jobRequest.minRatePerHour ?? 0.0,
            // maxRatePerHour: jobRequest.maxRatePerHour ?? 0.0,
            vacancy: jobRequest.vacancy ?? 0,
            dates: jobRequest.dates ?? [],
            nationalities: jobRequest.nationalities ?? [],
            skills: jobRequest.skills ?? [],
            // minExperience: jobRequest.minExperience ?? 0,
            // maxExperience: jobRequest.maxExperience ?? 0,
            languages: jobRequest.languages ?? [],
            description: jobRequest.description ?? "",
            publishedDate: jobRequest.publishedDate,
            endDate: jobRequest.endDate,
          )
          // minAge: jobRequest.minAge,
          // maxAge: jobRequest.maxAge)
          );

  void onDeleteClick({required String jobId}) async {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: MyStrings.areYouSureDeleteJobRequest.tr,
      confirmButtonText: MyStrings.delete.tr,
      onConfirm: () async {
        Get.back();

        CustomLoader.show(context!);
        Either<CustomError, CommonResponseModel> responseData =
            await _apiHelper.deleteJobPost(jobId: jobId);
        CustomLoader.hide(context!);

        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (CommonResponseModel response) async {
          if (response.status == "success" && response.statusCode == 200) {
            await getAdminJobPosts(isSocketCall: true);
            Utils.showSnackBar(
                message: response.message ??
                    MyStrings.jobRequestDeletedSuccessfully.tr,
                isTrue: true);
          }
        });
      },
    );
  }

  void onTodaysEmployeesPressed() {
    Get.toNamed(Routes.adminTodaysEmployees);
  }

// void getJobPostsPublic({bool isSocketCall=false}){
//   log(" i got:: $isSocketCall");
//   getAdminJobPosts(isSocketCall: isSocketCall);
// }
  void onChatPressed() {
    Get.toNamed(Routes.chatIt);
  }

  Future<void> getUnreadMessages() async {
    unreadMessageLoading.value = true;
    Either<CustomError, UnreadMessageResponseModel> response =
        await _apiHelper.getUnreadMessages();
    unreadMessageLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (UnreadMessageResponseModel response) async {
      if (response.status == "success" && response.statusCode == 200) {
        unreadMessageCount.value = response.unreadConversationsCount ?? 0;
        FlutterAppBadgeControl.isAppBadgeSupported().then((value) {
          FlutterAppBadgeControl.updateBadgeCount(unreadMessageCount.value);
        });
      }
    });
  }

  Future<void> _getAdminDetails() async {
    adminDataLoading.value = true;
    Either<CustomError, EmployeeFullDetails> response = await _apiHelper
        .employeeFullDetails(appController.user.value.employee?.id ?? "");
    adminDataLoading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (r) {
      admin.value = r;
      userProfilePic = admin.value.details?.profilePicture ?? '';
      admin.refresh();
    });
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < tabs.length; i++) {
      tabs[i].isSelected = i == index;
    }
    tabs.refresh(); // Notify listeners about the update
  }

  void onProfileClick() => CustomMenu.accountMenu(context!);

  void onViewDetailsClicked({required String jobPostId, bool? isMyJobPost}) {
    Get.toNamed(Routes.jobPostDetails, arguments: {
      "jobPostId": jobPostId,
      'isMyJobPost': isMyJobPost,
    });
  }
  // Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);

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
    _apiHelper.blockUnblockUser(userId: userId, action: 'BLOCK').then(
        (Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      homeMethods();
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
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      });
    });
  }

  void updateTotalAllJobPostPages() {
    totalAllJobPosts.value =
        (totalAllJobPosts.value / itemsAllJobPerPage).ceil();
  }

  void goToAllJobNextPage() {
    if (allJobCurrentPage.value < totalAllJobPosts.value) {
      allJobCurrentPage.value++;
      getAdminJobPosts(
          page: allJobCurrentPage.value); // Load data for the next page
    }
  }

  void goToAllJobPreviousPage() {
    if (allJobCurrentPage.value > 1) {
      allJobCurrentPage.value--;
      getAdminJobPosts(
          page: allJobCurrentPage.value); // Load data for the previous page
    }
  }

  Future<void> getSocialFeeds({bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      socialPostDataLoaded.value = false;
    } else {
      socialPostDataLoaded.value = true;
    }
    // socialPostDataLoaded.value=false;
    // socialPostList.clear();
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                limit: 10, page: 1, socialFeedType: SocialFeedType.public));
    if (isSocketCall == false) socialPostDataLoaded.value = true;
    // socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        socialPostList.value = response.socialFeeds?.posts ?? [];
      }
    });
    if (isSocketCall == false) socialPostList.refresh();
    //  if (isSocketCall == false) scrollController.jumpTo(0.0);
  }

  void paginateTask() {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent -
                  scrollController.position.pixels <=
              1000 &&
          isLoadingMoreSocialPost.value == false) {
        loadNextPage();
      }
    });
  }

  void loadNextPage() async {
    if (selectedTabIndex.value == 0) {
      socialCurrentPage.value++;
      await _getMoreSocialFeeds();
    }
    //  else {
    //   jobCurrentPage.value++;
    //   await _getMoreJobPosts();
    // }
  }

  Future<void> _getMoreSocialFeeds() async {
    isLoadingMoreSocialPost.value = true;
    moreSocialDataAvailable.value = true;
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                limit: 10,
                page: socialCurrentPage.value,
                socialFeedType: SocialFeedType.public));
    socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      moreSocialDataAvailable.value = false;
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        if ((response.socialFeeds?.posts ?? []).isNotEmpty) {
          moreSocialDataAvailable.value = true;
        } else {
          moreSocialDataAvailable.value = false;
        }
        socialPostList.addAll(response.socialFeeds?.posts ?? []);
      }
    });
    socialPostList.refresh();
    isLoadingMoreSocialPost.value = false;
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
        await getSocialFeeds();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(0.0);
        });
        socialCurrentPage.value = 1;
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

  Future<void> getAdminJobPosts(
      {int page = 1, bool isSocketCall = false}) async {
    log(" is sockettt: $isSocketCall");
    if (isSocketCall == false) {
      jobPostDataLoaded.value = false;
    } else {
      jobPostDataLoaded.value = true;
    }
    Either<CustomError, JobPostRequestModel> responseData = await _apiHelper
        .getJobPosts(page: page, limit: itemsAllJobPerPage, userType: "admin");
    if (isSocketCall == false) jobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        jobPostList.value = response.jobs ?? [];

        totalAllJobPosts.value =
            response.total ?? 0; // Update total items count
        grossTotalAllJobPosts.value =
            response.total ?? 0; // Update total items count that wiont change

        updateTotalAllJobPostPages(); // Recalculate total pages
      }
    });
    jobPostList.refresh();
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
        socialCurrentPage.value = 1;
        await getSocialFeeds();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(0.0);
        });
      }
    });
  }
}

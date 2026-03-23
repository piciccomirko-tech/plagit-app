import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/models/create_job_post_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/main.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../common/cache_service/CacheManager.dart';
import '../../../../common/location_service/location_service.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../models/user_profile_completion_details.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../client_access_control/models/alter_user.dart';
import '../../client_dashboard/controllers/client_dashboard_controller.dart';
import '../../client_home/controllers/client_home_controller.dart';
import '../../mh_employees/controllers/mh_employees_controller.dart';

class ClientHomePremiumController extends GetxController {
  BuildContext? context;

  final NotificationsController notificationsController =
      Get.find<NotificationsController>();
  final ClientDashboardController clientDashboardController =
      Get.put(ClientDashboardController());
  final MhEmployeesController mhEmployeesController =
      Get.put(MhEmployeesController());
  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();

  Rx<EmployeeFullDetails> client = EmployeeFullDetails().obs;
  RxBool clientDataLoading = false.obs;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();
  RxBool isShortListRemove = false.obs;
  RxBool isRequestRemove = false.obs;
  RxList<DropdownItem> positionList = <DropdownItem>[].obs;
  late CarouselSliderController carouselController;

  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.plagIt, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: false, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.jobPosts, isSelected: false, hasUpdate: false),
  ].obs;
  RxInt selectedTabIndex = 0.obs;
  var isNewPostAvailable = false.obs;

  RxList<Job> jobPostList = <Job>[].obs;
  RxBool jobPostDataLoaded = false.obs;

  RxList<Job> myJobPostList = <Job>[].obs;
  RxBool myJobPostDataLoaded = false.obs;
  RxInt jobCurrentPage = 1.obs;
  RxBool moreJobPostsAvailable = false.obs;

// Pagination Variables
  RxInt myJobCurrentPage = 1.obs;
  final int itemsMyJobPerPage = 3; // Items per page
  RxInt totalMyJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalMyJobPosts = 0.obs; // Total items fetched from the API
// Pagination Variables for all job posts
  RxInt allJobCurrentPage = 1.obs;
  final int itemsAllJobPerPage = 6; // Items per page
  RxInt totalAllJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalAllJobPosts = 0.obs; // Total items fetched from the API
//  final SocketController socketController = Get.find<SocketController>();
  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;
  RxInt socialCurrentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreSocialPostsAvailable = true.obs;
  RxBool isLoadingMoreSocialPost = false.obs;

  bool _isReacting = false; // Flag to track the API call state
  bool _isBlocking = false; // Flag to track the API call state
  Rxn<UserProfileCompletionDetails> userProfileCompletionDetails =
      Rxn<UserProfileCompletionDetails>();

  // Add a computed getter to access skillList
  // List<SavedPostModel> get savedPosts => splashController.skillList;

  late TutorialCoachMark tutorialCoachMark;

  final GlobalKey keySearch = GlobalKey();
  final GlobalKey keyNotifications = GlobalKey();
  final GlobalKey keyMessages = GlobalKey();
  final GlobalKey keyDashboard = GlobalKey();
  final GlobalKey keyMyCandidate = GlobalKey();
  final GlobalKey keyPosition = GlobalKey();
  final GlobalKey keySocialPost = GlobalKey();
  final GlobalKey keyJobPost = GlobalKey();
  final GlobalKey keyNearby = GlobalKey();

  final alreadyCreatedTutorial = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    fetchAlterUsers();
    commonSocialFeedController.getSocialPost();

    carouselController = CarouselSliderController();
    getProfileCompletion(appController.user.value.client!.id!);
    _getClientDetails();
    _shufflePositionList();
    getSocialFeeds();
    getMyJobPosts();
    getJobPosts();
    //  _getSocketCheckout();

    isShortListRemove.value = false;
    isRequestRemove.value = false;
    Get.putAsync<LocationService>(() async => LocationService());
    await preCacheImages();
  }

  void fetchAlterUsers() async {
    final response = await _apiHelper.getAlterUsers();

    response.fold((CustomError error) {
      Utils.showSnackBar(message: error.msg, isTrue: false);
    }, (List<AlterUser> users) {
      if (kDebugMode) {
        print('current alter useer length');
        print(users.length);
      }
      if (users
          .any((user) => user.email == appController.currentUserEmail.value)) {
        appController.currentUserIsAlter.value = true;
        if (kDebugMode) {
          print('current user is alter');
        }
      } else {
        appController.currentUserIsAlter.value = false;
        if (kDebugMode) {
          print('current user is main user');
        }
      }
    });
  }

  Future<void> preCacheImages() async {
    try {
      // Show loading indicator or update UI to show caching progress
      // isLoading.value = true;

      // Create a set to store unique URLs and avoid duplicates
      final Set<String> uniqueUrls = {};

      // Collect all unique image URLs from social posts
      for (final post in commonSocialFeedController.socialPostList) {
        // Add media from main post
        if (post.media != null) {
          for (final media in post.media!) {
            if (media.type?.toLowerCase() == 'image' && media.url != null) {
              uniqueUrls.add(media.url!.socialMediaUrl);
            }
            // Also cache thumbnails for videos
            if (media.type?.toLowerCase() == 'video' &&
                media.thumbnail != null) {
              uniqueUrls.add(media.thumbnail!.socialMediaUrl);
            }
          }
        }

        // Add media from reposts if any
        if (post.repost?.media != null) {
          for (final media in post.repost!.media!) {
            if (media.type?.toLowerCase() == 'image' && media.url != null) {
              uniqueUrls.add(media.url!.socialMediaUrl);
            }
            if (media.type?.toLowerCase() == 'video' &&
                media.thumbnail != null) {
              uniqueUrls.add(media.thumbnail!.socialMediaUrl);
            }
          }
        }

        // Cache user profile pictures
        if (post.user?.profilePicture != null &&
            post.user!.profilePicture!.isNotEmpty) {
          uniqueUrls.add(post.user!.profilePicture!.socialMediaUrl);
        }
      }

      // Create a batch of Future downloads
      final List<Future<void>> downloadFutures = uniqueUrls.map((url) async {
        try {
          await CustomCacheManager.instance.downloadFile(
            url,
            key: url.split('/').last, // Use filename as key
          );
          print('Successfully cached: $url');
        } catch (e) {
          print('Error caching $url: $e');
        }
      }).toList();

      // Download in batches to avoid overwhelming the device
      const int batchSize = 5;
      for (var i = 0; i < downloadFutures.length; i += batchSize) {
        final end = (i + batchSize < downloadFutures.length)
            ? i + batchSize
            : downloadFutures.length;
        await Future.wait(downloadFutures.sublist(i, end));
      }

      print('Cached ${uniqueUrls.length} images successfully');
    } catch (e) {
      print('Error in preCacheImages: $e');
    } finally {
      // isLoading.value = false;
    }
  }

  Future<void> getProfileCompletion(String userId) async {
    final result = await _apiHelper.userProfileCompletionDetails(userId);
    // log(" rrrree: ${result.asRight.profileCompleted}");
    result.fold(
      (error) {
        // Handle the error case if needed
        print("Error fetching profile completion details: $error");
      },
      (success) {
        // Set the local variable with the result
        userProfileCompletionDetails.value = success;
        //  log("prof val: ${success.profileCompleted}");
        // Optionally, if using GetX or similar, update the state
        update(); // or notifyListeners() if using Provider
      },
    );
  }

  String getProgressMessage() {
    int amount = userProfileCompletionDetails.value?.profileCompleted ?? 0;
    String msg =
        '$amount% completed! Upadte more profile fields to explore all the features';
    if (amount < 60) {
      msg =
          '$amount% completed! Upadte more profile fields to explore all the features';
    }
    if (amount >= 60 && amount <= 80) {
      msg =
          '$amount% completed!  Upadte more profile fields to explore all the features';
    }
    if (amount > 81 && amount < 85) {
      msg = '$amount% completed! You can complete all the information';
    }
    if (amount > 84) {
      msg = '$amount% completed! All the steps are now done!';
    }
    return msg;
  }

  @override
  void onReady() {
    // _showCheckoutDialog();
    commonSocialFeedController.paginateTask(scrollController);
    getProfileCompletion(appController.user.value.userId);
    super.onReady();
    paginateTask();
  }

  Future<void> onRefresh(
      {bool refresh = false,
      bool refreshLoader = false,
      bool needToJumpTop = false,
      bool fromHome = false}) async {
    // _getClientDetails();
    // if(commonSocialFeedController.isNewPostLoading.value){
    //   isNewPostAvailable(false);
    // }
    commonSocialFeedController.currentSocialPage(1);
    commonSocialFeedController.getSocialPost(
        refresh: refresh,
        refreshLoader: refreshLoader,
        needToJumpTop: needToJumpTop,
        fromHome: fromHome);
    getProfileCompletion(appController.user.value.userId);
    socialPostDataLoaded.value = false;
    getSocialFeeds(needToJump: needToJumpTop);
    myJobCurrentPage.value = 1;
    getMyJobPosts(page: 1);
    getJobPosts();
    socialCurrentPage.value = 1;
    jobCurrentPage.value = 1;
    if (!refreshLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(0.0);
      });
    }
    Get.find<ClientHomeController>().homeMethods();
  }

  Future<void> getPublicClientDetails() async {
    _getClientDetails();
  }

  void _getClientDetails() async {
    clientDataLoading.value = true;
    Either<CustomError, EmployeeFullDetails> response = await _apiHelper
        .employeeFullDetails(appController.user.value.client?.id ?? "");
    clientDataLoading.value = false;
    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (r) {
      client.value = r;
      userProfilePic = client.value.details?.profilePicture ?? '';
      client.refresh();
    });
  }

  void onDashboardClick() {
    Get.toNamed(Routes.clientDashboard);
  }

  void onMyCandidateClick() {
    Get.toNamed(Routes.clientMyEmployee);
  }

  void _shufflePositionList() {
    positionList = appController.allActivePositions;
    //positionList.shuffle();
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < tabs.length; i++) {
      tabs[i].isSelected = i == index;
    }
    tabs.refresh(); // Notify listeners about the update
  }

  Future<void> getMyJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      myJobPostDataLoaded.value = false;
    } else {
      myJobPostDataLoaded.value = true;
    }
    // log("Fetching My Job Posts for Page: $page"); // Debugging
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
      page: page,
      isMyJobPost: true, // Ensure this parameter filters only "my job posts"
      userType: "client",
      status: "PUBLISHED", //doesnt matter if isMyJobpost is true
      limit:
          itemsMyJobPerPage, // Adjust to match API's limit parameter if applicable
    );
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
        log("Loaded ${response.jobs?.length ?? 0} jobs for page $page"); // Debugging
      } else {
        log("Failed to load My Job Posts for Page: $page"); // Debugging
      }
    });
    myJobPostList.refresh();
  }

  void updateTotalMyJobPostPages() {
    totalMyJobPosts.value = (totalMyJobPosts.value / itemsMyJobPerPage).ceil();
  }

  void updateTotalAllJobPostPages() {
    totalAllJobPosts.value =
        (totalAllJobPosts.value / itemsAllJobPerPage).ceil();
  }

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

  void goToAllJobNextPage() {
    if (allJobCurrentPage.value < totalAllJobPosts.value) {
      allJobCurrentPage.value++;
      getJobPosts(page: allJobCurrentPage.value); // Load data for the next page
    }
  }

  void goToAllJobPreviousPage() {
    if (allJobCurrentPage.value > 1) {
      allJobCurrentPage.value--;
      getJobPosts(
          page: allJobCurrentPage.value); // Load data for the previous page
    }
  }

  int get totalPages => (totalMyJobPosts.value / itemsMyJobPerPage).ceil();

  void onFullViewClick({required String jobPostId, bool? isMyJobPost}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: {
        "jobPostId": jobPostId,
        'isMyJobPost': isMyJobPost,
      });

  Future<void> onAccountDeleteClick() async {
    CustomDialogue.confirmation(
      context: context!,
      title: MyStrings.confirmDelete.tr,
      msg: MyStrings.areYouSureDeleteAccount.tr,
      confirmButtonText: MyStrings.delete.tr,
      onConfirm: () async {
        Get.back(); // hide confirmation dialog

        CustomLoader.show(context!);

        // Map<String, dynamic> data = {
        //   "id": appController.user.value.client?.id ?? "",
        //   "active": false,
        //   "deactivatedReason":
        //       "${MyStrings.accountDeactivatedByUser.tr} (${appController.user.value.userId})"
        // };
        Map<String, dynamic> data = {
          "id": appController.user.value.client?.id ?? "",
        };

        // await _apiHelper
        //     .deleteAccountPermanently(appController.user.value.userId)
        //     .then((response) {
        await _apiHelper.deleteAccountSoftly(data).then((response) {
          CustomLoader.hide(context!);

          response.fold((CustomError customError) {
            Utils.errorDialog(
                context!, customError..onRetry = onAccountDeleteClick);
          }, (Response deleteResponse) async {
            if (deleteResponse.statusCode == 200) {
              Utils.showSnackBar(
                  message: "Profile Deleted Successfully", isTrue: true);
              await appController.onLogoutClick();
            } else {
              Utils.showSnackBar(
                  message: "Failed To Deleted Profile", isTrue: true);
            }
          });
        });
      },
    );
  }

  void onJobDetailsClick(
          {required String jobPostId, bool isMyJobPost = false}) =>
      Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);

  void onEditClick({required Job jobRequest}) =>
      Get.toNamed(Routes.createJobPost,
          arguments: CreateJobPostRequestModel(
            id: jobRequest.id ?? "",
            positionId: jobRequest.positionId?.id ?? "",
            clientId: appController.user.value.client?.id ?? "",
            // minRatePerHour: jobRequest.minRatePerHour ?? "0.0",
            // maxRatePerHour: jobRequest.maxRatePerHour ?? "0.0",
            salary: jobRequest.salary ?? '',
            age: jobRequest.age ?? '',
            experience: jobRequest.experience,
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
        }, (CommonResponseModel response) {
          if (response.status == "success" && response.statusCode == 200) {
            getJobPosts();
            getMyJobPosts();
            Utils.showSnackBar(
                message: response.message ??
                    MyStrings.jobRequestDeletedSuccessfully.tr,
                isTrue: true);
          }
        });
      },
    );
  }

  void onPositionClick(DropdownItem position) {
    if (appController.user.value.isGuest) {
      Get.toNamed(Routes.login);
      return;
    }

    Get.toNamed(Routes.mhEmployeesById,
        arguments: {MyStrings.arg.data: position});
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

  void getSocialFeeds(
      {bool isSocketCall = false, bool needToJump = true}) async {
    if (isSocketCall == false) {
      socialPostDataLoaded.value = false;
    } else {
      socialPostDataLoaded.value = true;
    }
    // socialPostDataLoaded.value = false;
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                limit: 10, page: 1, socialFeedType: SocialFeedType.public));
    if (isSocketCall == false) socialPostDataLoaded.value = true;
    // socialPostDataLoaded.value = true;
    getMyFollowingList(isSocketCall: isSocketCall);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (SocialFeedResponseModel response) {
      if (response.status == "success") {
        socialPostList.value = response.socialFeeds?.posts ?? [];
      }
    });
    socialPostList.refresh();
    if (needToJump) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(0.0);
      });
    }
  }

  void getMyFollowingList({bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      socialPostDataLoaded.value = false;
    } else {
      socialPostDataLoaded.value = true;
    }
    Either<CustomError, FollowersResponseModel> responseData = await _apiHelper
        .employeeFollowersDetails(appController.user.value.client!.id!);
    if (isSocketCall == false) socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (FollowersResponseModel response) {
      if (response.status == "success") {
        appController.setMyFollowingList(response.result!.following ?? []);
      }
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
        socialCurrentPage.value = 1;
        getSocialFeeds();
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
    moreSocialPostsAvailable.value = true;
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                limit: 10,
                page: socialCurrentPage.value,
                socialFeedType: SocialFeedType.public));
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
        socialPostList.addAll(response.socialFeeds?.posts ?? []);
      }
    });
    socialPostList.refresh();
    isLoadingMoreSocialPost.value = false;
  }

  Future<void> getJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      jobPostDataLoaded.value = false;
    } else {
      jobPostDataLoaded.value = true;
    }
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
            page: page,
            limit:
                itemsAllJobPerPage, // Adjust to match API's limit parameter if applicable,
            userType: "client",
            isMyJobPost: false);
    if (isSocketCall == false) jobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        jobPostList.value = response.jobs ?? [];

        totalAllJobPosts.value =
            response.total ?? 0; // Update total items count
        grossTotalAllJobPosts.value =
            response.total ?? 0; // Update total items count that won't update

        updateTotalAllJobPostPages(); // Recalculate total pages
      }
    });
    jobPostList.refresh();
  }
}

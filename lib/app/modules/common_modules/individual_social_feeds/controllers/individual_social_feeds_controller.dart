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
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../models/client_edit_profile.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../../../client/create_job_post/models/create_job_post_request_model.dart';
import '../../../employee/employee_home/models/home_tab_model.dart';
import '../../common_social_feed/controllers/common_social_feed_controller.dart';

class IndividualSocialFeedsController extends GetxController {
  late SocialUser socialUser;
  Rx<Result> employeeFollowers = Result().obs;
  BuildContext? context;

  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();

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
  late String individualUserRole;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();

  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.jobHistory, isSelected: false, hasUpdate: false),
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
    socialUser = Get.arguments ?? "";
    if (kDebugMode) {
      print("Loading info for ${socialUser.id}");
    }
    ;
    individualUserRole = socialUser.role ?? 'CLIENT';
    if (individualUserRole.toLowerCase() == "employee") tabs.removeAt(1);
    _getUserInfo();
    getSocialFeeds();
    getMyJobPosts();
    _getFollowers();
    super.onInit();
  }

  //Method to load data like init method if the controller is registered
  void onlyLoadData(arguments) {
    socialUser = arguments;
    individualUserRole = socialUser.role ?? 'CLIENT';
    if (individualUserRole.toLowerCase() == "employee") tabs.removeAt(1);
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

  Future<void> _getFollowers() async {
    loadingFollowers.value = true;
    Either<CustomError, FollowersResponseModel> response =
        await _apiHelper.employeeFollowersDetails(socialUser.id!);
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
    Either<CustomError, ClientEditProfileModel> response =
        await _apiHelper.clientDetails(socialUser.id!);

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (ClientEditProfileModel r) {
      if (r.status == "success" && r.statusCode == 200 && r.details != null) {
        socialUser = employeeToSocialUser(r.details!);
      }
    });

    loadingUserDetails(false);
  }

  SocialUser employeeToSocialUser(UserDetails employee) {
    return SocialUser(
      id: employee.sId,
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
              appController.isFollowing(socialUser.id!);
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
              appController.isFollowing(socialUser.id!);
            }
          });
        }
      });
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
            jobPostForUserId: socialUser.id);
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
                userId: socialUser.id,
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
    moreSocialPostsAvailable.value = true;
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: socialUser.id,
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

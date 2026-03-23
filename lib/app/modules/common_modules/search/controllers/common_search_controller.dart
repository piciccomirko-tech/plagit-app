import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/repost_request_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../models/social_post_report_request_model.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../employee/employee_home/models/common_response_model.dart';
import '../../common_social_feed/controllers/common_social_feed_controller.dart';
import '../models/user_suggestions_model.dart';

class CommonSearchController extends GetxController {
  // Observables
  var isLoading = false.obs;
  var suggestionsList = <UserSuggestionModel>[].obs;
  var jobsList = <Job>[].obs;
  var errorMessage = ''.obs;
  var activeTab = 0.obs; // 0 for Profile, 1 for Jobs, 2 for Feeds
  final ApiHelper _apiHelper = Get.find();
  RxBool showClearIcon = false.obs;
  bool _isReacting = false; // Flag to track the API call state
  bool _isBlocking = false; // Flag to track the API call state
  final ScrollController scrollController = ScrollController();
  final moreSocialDataAvailable = false.obs;
  final isLoadingMoreSocialPost = false.obs;
  final currentSocialPage = 1.obs;
  // Text controller for search input
  TextEditingController searchController = TextEditingController();
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;

  final CommonSocialFeedController commonSocialFeedController =
  Get.find<CommonSocialFeedController>();
  // Function to search profiles
  void searchProfiles() async {
    final searchKey = searchController.text.trim();
    if (searchKey.isEmpty) {
      errorMessage.value = MyStrings.pleaseEnterASearchKey;
      return;
    }


    try {
      isLoading.value = true; // Show loading indicator
      errorMessage.value = ''; // Clear error message
      // Fetch user suggestions using API helper
      final result =
          await _apiHelper.fetchUserSuggestions(searchKey: searchKey);

      result.fold(
        // Handle error case
        (error) {
          suggestionsList.clear();
          isLoading.value = false;
          errorMessage.value = error.msg ?? 'Error fetching data';
        },
        // Handle success case
        (suggestions) {
          suggestionsList.clear();
          isLoading.value = false;
          suggestionsList.addAll(suggestions);
        },
      );
    } catch (e) {
      // Handle unexpected exceptions
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred: $e';
    }
  }

  // Function to search job posts
  void searchJobs() async {
    final searchKey = searchController.text.trim();
    if (searchKey.isEmpty) {
      errorMessage.value = MyStrings.pleaseEnterASearchKey;
      return;
    }

    isLoading.value = true; // Show loading indicator
    errorMessage.value = ''; // Clear error message
    jobsList.clear(); // Clear previous results

    try {
      // Fetch job posts using API helper
      final result = await _apiHelper.searchJobPosts(searchKey: searchKey);

      result.fold(
        // Handle error case
        (error) {
          log(" job error: ${error.msg}");
          isLoading.value = false;
          errorMessage.value = error.msg ?? 'Error fetching job posts';
        },
        // Handle success case
        (jobs) {
          log("job results: ${jobs.length}");
          isLoading.value = false;
          jobsList.addAll(jobs); // Correctly add all jobs to the list
        },
      );
    } catch (e) {
      // Handle unexpected exceptions
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred: $e';
    }
  }
  // Function to search social feed posts
  void searchSocialFeeds() async {
    final searchKey = searchController.text.trim();
    if (searchKey.isEmpty) {
      errorMessage.value = MyStrings.pleaseEnterASearchKey;
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      // Fetch job posts using API helper
      final result = await _apiHelper.searchSocialFeeds(searchKey: searchKey);

      result.fold(
        // Handle error case
        (error) {
          socialPostList.clear();
          log(" social feed error: ${error.msg}");
          isLoading.value = false;
          errorMessage.value = error.msg ?? 'Error fetching social feeds';
        },
        // Handle success case
        (socialFeeds) {
          socialPostList.clear();
          log("social results length: ${socialFeeds.feeds?.length}");
          isLoading.value = false;
        socialPostList.value=socialFeeds.feeds ?? []; // Correctly add all feeds to the list
        },
      );
    } catch (e) {
      // Handle unexpected exceptions
      isLoading.value = false;
      errorMessage.value = 'An unexpected error occurred: $e';
    }
  }

  // Function to set active tab
  void setActiveTab(int index) {
    activeTab.value = index;
    if (index == 0) {
      // Tab is 'Profile', search for profiles
      searchProfiles();
    } else if (index == 1) {
      // Tab is 'Jobs', search for jobs
      searchJobs();
      }
      else if(index==2){
        searchSocialFeeds();
      
    } else {
      // For other tabs (Feeds), show placeholder or error
      errorMessage.value = "This tab is under construction.";
      suggestionsList.clear();
      jobsList.clear();
    }
  }

  //perform search
  void performSearch() {
    if (activeTab.value == 0) {
      searchProfiles();
    } else if (activeTab.value == 1) {
      searchJobs();
    }
    else if (activeTab.value == 2) {
      searchSocialFeeds();
    }
  }

  // Clear search input and reset state
  void clearIconTap() {
    searchController.clear();
    showClearIcon.value = false;
    jobsList.clear();
    suggestionsList.clear();
    Utils.unFocus();
  }
  void addReport(
      {required SocialPostReportRequestModel socialPostReportRequestModel}) {
    _apiHelper
        .addReport(socialPostReportRequestModel: socialPostReportRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        // Utils.errorDialog(context!, customError);
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
    // CustomLoader.show(context!);
    Either<CustomError, CommonResponseModel> responseData = await _apiHelper
        .repostSocialPost(repostRequestModel: repostRequestModel);
    // CustomLoader.hide(context!);
    responseData.fold((CustomError customError) {
      // Utils.errorDialog(context!, customError);
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

  void blockUserAndRefreshSocialFeed({required String userId}) {
    if (_isBlocking) return; // Prevent further calls if already in progress
    _isBlocking = true; // Set the flag to true
    // CustomLoader.show(context!);
    _apiHelper
        .blockUnblockUser(userId: userId, action: 'BLOCK')
        .then((Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      // onRefresh();
      // CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        // Utils.errorDialog(context!, customError);
      }, (UserBlockUnblockResponseModel response) async {
        if (response.statusCode == 200) {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        }
      })?.whenComplete(() {
        _isBlocking = false; // Reset the flag after the API call completes
      });
    });
  }

  void reactPost({required String postId, required int index}) {
    if (_isReacting) return; // Prevent further calls if already in progress
    _isReacting = true; // Set the flag to true
    _apiHelper
        .reactPost(postId: postId)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        // Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status != "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      })?.whenComplete(() {
        // getSocialFeeds();
        _isReacting = false;
      }
      );
    });
  }
  SocialUser clientIdToSocialUser(ClientId clientId) {
    return SocialUser(
      id: clientId.id,
      name: clientId.name ?? clientId.restaurantName,
      positionId: clientId.positionId,
      positionName: clientId.positionName,
      email: clientId.email,
      role: clientId.role,
      profilePicture: clientId.profilePicture,
      countryName: clientId.countryName,
    );
  }

  @override
  void onReady() {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent -
          scrollController.position.pixels <=
          1000 &&
          isLoadingMoreSocialPost.value == false) {
        loadNextPage();
      }
    });
    super.onReady();
  }
  void loadNextPage() async {
    currentSocialPage.value++;
    await _getMoreSocialFeeds();
  }

  Future<void> _getMoreSocialFeeds() async {
    try {
      final searchKey = searchController.text.trim();
      if (searchKey.isEmpty) {
        errorMessage.value = MyStrings.pleaseEnterASearchKey;
        return;
      }
      isLoadingMoreSocialPost(true);
      moreSocialDataAvailable(true);
      final response = await _apiHelper.searchSocialFeeds(searchKey: searchKey,
          page: currentSocialPage.value);
      response.fold(
            (error) {
          log(" social feed error: ${error.msg}");
          isLoading.value = false;
          errorMessage.value = error.msg ?? 'Error fetching social feeds';
        },
            (socialFeeds) {
          log("social results length: ${socialFeeds.feeds?.length}");
          socialPostList.addAll(socialFeeds.feeds ?? []); // Correctly add all feeds to the list
        },
      );
    } catch (error) {
    } finally {
      socialPostList.refresh();
      moreSocialDataAvailable(false);
      isLoadingMoreSocialPost(false);
    }
  }
}

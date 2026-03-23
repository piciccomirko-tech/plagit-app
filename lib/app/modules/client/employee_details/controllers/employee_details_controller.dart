import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/models/followers_response_model.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../common/shortlist_controller.dart';

class EmployeeDetailsController extends GetxController {
  BuildContext? context;
  final AppController _appController = Get.find();

  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();

  final ShortlistController shortlistController = Get.find();
  Rx<Employee> employee = Employee().obs;
  Rx<Result> employeeFollowers = Result().obs;
  RxBool loading = false.obs;
  RxBool loadingFollow = false.obs;
  RxBool loadingToggleNotification = false.obs;
  var selectedIndex = 0.obs;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();
  String employeeId = '';

  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.profile, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: false, hasUpdate: false),
  ].obs;
  RxInt selectedTabIndex = 0.obs;

  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;
  RxInt socialCurrentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreSocialPostsAvailable = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;
  bool isCandidate = true;
  @override
  void onInit() {
    // employeeId = Get.arguments;
    final arguments = Get.arguments as Map<String, dynamic>?;

    employeeId = arguments?['employeeId'] ?? "";
    isCandidate = arguments?['isCandidate'] ?? true;
    _getDetails();
    getSocialFeeds();
    super.onInit();
  }

  //Method to load data like init method if the controller is registered
  void onlyLoadData(arguments) {
    final _arguments = arguments as Map<String, dynamic>?;
    employeeId = _arguments?['employeeId'];
    isCandidate = _arguments?['isCandidate'] ?? true;
    _getDetails();
    getSocialFeeds();
  }

  @override
  void onReady() {
    super.onReady();
    paginateTask();
  }

  Future<void> onBookNowClick() async {
    if (!_appController.hasPermission()) return;
    Get.toNamed(Routes.calender,
        arguments: [employee.value.id ?? '', '', null]);
  }

  // only admin chat with employee
  void onChatClick() {
    /* Get.toNamed(Routes.supportChat, arguments: {
      MyStrings.arg.fromId: _appController.user.value.userId,
      MyStrings.arg.toId: employee.value.id ?? "",
      MyStrings.arg.supportChatDocId: employee.value.id ?? "",
      MyStrings.arg.receiverName: employee.value.firstName ?? "-",
    });*/
  }

  void onViewCalenderClick() => Get.toNamed(Routes.calender,
      arguments: [employee.value.id ?? '', '', null]);

  Future<void> _getDetails() async {
    loading.value = true;
    Either<CustomError, EmployeeFullDetails> response =
        await _apiHelper.employeeFullDetails(employeeId);
    _getFollowers();

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (EmployeeFullDetails r) {
      if (r.status == "success" && r.statusCode == 200 && r.details != null) {
        employee.value = r.details!;
        employee.refresh();
      }
    });
  }

  Future<void> _getFollowers() async {
    loading.value = true;
    Either<CustomError, FollowersResponseModel> response =
        await _apiHelper.employeeFollowersDetails(employeeId);
    loading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (FollowersResponseModel r) {
      if (r.status == "success" && r.statusCode == 200 && r.result != null) {
        employeeFollowers.value = r.result!;
        employeeFollowers.refresh();
      }
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

  Future<void> getSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: employeeId,
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
              appController.isFollowing(employeeId);
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
              appController.isFollowing(employeeId);
            }
          });
        }
      });
    });
  }

  Future<void> _getMoreSocialFeeds() async {
    Either<CustomError, SocialFeedResponseModel> responseData =
        await _apiHelper.getSocialFeeds(
            socialFeedRequestModel: SocialFeedRequestModel(
                userId: employeeId,
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
          socialPostList.addAll((response.socialFeeds?.posts ?? [])
              .where((post) => post.active == true)
              .toList());
        } else {
          moreSocialPostsAvailable.value = false;
        }
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
        // getSocialFeeds();
      })?.whenComplete(() =>
              _isReacting = false // Reset the flag after the API call completes
          );
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
}

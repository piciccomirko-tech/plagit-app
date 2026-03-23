import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_feed_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/models/unread_message_response_model.dart';
import 'package:mh/app/models/user_block_unblock_response_model.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/common_modules/notifications/models/notification_update_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_in_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_out_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_location_update_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/home_tab_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_add_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_plan_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/todays_work_schedule_model.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/check_out_success_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_today_work_schedule_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_todays_dashboard_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/slide_action_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/subscription_widget.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../../main.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/controller/location_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/chat_with_user_choose.dart';
import '../../../../common/widgets/custom_break_time.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/dropdown_item.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../../../../models/followers_response_model.dart';
import '../../../../models/user_profile_completion_details.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../employee_root/controllers/employee_root_controller.dart';
import '../models/today_check_in_out_details.dart';

class EmployeeHomeController extends GetxController {
  final EmployeeRootController employeeRootController =
      Get.find<EmployeeRootController>();
  final CommonSocialFeedController commonSocialFeedController =
      Get.find<CommonSocialFeedController>();
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();
  final SocketController socketController = Get.find<SocketController>();
  // final EmployeeEditProfileController candidateEditProfileController =
  //     Get.put(EmployeeEditProfileController());
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  final GlobalKey<SlideActionWidgetState> key = GlobalKey();

  // done
  RxBool checkIn = false.obs;
  RxBool checkOut = false.obs;

  RxString locationFetchError = "".obs;
  Position? currentLocation;

  Rx<TodayCheckInOutDetails> todayCheckInOutDetails =
      TodayCheckInOutDetails().obs;
  RxBool todayCheckInCheckOutDetailsDataLoading = true.obs;

  // unread msg track
  RxInt unreadMessages = 0.obs;

  RxList<BookingDetailsModel> bookingHistoryList = <BookingDetailsModel>[].obs;
  RxBool bookingHistoryDataLoaded = false.obs;

  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();

  Rx<TodayWorkScheduleModel> todayWorkSchedule = TodayWorkScheduleModel().obs;
  RxBool todayWorkScheduleDataLoading = true.obs;

  RxList<HiredHistoryModel> hiredHistoryList = <HiredHistoryModel>[].obs;
  RxBool hiredHistoryDataLoaded = false.obs;

  RxList<Job> jobPostList = <Job>[].obs;
  RxBool jobPostDataLoaded = false.obs;

  RxList<Job> myJobPostList = <Job>[].obs;
  RxBool myJobPostDataLoaded = false.obs;
// Pagination Variables for all job posts
  RxInt allJobCurrentPage = 1.obs;
  final int itemsAllJobPerPage = 6; // Items per page
  RxInt totalAllJobPosts = 0.obs; // Total items fetched from the API
  RxInt grossTotalAllJobPosts = 0.obs; // Total items fetched from the API
  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.jobPosts, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.socialFeed, isSelected: false, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.history, isSelected: false, hasUpdate: false),
  ].obs;

  RxInt selectedTabIndex = 0.obs;
  var isNewPostAvailable = false.obs;

  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;
  RxBool employeeDataLoading = false.obs;

  Rx<SubscriptionPlanModel> subscriptionPlan = SubscriptionPlanModel().obs;
  RxBool subscriptionPlanDataLoading = false.obs;

  RxList<Widget> employeeTodayList = <Widget>[].obs;

  //Social Feed
  RxList<SocialPostModel> socialPostList = <SocialPostModel>[].obs;
  RxBool socialPostDataLoaded = false.obs;

  RxInt currentSocialPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreSocialDataAvailable = true.obs;
  RxBool isLoadingMoreSocialPost = false.obs;

  RxInt jobCurrentPage = 1.obs;
  RxBool moreJobPostsAvailable = false.obs;

  bool _isReacting = false;
  bool _isBlocking = false;
  TextEditingController tecSearch = TextEditingController();
  RxList<DropdownItem> featureList = <DropdownItem>[].obs;
  RxBool showClearIcon = false.obs;
  String jobPostId = '';
  bool isMyJobPost = false;

  RxBool profileCompletionDataLoaded = false.obs;
  Rxn<UserProfileCompletionDetails> userProfileCompletionDetails =
      Rxn<UserProfileCompletionDetails>();

  //Variable to store time in realtime
  var dailyStatisticsInHour = '00h:00m:00s'.obs;
  Timer? _timer;

  late TutorialCoachMark tutorialCoachMark;
  final GlobalKey keyNotifications = GlobalKey();
  final GlobalKey keyMessages = GlobalKey();
  final GlobalKey keyDashboard = GlobalKey();
  final GlobalKey keyCalender = GlobalKey();

  final alreadyCreatedTutorial = 0.obs;

  @override
  Future<void> onInit() async {
    commonSocialFeedController.getSocialPost();
    getMyFollowingList();
    // jobPostId = Get.arguments['jobPostId'];
    // isMyJobPost = Get.arguments['isMyJobPost']; // Optional parameter
    await getProfileCompletion(appController.user.value.userId);
    getCurrentLocation();
    getSocialFeeds();
    // getMyJobPosts();
    getJobPosts();
    _getEmployeeDetails();
    getUnreadMessages();
    super.onInit();
  }

  //Method for getting updated about working hour in every second
  void _startUpdatingStatistics() {
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      dailyStatisticsInHour.value =
          Utils.checkInOutToStatistics(CheckInCheckOutHistoryElement(
        employeeDetails: todayCheckInOutDetails.value.details?.employeeDetails,
        checkInCheckOutDetails:
            todayCheckInOutDetails.value.details?.checkInCheckOutDetails,
      )).workingHour;
    });
  }

  Future<void> getPublicEmployeeDetails() async {
    _getEmployeeDetails();
  }

  Future<void> getProfileCompletion(String userId) async {
    profileCompletionDataLoaded(false);
    final result = await _apiHelper.userProfileCompletionDetails(userId);

    result.fold(
      (error) {
        // Handle the error case if needed
        if (kDebugMode) {
          print("Error fetching profile completion details: $error");
        }
      },
      (details) {
        // Set the local variable with the result
        userProfileCompletionDetails.value = details;
        log(" emp: ${details.profileCompleted}");
        profileCompletionDataLoaded(true);
        // Optionally, if using GetX or similar, update the state
        // update(); // or notifyListeners() if using Provider
      },
    );
  }

  @override
  void onClose() {
    updateLocation();
    _timer?.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    commonSocialFeedController.paginateTask(scrollController);
    getProfileCompletion(appController.user.value.userId);
    if (appController.user.value.isEmployee &&
        employeeRootController.selectedIndex.value == 0) {
      showHomePopUpForCalender();
    }
    Future.delayed(const Duration(seconds: 2), () => showReviewBottomSheet());
    super.onReady();
  }

  String getProgressMessage() {
    int amount = userProfileCompletionDetails?.value?.profileCompleted ?? 0;
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

  Future<void> onRefresh(
      {bool refresh = false,
      bool refreshLoader = false,
      bool needToJumpTop = false,
      bool fromHome = false}) async {
    // isNewPostAvailable(false);
    commonSocialFeedController.currentSocialPage(1);
    commonSocialFeedController.getSocialPost(
        refresh: refresh,
        refreshLoader: refreshLoader,
        needToJumpTop: needToJumpTop,
        fromHome: fromHome);
    getMyFollowingList();
    getCurrentLocation();
    socialPostDataLoaded.value = false;
    getSocialFeeds(needToJump: needToJumpTop);
    getProfileCompletion(appController.user.value.userId);
    //getMyJobPosts();
    getJobPosts();
    _getEmployeeDetails();
    getUnreadMessages();
    notificationsController.getNotificationList();
    currentSocialPage.value = 1;
    jobCurrentPage.value = 1;
    if (!refreshLoader) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(0.0);
      });
    }
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < tabs.length; i++) {
      tabs[i].isSelected = i == index;
    }
    tabs.refresh(); // Notify listeners about the update
  }

  void homeMethods() async {
    notificationsController.getNotificationList;
    await _getTodayWorkSchedule(DateTime.now().toString().substring(0, 10));
    await _getTodayCheckInOutDetails();
    await getBookingHistory();
    await _getHiredHistory();
  }

  Future<void> getCurrentLocation() async {
    Either<CustomError, Position> response =
        await LocationController.determinePosition();
    response.fold(
      (CustomError error) async {
        locationFetchError.value = error.msg;
        showLocationEnableDialog();
      },
      (Position position) {
        currentLocation = position;
        updateLocation();
        homeMethods();
      },
    );
  }

  void updateTotalAllJobPostPages() {
    totalAllJobPosts.value =
        (totalAllJobPosts.value / itemsAllJobPerPage).ceil();
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

  Future<void> _getTodayWorkSchedule(String time) async {
    Either<CustomError, TodayWorkScheduleModel> responseData =
        await _apiHelper.getTodayWorkSchedule(time);
    todayWorkScheduleDataLoading.value = false;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (TodayWorkScheduleModel todayWorkScheduleInfo) {
      if (todayWorkScheduleInfo.status == 'success' &&
          todayWorkScheduleInfo.todayWorkScheduleDetailsModel != null) {
        todayWorkSchedule.value = todayWorkScheduleInfo;
        todayWorkSchedule.refresh();
        _shareCurrentLocation();
        if (employeeTodayList.isEmpty) {
          employeeTodayList.add(const EmployeeTodayWorkScheduleWidget());
        }
        _startUpdatingStatistics();
      }
    });
  }

  Future<void> _getTodayCheckInOutDetails() async {
    Either<CustomError, TodayCheckInOutDetails> response = await _apiHelper
        .getTodayCheckInOutDetails(appController.user.value.employee?.id ?? '');
    todayCheckInCheckOutDetailsDataLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(
          context!, customError..onRetry = _getTodayCheckInOutDetails);
    }, (TodayCheckInOutDetails details) {
      if (details.status == 'success' && details.details != null) {
        todayCheckInOutDetails.value = details;
        checkOut.value = false;
        checkIn.value = true;
        employeeTodayList.insert(0, const EmployeeTodayDashboardWidget());
      } else if (details.status == 'success' && details.details == null) {
        checkIn.value = false;
        checkOut.value = false;
        if (employeeTodayList.length > 1) {
          employeeTodayList.removeAt(0);
        }
      }
      employeeTodayList.refresh();
    });
  }

  Future<void> getBookingHistory() async {
    Either<CustomError, BookingHistoryModel> responseData =
        await _apiHelper.getBookingHistory();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = getBookingHistory);
    }, (BookingHistoryModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        bookingHistoryList.value = response.bookingDetailsList ?? [];
        bookingHistoryList.refresh();
      }
      bookingHistoryDataLoaded.value = true;
    });
  }

  Future<void> _getHiredHistory() async {
    Either<CustomError, EmployeeHiredHistoryModel> responseData =
        await _apiHelper.getHiredHistory();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = getBookingHistory);
    }, (response) {
      if (response.status == "success" && response.statusCode == 200) {
        hiredHistoryList.value = response.hiredHistory ?? [];
        if (bookingHistoryList.isNotEmpty) {
          tabs[2].hasUpdate = true;
          tabs.refresh();
        } else {
          tabs[2].hasUpdate = false;
          tabs.refresh();
        }
        bookingHistoryList.refresh();
      }
      hiredHistoryDataLoaded.value = true;
      if (showCheckInCheckOutWidget == true &&
          todayWorkSchedule.value.todayWorkScheduleDetailsModel == null) {
        _getTodayWorkSchedule(DateTime.now()
            .subtract(Duration(days: 1))
            .toString()
            .substring(0, 10));
      }
    });
  }

  void onDashboardClick() {
    Get.toNamed(Routes.employeeDashboard);
  }

  void onHelpAndSupportClick() {
    ChatWithUserChoose.show(
      context!,
      msgFromAdmin: 0,
      msgFromClient: 0,
    );
  }

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.employeeProfile);
  }

  UserDailyStatistics get dailyStatistics =>
      Utils.checkInOutToStatistics(CheckInCheckOutHistoryElement(
        employeeDetails: todayCheckInOutDetails.value.details?.employeeDetails,
        checkInCheckOutDetails:
            todayCheckInOutDetails.value.details?.checkInCheckOutDetails,
      ));

  void onCheckInCheckOut() {
    if (!checkIn.value && !checkOut.value) {
      _onCheckIn();
    } else {
      _onCheckout();
    }
  }

  void onBreakTimePickDone(int hour, int min) async {
    if ((hour * 60) + min >
        (int.parse(dailyStatisticsInHour.substring(0, 2)) * 60) +
            int.parse(dailyStatisticsInHour.substring(5, 7))) {
      Utils.showSnackBar(
          message: 'Breaktime should less than working time', isTrue: false);
      return;
    }

    CustomLoader.show(context!);
    EmployeeCheckOutRequestModel employeeCheckOutRequestModel =
        EmployeeCheckOutRequestModel(
            id: todayCheckInOutDetails.value.details?.id ?? '',
            checkOut: true,
            lat: '${currentLocation?.latitude ?? 0.0}',
            long: '${currentLocation?.longitude ?? 0.0}',
            breakTime: (hour * 60) + min,
            checkOutDistance: restaurantDistanceFromEmployee(
                targetLat: double.parse(
                    '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? 0.0}'),
                targetLng: double.parse(
                    '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? 0.0}')),
            checkOutTime: DateTime.now().toLocal().toString());

    Either<CustomError, Response> response = await _apiHelper.checkout(
        employeeCheckOutRequestModel: employeeCheckOutRequestModel);
    CustomLoader.hide(context!);
    response.fold((CustomError customError) {
      CustomDialogue.information(
        context: context!,
        title: MyStrings.failedToCheckout.tr,
        description: customError.msg,
      );
    }, (Response checkoutResponse) {
      _afterCheckInCheckout();
    });
  }

  void _onCheckIn() async {
    CustomLoader.show(context!);

    EmployeeCheckInRequestModel employeeCheckInRequestModel =
        EmployeeCheckInRequestModel(
            employeeId: appController.user.value.employee?.id ?? '',
            bookingId:
                todayWorkSchedule.value.todayWorkScheduleDetailsModel?.id ?? "",
            hiredBy: todayWorkSchedule.value.todayWorkScheduleDetailsModel
                    ?.restaurantDetails?.hiredBy ??
                "",
            checkIn: true,
            lat: '${currentLocation?.latitude ?? 0.0}',
            long: '${currentLocation?.longitude ?? 0.0}',
            checkInDistance: restaurantDistanceFromEmployee(
                targetLat: double.parse(
                    '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? 0.0}'),
                targetLng: double.parse(
                    '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? 0.0}')),
            checkInTime: DateTime.now().toLocal().toString());

    Either<CustomError, CommonResponseModel> response = await _apiHelper
        .checkIn(employeeCheckInRequestModel: employeeCheckInRequestModel);
    CustomLoader.hide(context!);

    response.fold((CustomError customError) {
      CustomDialogue.information(
        context: context!,
        title: MyStrings.failedToCheckIn.tr,
        description: customError.msg,
      );
    }, (CommonResponseModel clients) {
      _afterCheckInCheckout();
    });
  }

  void _onCheckout() {
    CustomBreakTime.show(context!, onBreakTimePickDone);
  }

  void resetSlider() {
    key.currentState?.reset();
  }

  void refreshPage() {
    locationFetchError.value = "";
    todayWorkScheduleDataLoading.value = true;
    todayCheckInCheckOutDetailsDataLoading.value = true;
    checkIn.value = false;
    checkOut.value = false;
    bookingHistoryDataLoaded.value = false;
    hiredHistoryDataLoaded.value = false;

    homeMethods();

    Utils.showSnackBar(message: MyStrings.pageRefreshed.tr, isTrue: true);
  }

  void updateNotification({required String id, required String hiredStatus}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg:
          "${MyStrings.sureWantTo.tr} ${hiredStatus == "ALLOW" ? MyStrings.allow.tr : MyStrings.deny.tr} ${MyStrings.bookingRequest.tr}?",
      confirmButtonText:
          hiredStatus == "ALLOW" ? MyStrings.allow.tr : MyStrings.deny.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context!);
        NotificationUpdateRequestModel notificationUpdateRequestModel =
            NotificationUpdateRequestModel(
                id: id,
                fromWhere: 'employee_home_view',
                hiredStatus: hiredStatus);
        _apiHelper
            .updateNotification(
                notificationUpdateRequestModel: notificationUpdateRequestModel)
            .then((Either<CustomError, NotificationUpdateResponseModel>
                response) {
          CustomLoader.hide(context!);
          Get.back();
          Get.back();
          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (NotificationUpdateResponseModel responseModel) {
            if (responseModel.status == 'success') {
              refreshPage();
            } else {
              Utils.showSnackBar(
                  message: responseModel.message ??
                      'Something wrong, please try again',
                  isTrue: false);
            }
          });
        });
      },
    );
  }

  void onPaymentHistoryClick() {
    Get.toNamed(Routes.employeePaymentHistory);
  }

  void showReviewBottomSheet() {
    _apiHelper
        .showReviewDialog()
        .then((Either<CustomError, ReviewDialogModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry);
      }, (ReviewDialogModel response) {
        if (response.status == "success" &&
            response.statusCode == 200 &&
            response.reviewDialogDetailsModel != null &&
            response.reviewDialogDetailsModel!.isNotEmpty) {
          Get.bottomSheet(RatingReviewWidget(
              reviewFor: 'client',
              onCancelClick: onCancelClick,
              onRatingUpdate: onRatingUpdate,
              onReviewSubmit: onReviewSubmitClick,
              reviewDialogDetailsModel:
                  response.reviewDialogDetailsModel!.first,
              tecReview: tecReview));
        }
      });
    });
  }

  void onReviewSubmitClick({required String id, required String reviewForId}) {
    Get.back();

    CustomLoader.show(context!);

    ReviewRequestModel reviewRequestModel = ReviewRequestModel(
        rating: rating.value,
        reviewForId: reviewForId,
        comment: tecReview.text,
        hiredId: id);

    _apiHelper
        .giveReview(reviewRequestModel: reviewRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 201) {
          tecReview.clear();
          Utils.showSnackBar(message: MyStrings.thanksReview.tr, isTrue: true);
        }
      });
    });
  }

  void onCancelClick(
      {required String id,
      required String reviewForId,
      required double manualRating}) {
    Get.back();

    CustomLoader.show(context!);

    ReviewRequestModel reviewRequestModel = ReviewRequestModel(
        rating: manualRating,
        reviewForId: reviewForId,
        comment: tecReview.text,
        hiredId: id);

    _apiHelper
        .giveReview(reviewRequestModel: reviewRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 201) {
          tecReview.clear();
        }
      });
    });
  }

  void onRatingUpdate(double rat) {
    rating.value = rat;
  }

  void onCalenderClick() => Get.toNamed(Routes.calender,
      arguments: [appController.user.value.employee?.id ?? 0, '', null]);

  void onBookedHistoryClick() {
    Get.toNamed(Routes.employeeBookedHistory);
  }

  void onHiredHistoryClick() {
    Get.toNamed(Routes.employeeHiredHistory);
  }

  void onChatItClick() {
    log("to chatttt");
    Get.toNamed(Routes.chatIt);
  }

  double restaurantDistanceFromEmployee(
      {required double targetLat, required double targetLng}) {
    if (currentLocation != null) {
      return LocationController.calculateDistance(
          targetLat: targetLat,
          targetLong: targetLng,
          currentLat: currentLocation?.latitude ?? 0.0,
          // 23.81183356268996,
          currentLong: currentLocation?.longitude ?? 0.0
          // 90.35531155765057
          );
    }
    return 0.0;
  }

  bool get showCheckInCheckOutWidget {
    final TodayWorkScheduleDetailsModel? todaySchedule =
        todayWorkSchedule.value.todayWorkScheduleDetailsModel;
    final double restaurantLat =
        double.parse(todaySchedule?.restaurantDetails?.lat ?? '0.0');
    final double restaurantLng =
        double.parse(todaySchedule?.restaurantDetails?.long ?? '0.0');

    return !todayWorkScheduleDataLoading.value &&
        (todaySchedule != null || checkIn.value) &&
        locationFetchError.value.isEmpty &&
        (restaurantDistanceFromEmployee(
                    targetLat: restaurantLat, targetLng: restaurantLng) <
                200 ||
            (!todayWorkScheduleDataLoading.value &&
                todaySchedule == null &&
                checkIn.value)) &&
        !todayCheckInCheckOutDetailsDataLoading.value &&
        (checkIn.value == false || checkOut.value == false);
  }

  void _afterCheckInCheckout() async {
    todayWorkScheduleDataLoading.value = true;
    todayCheckInCheckOutDetailsDataLoading.value = true;

    await _getTodayWorkSchedule(DateTime.now().toString().substring(0, 10));
    await _getTodayCheckInOutDetails();

    if (checkIn.value == true && checkOut.value == false) {
      Utils.showSnackBar(
          message: MyStrings.successfullyCheckedIn.tr, isTrue: true);
    } else if (checkOut.value == false && checkIn.value == false) {
      Get.dialog(Dialog(
          backgroundColor: MyColors.lightCard(Get.context!),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: const CheckOutSuccessWidget()));
    }
  }

  void showHomePopUpForCalender() {
    _apiHelper
        .getSkipDate()
        .then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) {
        if (response.status == "success" &&
            response.statusCode == 200 &&
            response.details != null) {
          if (response.details?.skipDate == null ||
              response.details!.skipDate!.isEmpty ||
              response.details?.skipDate?.split('T').first !=
                  DateTime.now().toString().split(" ").first) {
            Get.dialog(
                Dialog(
                  insetPadding: const EdgeInsets.symmetric(
                      horizontal: 0.0, vertical: 0.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.sp),
                    decoration: BoxDecoration(
                        color: MyColors.lightCard(Get.context!),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.asset(MyAssets.lottie.calenderLottie,
                              height: 200.w, width: 200.w),
                          Text(MyStrings.updateCalendar.tr,
                              style: Get.width > 600
                                  ? MyColors.c_C6A34F.semiBold13
                                  : MyColors.c_C6A34F.semiBold18,
                              maxLines: 2),
                          SizedBox(height: 20.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButtons.button(
                                  height: 40.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.0.sp),
                                  margin: EdgeInsets.zero,
                                  text: MyStrings.update.tr,
                                  fontSize: Get.width > 600 ? 10.sp : 16.sp,
                                  onTap: () =>
                                      onCalenderUpdatePressed(tag: 'update'),
                                  customButtonStyle:
                                      CustomButtonStyle.radiusTopBottomCorner),
                              const SizedBox(width: 20),
                              CustomButtons.button(
                                  height: 40.w,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.0.sp),
                                  margin: EdgeInsets.zero,
                                  backgroundColor: Colors.grey.shade400,
                                  text: MyStrings.close.tr,
                                  fontSize: Get.width > 600 ? 10.sp : 16.sp,
                                  onTap: () =>
                                      onCalenderUpdatePressed(tag: 'close'),
                                  customButtonStyle:
                                      CustomButtonStyle.radiusTopBottomCorner),
                            ],
                          ),
                          SizedBox(height: 20.w),
                        ],
                      ),
                    ),
                  ),
                ),
                barrierDismissible: false);
          }
        }
      });
    });
  }

  void onCalenderUpdatePressed({required String tag}) {
    Get.back();
    CustomLoader.show(context!);
    _apiHelper
        .updateSkipDate()
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 200) {
          if (tag == 'update') {
            Get.toNamed(Routes.calender, arguments: [
              appController.user.value.employee?.id ?? 0,
              '',
              null
            ])?.then((value) => null);
          } else {}
        }
      });
    });
  }

  void _shareCurrentLocation() {
    if (todayWorkSchedule.value.todayWorkScheduleDetailsModel != null) {
      Geolocator.getPositionStream().listen((Position position) {
        currentLocation = position;
        if (locationFetchError.value.isEmpty &&
            restaurantDistanceFromEmployee(
                    targetLat: double.parse(todayWorkSchedule
                            .value
                            .todayWorkScheduleDetailsModel
                            ?.restaurantDetails
                            ?.lat ??
                        "0.0"),
                    targetLng: double.parse(todayWorkSchedule
                            .value
                            .todayWorkScheduleDetailsModel
                            ?.restaurantDetails
                            ?.long ??
                        "0.0")) >
                200) {
          sendDataThroughSocket();
        } // Update socket location on each change
      });
    }
  }

  void sendDataThroughSocket() {
    SocketLocationModel socketLocationModel = SocketLocationModel(
      sender: appController.user.value.employee?.id ?? "",
      receiver: todayWorkSchedule.value.todayWorkScheduleDetailsModel
              ?.restaurantDetails?.hiredBy ??
          "",
      cords: Cords(
          latitude: currentLocation?.latitude,
          longitude: currentLocation?.longitude),
    );
    socketController.socket
        ?.emit('location:move', socketLocationModel.toJson());
  }

  Future<void> getMyJobPosts() async {
    myJobPostDataLoaded.value = false;
    Either<CustomError, JobPostRequestModel> responseData = await _apiHelper
        .getJobPosts(userType: 'employee', page: 1, status: "PUBLISHED");
    myJobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        myJobPostList.value = response.jobs ?? [];
        myJobPostList.refresh();
      }
    });
  }

  void onFullViewClick({required String jobPostId, bool? isMyJobPost}) {
    Get.toNamed(Routes.jobPostDetails, arguments: {
      "jobPostId": jobPostId,
      'isMyJobPost': isMyJobPost,
    });
  }
  // Get.toNamed(Routes.jobPostDetails, arguments: jobPostId);

  Future<void> updateLocation() async {
    EmployeeLocationUpdateRequestModel employeeLocationUpdateRequestModel =
        EmployeeLocationUpdateRequestModel(
            id: appController.user.value.employee?.id ?? "",
            lat: (currentLocation?.latitude ?? 0.0).toString(),
            long: (currentLocation?.longitude ?? 0.0).toString());

    await _apiHelper.updateLocation(
        employeeLocationUpdateRequestModel: employeeLocationUpdateRequestModel);
  }

  void showLocationEnableDialog() {
    CustomDialogue.information(
        context: context!,
        title: MyStrings.warning.tr,
        description: MyStrings.enableDeviceLocation.tr,
        onTap: () async {
          await Geolocator.openLocationSettings();
        });
  }

  Future<void> getUnreadMessages() async {
    Either<CustomError, UnreadMessageResponseModel> responseData =
        await _apiHelper.getUnreadMessages();
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (UnreadMessageResponseModel response) {
      if (response.status == "success") {
        unreadMessages.value = response.unreadConversationsCount ?? 0;
        FlutterAppBadgeControl.isAppBadgeSupported().then((value) {
          FlutterAppBadgeControl.updateBadgeCount(unreadMessages.value);
        });
      }
    });
  }

  Future<void> _getEmployeeDetails() async {
    employeeDataLoading.value = true;

    // Keep the current profile picture cached
    String currentProfilePicture = employee.value.details?.profilePicture ?? '';

    Either<CustomError, EmployeeFullDetails> response = await _apiHelper
        .employeeFullDetails(appController.user.value.employee?.id ?? "");

    employeeDataLoading.value = false;

    response.fold(
      (CustomError l) {
        Logcat.msg(l.msg);
      },
      (EmployeeFullDetails r) {
        employee.value = r;
        userProfilePic = employee.value.details?.profilePicture ?? '';
        employee.refresh();
      },
    );
  }

  Future<void> _getEmployeeDetails2() async {
    // candidateEditProfileController.getDetails();
    employeeDataLoading.value = true;
    Either<CustomError, EmployeeFullDetails> response = await _apiHelper
        .employeeFullDetails(appController.user.value.employee?.id ?? "");
    employeeDataLoading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (r) {
      employee.value = r;
      employee.refresh();
    });
  }

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
        //   "id": appController.user.value.employee?.id ?? "",
        //   "active": false,
        //   "deactivatedReason":
        //       "${MyStrings.accountDeactivatedByUser.tr}(${appController.user.value.userId})"
        // };
        Map<String, dynamic> data = {
          "id": appController.user.value.employee?.id ?? "",
        };

        // await _apiHelper.deleteAccountPermanently(appController.user.value.userId).then((response) {
        await _apiHelper.deleteAccountSoftly(data).then((response) {
          CustomLoader.hide(context!);

          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
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

  void checkSubscription() {
    if (_isReacting) return; // Prevent further calls if already in progress
    _isReacting = true;

    CustomLoader.show(context!);
    _apiHelper
        .checkSubscription()
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status == "error") {
          getSubscriptionPlans();
        } else {
          Get.toNamed(Routes.employeePlagitPlus);
        }
      });
    });
  }

  void getSubscriptionPlans() {
    subscriptionPlanDataLoading.value = true;
    _apiHelper.getSubscriptionPlans().then(
        (Either<CustomError, SubscriptionPlanResponseModel> responseData) {
      subscriptionPlanDataLoading.value = false;
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = checkSubscription);
      }, (SubscriptionPlanResponseModel response) async {
        if (response.status == "success") {
          subscriptionPlan.value = (response.result ?? []).first;
          Get.dialog(Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
              child: SubscriptionWidget(
                  onTap: onGetStartedClick,
                  module: 'employee',
                  subscriptionPlan: subscriptionPlan.value)));
          _isReacting = false;
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      });
    });
  }

  void onGetStartedClick() {
    Get.back();
    CustomLoader.show(context!);
    _apiHelper
        .userValidation(
            email: Get.find<AppController>().user.value.client?.email ?? "")
        .then((Either<CustomError, Response> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (Response r) {
        if (r.statusCode == 201) {
          addNewSubscription();
        } else {
          CustomLoader.hide(context!);
          Get.toNamed(Routes.cardAdd, arguments: [
            Get.find<AppController>().user.value.employee?.email,
            'employeeHome'
          ]);
        }
      });
    });
  }

  void addNewSubscription() {
    SubscriptionAddRequestModel subscriptionAddRequestModel =
        SubscriptionAddRequestModel(
            plan: subscriptionPlan.value.id ?? "",
            currency: subscriptionPlan.value.currency ?? "",
            yearlyCharge: Utils.getSubscriptionYearlyCharge(
                subscriptionPlan: subscriptionPlan.value),
            monthlyCharge: Utils.getSubscriptionMonthlyCharge(
                subscriptionPlan: subscriptionPlan.value),
            startDate:
                DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
            endDate: DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime(
                DateTime.now().year + 1,
                DateTime.now().month,
                DateTime.now().day))),
            paymentDate:
                DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now())),
            nextPaymentDate: DateTime.parse(DateFormat('yyyy-MM-dd').format(
                DateTime(DateTime.now().year, DateTime.now().month + 1,
                    DateTime.now().day))));

    CustomLoader.show(context!);
    _apiHelper
        .addNewSubscription(
            subscriptionAddRequestModel: subscriptionAddRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = checkSubscription);
      }, (CommonResponseModel response) async {
        if (response.status == "success") {
          Get.toNamed(Routes.employeePlagitPlus);
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
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
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) async {
        if (response.status != "success") {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
        // getSocialFeeds();
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
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      });
    });
  }

  Future<void> getSocialFeeds(
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
    // getMyFollowingList();
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
        .employeeFollowersDetails(appController.user.value.employee!.id!);
    if (isSocketCall == false) socialPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (FollowersResponseModel response) {
      if (response.status == "success") {
        appController.setMyFollowingList(response.result!.following ?? []);
      }
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
      currentSocialPage.value++;
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
                page: currentSocialPage.value,
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

  Future<void> getJobPosts({int page = 1, bool isSocketCall = false}) async {
    if (isSocketCall == false) {
      jobPostDataLoaded.value = false;
    } else {
      jobPostDataLoaded.value = true;
    }
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobPosts(
      userType: 'employee',
      page: page,
      status: 'PUBLISHED',
      limit: itemsAllJobPerPage,
    );
    if (isSocketCall == false) jobPostDataLoaded.value = true;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        jobPostList.value = response.jobs ?? [];
        totalAllJobPosts.value =
            response.total ?? 0; // Update total items count
        grossTotalAllJobPosts.value =
            response.total ?? 0; // Update total items count that won't change

        updateTotalAllJobPostPages(); // Recalculate total pages
        jobPostList.refresh();
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
        currentSocialPage.value = 1;
        getSocialFeeds();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollController.jumpTo(0.0);
        });
      }
    });
  }

  Future<void> _getMoreJobPosts() async {
    Either<CustomError, JobPostRequestModel> responseData = await _apiHelper
        .getJobPosts(page: jobCurrentPage.value, userType: 'employee');
    jobPostDataLoaded.value = true;
    responseData.fold((CustomError customError) {
      moreJobPostsAvailable.value = false;
    }, (JobPostRequestModel response) {
      if (response.status == "success") {
        if ((response.jobs ?? []).isNotEmpty) {
          moreJobPostsAvailable.value = true;
        } else {
          moreJobPostsAvailable.value = false;
        }
        jobPostList.addAll(response.jobs ?? []);
      }
    });
    jobPostList.refresh();
  }

  void onSearchChanged(String query) {
    featureList.clear();

    if (query.isNotEmpty) {
      showClearIcon.value = true;
      scrollController.animateTo(
        100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      // List:-
      // Dashboard
      // Calendar
      // Jop post
      // Payment
      // Support
      // Booked history
      // Hired history
      // Social feed
      // Use the where method for a concise filtering
      featureList.addAll(appController.employeeSearchList.where(
          (item) => item.name!.toLowerCase().contains(query.toLowerCase())));

      featureList.refresh();
    } else {
      clearIconTap();
    }
  }

  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    featureList.clear();
    Utils.unFocus();
  }

  void onSearchItemTap({required int position}) {
    clearIconTap();
    Get.back();
    switch (position) {
      case 0:
        onDashboardClick();
        break;
      case 1:
        onCalenderClick();
        break;
      case 2:
        employeeRootController.changePage(0);
        selectTab(1);
        break;
      case 3:
        employeeRootController.changePage(2);
        break;
      case 5:
        onBookedHistoryClick();
        break;
      case 6:
        onHiredHistoryClick();
        break;
      case 7:
        employeeRootController.changePage(0);
        selectTab(0);
        break;
      case 8:
        onChatItClick();
        break;
      default:
        employeeRootController.changePage(0);
        selectTab(0);
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_in_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_out_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_location_update_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/todays_work_schedule_model.dart';
import 'package:mh/app/modules/employee/employee_home/views/employee_job_posts_view_all_view.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/check_out_success_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/slide_action_widget.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/live_chat/models/unread_message_response_model.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/notifications/models/notification_response_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_request_model.dart';
import 'package:mh/app/modules/notifications/models/notification_update_response_model.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/controller/location_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/chat_with_user_choose.dart';
import '../../../../common/widgets/custom_break_time.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../models/today_check_in_out_details.dart';

class EmployeeHomeController extends GetxController {
  final NotificationsController notificationsController = Get.find<NotificationsController>();
  final SocketController socketController = Get.find<SocketController>();
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  final GlobalKey<SlideActionWidgetState> key = GlobalKey();

  // done
  RxBool checkIn = false.obs;
  RxBool checkOut = false.obs;

  RxString locationFetchError = "".obs;
  Position? currentLocation;

  Rx<TodayCheckInOutDetails> todayCheckInOutDetails = TodayCheckInOutDetails().obs;
  RxBool todayCheckInCheckOutDetailsDataLoading = true.obs;

  // unread msg track
  RxInt unreadMsgFromClient = 0.obs;
  RxInt unreadMsgFromAdmin = 0.obs;

  RxList<BookingDetailsModel> bookingHistoryList = <BookingDetailsModel>[].obs;
  RxBool bookingHistoryDataLoaded = false.obs;

  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();

  Rx<TodayWorkScheduleModel> todayWorkSchedule = TodayWorkScheduleModel().obs;
  RxBool todayWorkScheduleDataLoading = true.obs;

  RxList<HiredHistoryModel> hiredHistoryList = <HiredHistoryModel>[].obs;
  RxBool hiredHistoryDataLoaded = false.obs;

  Rx<JobPostRequestModel> jobPostRequest = JobPostRequestModel().obs;
  RxBool jobPostDataLoading = false.obs;

  @override
  void onInit() {
    _getCurrentLocation();
    super.onInit();
  }

  @override
  void onClose() {
    updateLocation();
    super.onClose();
  }

  @override
  void onReady() {
    _createConversationForAdmin();
    showHomePopUpForCalender();
    Future.delayed(const Duration(seconds: 2), () => showReviewBottomSheet());
    super.onReady();
  }

  void homeMethods() {
    notificationsController.getNotificationList;
    _getTodayWorkSchedule();
    _getTodayCheckInOutDetails();
    getBookingHistory();
    _getHiredHistory();
    getJobRequests();
  }

  void _getCurrentLocation() async {
    Either<CustomError, Position> response = await LocationController.determinePosition();
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

  Future<void> _getTodayWorkSchedule() async {
    Either<CustomError, TodayWorkScheduleModel> responseData = await _apiHelper.getTodayWorkSchedule();
    todayWorkScheduleDataLoading.value = false;
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _getTodayWorkSchedule);
    }, (TodayWorkScheduleModel todayWorkScheduleInfo) {
      if (todayWorkScheduleInfo.status == 'success' && todayWorkScheduleInfo.todayWorkScheduleDetailsModel != null) {
        todayWorkSchedule.value = todayWorkScheduleInfo;
        todayWorkSchedule.refresh();
        _shareCurrentLocation();
      }
      _createConversationForClient();
    });
  }

  Future<void> _getTodayCheckInOutDetails() async {
    Either<CustomError, TodayCheckInOutDetails> response =
        await _apiHelper.getTodayCheckInOutDetails(appController.user.value.employee?.id ?? '');
    todayCheckInCheckOutDetailsDataLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _getTodayCheckInOutDetails);
    }, (TodayCheckInOutDetails details) {
      if (details.status == 'success' && details.details != null) {
        todayCheckInOutDetails.value = details;
        checkOut.value = false;
        checkIn.value = true;
      } else if (details.status == 'success' && details.details == null) {
        checkIn.value = false;
        checkOut.value = false;
      }
    });
  }

  void getBookingHistory() async {
    Either<CustomError, BookingHistoryModel> responseData = await _apiHelper.getBookingHistory();

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

  void _getHiredHistory() async {
    Either<CustomError, EmployeeHiredHistoryModel> responseData = await _apiHelper.getHiredHistory();

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = getBookingHistory);
    }, (response) {
      if (response.status == "success" && response.statusCode == 200) {
        hiredHistoryList.value = response.hiredHistory ?? [];
        bookingHistoryList.refresh();
      }
      hiredHistoryDataLoaded.value = true;
    });
  }

  void onDashboardClick() {
    Get.toNamed(Routes.employeeDashboard);
  }

  void onHelpAndSupportClick() {
    ChatWithUserChoose.show(
      context!,
      msgFromAdmin: unreadMsgFromAdmin.value,
      msgFromClient: unreadMsgFromClient.value,
    );
  }

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.employeeSelfProfile);
  }

  void chatWithAdmin() {
    Get.back();

    Get.toNamed(Routes.liveChat,
        arguments: LiveChatDataTransferModel(
            toName: "Support",
            toId: appController.user.value.userId,
            toProfilePicture: "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
  }

  void chatWithClient() {
    Get.back(); // hide dialogue

    if (todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
        todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails != null) {
      Get.toNamed(Routes.liveChat,
          arguments: LiveChatDataTransferModel(
              toName: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.restaurantName ?? "",
              toId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
              senderId: appController.user.value.userId,
              bookedId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.id ?? "",
              toProfilePicture:
                  (todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.profilePicture ?? "")
                      .imageUrl));
    } else {
      Utils.showSnackBar(
          message: 'You cannot chat with any restaurant because you have not been hired yet', isTrue: false);
    }
  }

  UserDailyStatistics get dailyStatistics => Utils.checkInOutToStatistics(CheckInCheckOutHistoryElement(
        employeeDetails: todayCheckInOutDetails.value.details?.employeeDetails,
        checkInCheckOutDetails: todayCheckInOutDetails.value.details?.checkInCheckOutDetails,
      ));

  void onCheckInCheckOut() {
    if (!checkIn.value && !checkOut.value) {
      _onCheckIn();
    } else {
      _onCheckout();
    }
  }

  void onBreakTimePickDone(int hour, int min) async {
    CustomLoader.show(context!);
    EmployeeCheckOutRequestModel employeeCheckOutRequestModel = EmployeeCheckOutRequestModel(
        id: todayCheckInOutDetails.value.details?.id ?? '',
        checkOut: true,
        lat: '${currentLocation?.latitude ?? 0.0}',
        long: '${currentLocation?.longitude ?? 0.0}',
        breakTime: (hour * 60) + min,
        checkOutDistance: restaurantDistanceFromEmployee(
            targetLat:
                double.parse('${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? 0.0}'),
            targetLng: double.parse(
                '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? 0.0}')),
        checkOutTime: DateTime.now().toLocal().toString());

    Either<CustomError, Response> response =
        await _apiHelper.checkout(employeeCheckOutRequestModel: employeeCheckOutRequestModel);
    CustomLoader.hide(context!);
    response.fold((CustomError customError) {
      CustomDialogue.information(
        context: context!,
        title: "Failed to Checkout",
        description: customError.msg,
      );
    }, (Response checkoutResponse) {
      _afterCheckInCheckout();
    });
  }

  void _onCheckIn() async {
    CustomLoader.show(context!);

    EmployeeCheckInRequestModel employeeCheckInRequestModel = EmployeeCheckInRequestModel(
        employeeId: appController.user.value.employee?.id ?? '',
        bookingId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.id ?? "",
        hiredBy: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
        checkIn: true,
        lat: '${currentLocation?.latitude ?? 0.0}',
        long: '${currentLocation?.longitude ?? 0.0}',
        checkInDistance: restaurantDistanceFromEmployee(
            targetLat:
                double.parse('${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? 0.0}'),
            targetLng: double.parse(
                '${todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? 0.0}')),
        checkInTime: DateTime.now().toLocal().toString());

    Either<CustomError, CommonResponseModel> response =
        await _apiHelper.checkIn(employeeCheckInRequestModel: employeeCheckInRequestModel);
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
      confirmButtonText: hiredStatus == "ALLOW" ? MyStrings.allow.tr : MyStrings.deny.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context!);
        NotificationUpdateRequestModel notificationUpdateRequestModel =
            NotificationUpdateRequestModel(id: id, fromWhere: 'employee_home_view', hiredStatus: hiredStatus);
        _apiHelper
            .updateNotification(notificationUpdateRequestModel: notificationUpdateRequestModel)
            .then((Either<CustomError, NotificationUpdateResponseModel> response) {
          CustomLoader.hide(context!);
          Get.back();
          Get.back();
          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (NotificationUpdateResponseModel responseModel) {
            if (responseModel.status == 'success') {
              refreshPage();
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
    _apiHelper.showReviewDialog().then((Either<CustomError, ReviewDialogModel> responseData) {
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
              reviewDialogDetailsModel: response.reviewDialogDetailsModel!.first,
              tecReview: tecReview));
        }
      });
    });
  }

  void onReviewSubmitClick({required String id, required String reviewForId}) {
    Get.back();

    CustomLoader.show(context!);

    ReviewRequestModel reviewRequestModel =
        ReviewRequestModel(rating: rating.value, reviewForId: reviewForId, comment: tecReview.text, hiredId: id);

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

  void onCancelClick({required String id, required String reviewForId, required double manualRating}) {
    Get.back();

    CustomLoader.show(context!);

    ReviewRequestModel reviewRequestModel =
        ReviewRequestModel(rating: manualRating, reviewForId: reviewForId, comment: tecReview.text, hiredId: id);

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

  void onCalenderClick() {
    Get.toNamed(Routes.calender, arguments: [appController.user.value.employee?.id ?? 0, '', null]);
  }

  void onBookedHistoryClick() {
    Get.toNamed(Routes.employeeBookedHistory);
  }

  void onHiredHistoryClick() {
    Get.toNamed(Routes.employeeHiredHistory);
  }

  double restaurantDistanceFromEmployee({required double targetLat, required double targetLng}) {
    if (currentLocation != null) {
      return LocationController.calculateDistance(
          targetLat: targetLat,
          targetLong: targetLng,
          currentLat: currentLocation?.latitude ?? 0.0,
          //23.795455885215837,
          currentLong: currentLocation?.longitude ?? 0.0
          //90.40503904223443
          );
    }
    return 0.0;
  }

  bool get showCheckInCheckOutWidget {
    final TodayWorkScheduleDetailsModel? todaySchedule = todayWorkSchedule.value.todayWorkScheduleDetailsModel;
    final double restaurantLat = double.parse(todaySchedule?.restaurantDetails?.lat ?? '0.0');
    final double restaurantLng = double.parse(todaySchedule?.restaurantDetails?.long ?? '0.0');

    return !todayWorkScheduleDataLoading.value &&
        (todaySchedule != null || checkIn.value) &&
        locationFetchError.value.isEmpty &&
        (restaurantDistanceFromEmployee(targetLat: restaurantLat, targetLng: restaurantLng) < 200 ||
            (!todayWorkScheduleDataLoading.value && todaySchedule == null && checkIn.value)) &&
        !todayCheckInCheckOutDetailsDataLoading.value &&
        (checkIn.value == false || checkOut.value == false);
  }

  void _afterCheckInCheckout() async {
    todayWorkScheduleDataLoading.value = true;
    todayCheckInCheckOutDetailsDataLoading.value = true;

    await _getTodayWorkSchedule();
    await _getTodayCheckInOutDetails();

    if (checkIn.value == true && checkOut.value == false) {
      Utils.showSnackBar(message: MyStrings.successfullyCheckedIn.tr, isTrue: true);
    } else if (checkOut.value == false && checkIn.value == false) {
      Get.dialog(Dialog(
          backgroundColor: MyColors.lightCard(Get.context!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: const CheckOutSuccessWidget()));
    }
  }

  void showHomePopUpForCalender() {
    _apiHelper.getSkipDate().then((Either<CustomError, CommonResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.details != null) {
          if (response.details?.skipDate == null ||
              response.details!.skipDate!.isEmpty ||
              response.details?.skipDate?.split('T').first != DateTime.now().toString().split(" ").first) {
            Get.dialog(
                Dialog(
                  insetPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                  child: Container(
                    height: 370,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration:
                        BoxDecoration(color: MyColors.lightCard(context!), borderRadius: BorderRadius.circular(10.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(MyAssets.lottie.calenderLottie, height: 220, width: 220),
                        Text(MyStrings.updateCalendar.tr, style: MyColors.c_C6A34F.semiBold18, maxLines: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButtons.button(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                margin: EdgeInsets.zero,
                                text: MyStrings.update.tr,
                                onTap: () => onCalenderUpdatePressed(tag: 'update'),
                                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                            const SizedBox(width: 20),
                            CustomButtons.button(
                                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                margin: EdgeInsets.zero,
                                backgroundColor: Colors.grey.shade400,
                                text: MyStrings.close.tr,
                                onTap: () => onCalenderUpdatePressed(tag: 'close'),
                                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                          ],
                        )
                      ],
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
    CustomLoader.show(context!);
    _apiHelper.updateSkipDate().then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel response) {
        if (response.status == "success" && response.statusCode == 200) {
          if (tag == 'update') {
            Get.toNamed(Routes.calender, arguments: [appController.user.value.employee?.id ?? 0, '', null])
                ?.then((value) => Get.back());
          } else {
            Get.back();
          }
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
                    targetLat: double.parse(
                        todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? "0.0"),
                    targetLng: double.parse(
                        todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? "0.0")) >
                200) {
          sendDataThroughSocket();
        } // Update socket location on each change
      });
    }
  }

  void sendDataThroughSocket() {
    SocketLocationModel socketLocationModel = SocketLocationModel(
      sender: appController.user.value.employee?.id ?? "",
      receiver: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
      cords: Cords(latitude: currentLocation?.latitude, longitude: currentLocation?.longitude),
    );
    socketController.socket?.emit('location:move', socketLocationModel.toJson());
  }

  void getJobRequests() async {
    jobPostDataLoading.value = true;
    Either<CustomError, JobPostRequestModel> responseData = await _apiHelper.getJobRequests(status: "PUBLISHED");
    jobPostDataLoading.value = false;

    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = getJobRequests);
    }, (JobPostRequestModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        jobPostRequest.value = response;
        jobPostRequest.refresh();
      }
    });
  }

  void onFullViewClick({required Job jobPostDetails}) =>
      Get.toNamed(Routes.employeeJobPostDetails, arguments: jobPostDetails);

  void onViewAllClick() => Get.to(() => EmployeeJobPostsViewAllView(jobPostList: (jobPostRequest.value.jobs ?? [])));

  void updateLocation() async {
    EmployeeLocationUpdateRequestModel employeeLocationUpdateRequestModel = EmployeeLocationUpdateRequestModel(
        id: appController.user.value.employee?.id ?? "",
        lat: (currentLocation?.latitude ?? 0.0).toString(),
        long: (currentLocation?.longitude ?? 0.0).toString());

    await _apiHelper.updateLocation(employeeLocationUpdateRequestModel: employeeLocationUpdateRequestModel);
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

  void _createConversationForAdmin() {
    ConversationCreateRequestModel conversationCreateRequestModel =
        ConversationCreateRequestModel(isAdmin: true, senderId: appController.user.value.userId);

    _apiHelper
        .createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ConversationResponseModel response) {
        if (response.status == "success" && response.statusCode == 201 && response.details != null) {
          _getUnreadMessageForAdmin(conversationId: response.details?.id ?? "");
        }
      });
    });
  }

  void _getUnreadMessageForAdmin({required String conversationId}) {
    _apiHelper
        .getUnreadMessage(conversationId: conversationId)
        .then((Either<CustomError, UnreadMessageResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (UnreadMessageResponseModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.details != null) {
          unreadMsgFromAdmin.value = response.details?.count ?? 0;
        }
      });
    });
  }

  void _createConversationForClient() {
    if (todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
        todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails != null) {
      ConversationCreateRequestModel conversationCreateRequestModel;
      conversationCreateRequestModel = ConversationCreateRequestModel(
          senderId: appController.user.value.userId,
          receiverId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
          bookedId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.id ?? "");

      _apiHelper
          .createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
          .then((Either<CustomError, ConversationResponseModel> responseData) {
        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (ConversationResponseModel response) {
          if (response.status == "success" && response.statusCode == 201 && response.details != null) {
            _getUnreadMessageForClient(conversationId: response.details?.id ?? "");
          }
        });
      });
    }
  }

  void _getUnreadMessageForClient({required String conversationId}) {
    _apiHelper
        .getUnreadMessage(conversationId: conversationId)
        .then((Either<CustomError, UnreadMessageResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (UnreadMessageResponseModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.details != null) {
          unreadMsgFromClient.value = response.details?.count ?? 0;
        }
      });
    });
  }
}

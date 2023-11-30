import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_in_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_check_out_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/employee_hired_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/todays_work_schedule_model.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/check_out_success_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/slide_action_widget.dart';
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
  @override
  void onInit() async {
    await homeMethods();
    super.onInit();
  }

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 1), () => showHomePopUpForCalender());
    Future.delayed(const Duration(seconds: 3), () => showReviewBottomSheet());
    super.onReady();
  }

  Future<void> homeMethods() async {
    notificationsController.getNotificationList;
    await _getCurrentLocation();
    await _getTodayWorkSchedule();
    await _getTodayCheckInOutDetails();
    await getBookingHistory();
    await _getHiredHistory();
    _trackUnreadMsg();
  }

  Future<void> _getCurrentLocation() async {
    Either<CustomError, Position> response = await LocationController.determinePosition();
    response.fold((l) {
      locationFetchError.value = l.msg;
    }, (Position position) {
      currentLocation = position;
    });
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
      }
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

  Future<void> getBookingHistory() async {
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

  Future<void> _getHiredHistory() async {
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
    Get.toNamed(Routes.employeeSelfProfile);
  }

  void chatWithAdmin() {
    Get.back(); // hide dialogue

    Get.toNamed(Routes.supportChat, arguments: {
      MyStrings.arg.fromId: appController.user.value.userId,
      MyStrings.arg.toId: "allAdmin",
      MyStrings.arg.supportChatDocId: appController.user.value.userId,
      MyStrings.arg.receiverName: "Support",
    });
  }

  void chatWithClient() {
    Get.back(); // hide dialogue

    if (todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
        todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails != null) {
      Get.toNamed(Routes.clientEmployeeChat, arguments: {
        MyStrings.arg.receiverName:
            todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.restaurantName ?? "-",
        MyStrings.arg.fromId: appController.user.value.employee?.id ?? "",
        MyStrings.arg.toId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
        MyStrings.arg.clientId: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? "",
        MyStrings.arg.employeeId: appController.user.value.employee?.id ?? "",
      });
    } else {
      Utils.showSnackBar(
          message: 'You cannot chat with any restaurant because you have not been hired yet', isTrue: false);
    }
  }

  UserDailyStatistics get dailyStatistics => Utils.checkInOutToStatistics(CheckInCheckOutHistoryElement(
        employeeDetails: todayCheckInOutDetails.value.details?.employeeDetails,
        checkInCheckOutDetails: todayCheckInOutDetails.value.details?.checkInCheckOutDetails,
      ));

  Future<void> onCheckInCheckOut() async {
    if (!checkIn.value && !checkOut.value) {
      await _onCheckIn();
    } else {
      _onCheckout();
    }
  }

  Future<void> onBreakTimePickDone(int hour, int min) async {
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

  Future<void> _onCheckIn() async {
    CustomLoader.show(context!);

    EmployeeCheckInRequestModel employeeCheckInRequestModel = EmployeeCheckInRequestModel(
        employeeId: appController.user.value.employee?.id ?? '',
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
        title: "Failed to CheckIn",
        description: customError.msg,
      );
    }, (CommonResponseModel clients) async {
      await _afterCheckInCheckout();
    });
  }

  void _onCheckout() {
    CustomBreakTime.show(context!, onBreakTimePickDone);
  }

  void resetSlider() {
    key.currentState?.reset();
  }

  void refreshPage() async {
    locationFetchError.value = "";
    todayWorkScheduleDataLoading.value = true;
    todayCheckInCheckOutDetailsDataLoading.value = true;
    checkIn.value = false;
    checkOut.value = false;
    bookingHistoryDataLoaded.value = false;
    hiredHistoryDataLoaded.value = false;

    await homeMethods();

    Utils.showSnackBar(message: 'This page has been refreshed', isTrue: true);
  }

  void _trackUnreadMsg() {
    try {
      if (todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
          todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails != null) {
        FirebaseFirestore.instance
            .collection('employee_client_chat')
            .where("employeeId", isEqualTo: appController.user.value.employee?.id ?? '')
            .where("clientId",
            isEqualTo: todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.hiredBy ?? '')
            .snapshots()
            .listen((QuerySnapshot<Map<String, dynamic>> event) {
          if (event.docs.isNotEmpty) {
            Map<String, dynamic> data = event.docs.first.data();
            unreadMsgFromClient.value = data["${appController.user.value.employee?.id ?? ''}_unread"];
          }
        });
      }

      FirebaseFirestore.instance
          .collection('support_chat')
          .doc(appController.user.value.userId)
          .snapshots()
          .listen((event) {
        if (event.exists) {
          Map<String, dynamic> data = event.data()!;
          unreadMsgFromAdmin.value = data["${appController.user.value.userId}_unread"];
        }
      });
    } catch (_) {}
  }

  void updateNotification({required String id, required String hiredStatus}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: "Confirm?",
      msg: "Are you sure you want to $hiredStatus this booking request?",
      confirmButtonText: hiredStatus,
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
          Utils.showSnackBar(message: 'Thanks for your review...', isTrue: true);
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
          currentLat: currentLocation!.latitude,
          //23.795455885215837,
          currentLong: currentLocation!.longitude
          //90.40503904223443
          );
    }
    return 0.0;
  }

  bool get showCheckInCheckOutWidget {
    return todayWorkScheduleDataLoading.value == false &&
        todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
        locationFetchError.value.isEmpty &&
        restaurantDistanceFromEmployee(
                targetLat: double.parse(
                    todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? '0.0'),
                targetLng: double.parse(
                    todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? '0.0')) <
            200 &&
        todayCheckInCheckOutDetailsDataLoading.value == false &&
        (checkIn.value == false || checkOut.value == false);
  }

  bool get showEmergencyCheckInCheckOut {
    return todayWorkSchedule.value.todayWorkScheduleDetailsModel != null &&
        restaurantDistanceFromEmployee(
                targetLat: double.parse(
                    todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.lat ?? '0.0'),
                targetLng: double.parse(
                    todayWorkSchedule.value.todayWorkScheduleDetailsModel?.restaurantDetails?.long ?? '0.0')) >
            200 &&
        checkIn.value == false;
  }

  Future<void> _afterCheckInCheckout() async {
    todayWorkScheduleDataLoading.value = true;
    todayCheckInCheckOutDetailsDataLoading.value = true;

    await _getTodayWorkSchedule();
    await _getTodayCheckInOutDetails();

    if (checkIn.value == true && checkOut.value == false) {
      Utils.showSnackBar(message: 'You have successfully checkedIn', isTrue: true);
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
        Utils.errorDialog(context!, customError..onRetry);
      }, (CommonResponseModel response) {
        if (response.status == "success" &&
            response.statusCode == 200 &&
            response.details != null &&
            response.details?.skipDate != null &&
            response.details!.skipDate!.isNotEmpty &&
            response.details?.skipDate?.split('T').first != DateTime.now().toString().split(" ").first) {
          Get.dialog(Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            child: Container(
              height: 350,
              decoration: BoxDecoration(color: MyColors.lightCard(context!), borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(MyAssets.lottie.calenderLottie),
                  Text('PLEASE UPDATE YOUR CALENDER', style: MyColors.c_C6A34F.semiBold18),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButtons.button(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          margin: EdgeInsets.zero,
                          text: "Update",
                          onTap: () => onCalenderUpdatePressed(tag: 'update'),
                          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                      const SizedBox(width: 20),
                      CustomButtons.button(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          margin: EdgeInsets.zero,
                          backgroundColor: Colors.grey.shade400,
                          text: 'Close',
                          onTap: () => onCalenderUpdatePressed(tag: 'close'),
                          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner),
                    ],
                  )
                ],
              ),
            ),
          ));
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
}

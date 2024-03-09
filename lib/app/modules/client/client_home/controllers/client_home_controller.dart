import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/client_help_option.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/requested_employees.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../common/shortlist_controller.dart';

class ClientHomeController extends GetxController {
  final NotificationsController notificationsController = Get.find<NotificationsController>();
  BuildContext? context;
  final AppController appController = Get.find();
  final ShortlistController shortlistController = Get.find();
  final ApiHelper _apiHelper = Get.find();
  Rx<RequestedEmployees> requestedEmployees = RequestedEmployees().obs;
  RxBool isLoading = true.obs;
  // unread msg track
  RxInt unreadMsgFromEmployee = 0.obs;
  RxInt unreadMsgFromAdmin = 0.obs;
  RxList<Map<String, dynamic>> employeeChatDetails = <Map<String, dynamic>>[].obs;
  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();
  TextEditingController tecSearch = TextEditingController();
  ScrollController scrollController = ScrollController();
  RxList<DropdownItem> positionList = <DropdownItem>[].obs;
  RxBool showClearIcon = false.obs;

  Rx<JobPostRequestModel> jobPostRequest = JobPostRequestModel().obs;
  RxBool jobPostDataLoading = false.obs;

  Rx<CheckInCheckOutHistory> clientPaymentInvoice = CheckInCheckOutHistory().obs;

  @override
  void onInit() {
    homeMethods();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
    tecReview.dispose();
  }

  @override
  void onReady() {
    Future.delayed(const Duration(seconds: 2), () => showReviewBottomSheet());
    super.onReady();
  }

  void onMhEmployeeClick() {
    Get.toNamed(Routes.mhEmployees);
  }

  void onDashboardClick() {
    Get.toNamed(Routes.clientDashboard);
  }

  void onMyEmployeeClick() {
    Get.toNamed(Routes.clientMyEmployee);
  }

  void onInvoiceAndPaymentClick() {
    Get.toNamed(Routes.clientPaymentAndInvoice);
  }

  void onCreateJobPostClick() => Get.toNamed(Routes.createJobPost);

  void onJobRequestsClick() => Get.toNamed(Routes.jobRequests);

  void onHelpAndSupportClick() {
    ClientHelpOption.show(
      context!,
      msgFromAdmin: unreadMsgFromAdmin.value,
    );
  }

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.clientSelfProfile);
  }

  void onSettingsClick() {
    Get.back();
    Get.toNamed(Routes.settings);
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

  void requestEmployees() {
    Get.back(); // hide dialogue

    Get.toNamed(Routes.clientRequestForEmployee);
  }

  void onShortlistClick() {
    Get.toNamed(Routes.clientShortlisted);
  }

  void onSuggestedEmployeesClick() {
    Get.toNamed(Routes.clientSuggestedEmployees);
  }

  void getJobRequests() async {
    jobPostDataLoading.value = true;
    Either<CustomError, JobPostRequestModel> responseData =
        await _apiHelper.getJobRequests(userType: "CLIENT", clientId: appController.user.value.client?.id ?? "");
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

  void fetchRequestEmployees() {
    _apiHelper.getRequestedEmployees(clientId: appController.user.value.userId).then((response) {
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = onAccountDeleteClick);
      }, (RequestedEmployees requestedEmployees) async {
        this.requestedEmployees.value = requestedEmployees;
        this.requestedEmployees.refresh();
      });
    });
  }

  int countTotalRequestedEmployees() {
    int total = 0;

    for (RequestedEmployeeModel element in requestedEmployees.value.requestEmployeeList ?? []) {
      total += (element.clientRequestDetails ?? [])
          .fold(0, (previousValue, element) => previousValue + (element.numOfEmployee ?? 0));
    }

    return total;
  }

  int countSuggestedEmployees() {
    int total = 0;

    for (RequestedEmployeeModel element in requestedEmployees.value.requestEmployeeList ?? []) {
      total += (element.suggestedEmployeeDetails ?? []).length;
    }

    return total;
  }

  Future<void> onAccountDeleteClick() async {
    CustomDialogue.confirmation(
      context: context!,
      title: "Confirm Delete",
      msg:
          "Are you sure you want to delete account? \n\n Once you delete your account you can't access and you lost all of your data",
      confirmButtonText: "Delete",
      onConfirm: () async {
        Get.back(); // hide confirmation dialog

        CustomLoader.show(context!);

        Map<String, dynamic> data = {
          "id": appController.user.value.userId,
          "active": false,
          "deactivatedReason": "Account deactivate by user(${appController.user.value.userId})"
        };

        await _apiHelper.deleteAccount(data).then((response) {
          CustomLoader.hide(context!);

          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError..onRetry = onAccountDeleteClick);
          }, (Response deleteResponse) async {
            appController.onLogoutClick();
          });
        });
      },
    );
  }

  void _trackUnreadMsg() {
    // employee massage
    FirebaseFirestore.instance
        .collection('employee_client_chat')
        .where("clientId", isEqualTo: appController.user.value.userId)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> event) {
      unreadMsgFromEmployee.value = 0;
      employeeChatDetails.clear();

      for (QueryDocumentSnapshot<Map<String, dynamic>> element in event.docs) {
        Map<String, dynamic> data = element.data();
        unreadMsgFromEmployee.value += data["${appController.user.value.userId}_unread"] == null
            ? 0
            : int.parse(data["${appController.user.value.userId}_unread"].toString());
        employeeChatDetails.add(data);
      }

      employeeChatDetails.refresh();
    });

    // admin massage
    FirebaseFirestore.instance
        .collection("support_chat")
        .doc(appController.user.value.userId)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> event) {
      if (event.exists) {
        Map<String, dynamic> data = event.data()!;
        unreadMsgFromAdmin.value = data["${appController.user.value.userId}_unread"];
      }
    });
  }

  void homeMethods() {
    notificationsController.getNotificationList();
    _clientPaymentInvoice();
    _trackUnreadMsg();
    fetchRequestEmployees();
    getJobRequests();
  }

  void refreshPage() {
    homeMethods();
    Utils.showSnackBar(message: MyStrings.pageRefreshed.tr, isTrue: true);
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
                  reviewFor: 'employee',
                  onCancelClick: onCancelClick,
                  onRatingUpdate: onRatingUpdate,
                  onReviewSubmit: onReviewSubmitClick,
                  reviewDialogDetailsModel: response.reviewDialogDetailsModel!.first,
                  tecReview: tecReview)
              //reviewDialogWidget(reviewDialogDetails: response.reviewDialogDetailsModel!.first)
              );
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

  void onSearchChanged(String query) {
    positionList.clear();

    if (query.isNotEmpty) {
      showClearIcon.value = true;
      scrollController.animateTo(
        100,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // Use the where method for a concise filtering
      positionList.addAll(
          appController.allActivePositions.where((item) => item.name!.toLowerCase().contains(query.toLowerCase())));

      positionList.refresh();
    } else {
      clearIconTap();
    }
  }

  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    positionList.clear();
    Utils.unFocus();
  }

  void onSearchItemTap({required DropdownItem position}) {
    clearIconTap();
    Get.toNamed(Routes.mhEmployeesById, arguments: {MyStrings.arg.data: position});
  }

  Future<void> _clientPaymentInvoice() async {
    isLoading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response = await _apiHelper.getCheckInOutHistory(
      clientId: appController.user.value.userId,
    );
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _clientPaymentInvoice);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      clientPaymentInvoice.value = checkInCheckOutHistory;
    });
  }
}

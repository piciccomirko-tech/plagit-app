import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_menu.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/admin/admin_home/models/unread_message_response_model_for_admin.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/live_chat/models/unread_message_response_model.dart';
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
  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();
  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;

  ScrollController scrollController = ScrollController();
  RxList<DropdownItem> positionList = <DropdownItem>[].obs;

  Rx<JobPostRequestModel> jobPostRequest = JobPostRequestModel().obs;
  RxBool jobPostDataLoading = false.obs;

  Rx<CheckInCheckOutHistory> clientPaymentInvoice = CheckInCheckOutHistory().obs;

  RxInt unreadMessageFromAdmin = 0.obs;
  RxInt unreadMessageFromEmployee = 0.obs;
  RxBool unreadMessageFromEmployeeLoading = true.obs;

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

  void onProfileTapped({required BuildContext context}) {
    CustomMenu.accountMenu(
      context,
      onSettingsTap: onSettingsClick,
      onProfileTap: onProfileClick,
    );
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
      msgFromAdmin: unreadMessageFromAdmin.value,
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
    Get.back();

    Get.toNamed(Routes.liveChat,
        arguments: LiveChatDataTransferModel(
            toName: "Support",
            toId: appController.user.value.userId,
            toProfilePicture: "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
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
        Utils.errorDialog(context!, customError);
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

  void homeMethods() {
    clientPaymentInvoiceMethod();
    fetchRequestEmployees();
    getJobRequests();
    getMessages();
  }

  void getMessages() {
    _getUnreadMessageFromEmployee();
    _createConversation();
    notificationsController.getNotificationList();
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

  Future<void> clientPaymentInvoiceMethod() async {
    isLoading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response = await _apiHelper.getCheckInOutHistory(
      clientId: appController.user.value.userId,
    );
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      clientPaymentInvoice.value = checkInCheckOutHistory;
    });
  }

  void _createConversation() {
    ConversationCreateRequestModel conversationCreateRequestModel =
        ConversationCreateRequestModel(isAdmin: true, senderId: appController.user.value.userId);

    _apiHelper
        .createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ConversationResponseModel response) {
        if (response.status == "success" && response.statusCode == 201 && response.details != null) {
          _getUnreadMessage(conversationId: response.details?.id ?? "");
        }
      });
    });
  }

  void _getUnreadMessage({required String conversationId}) {
    _apiHelper
        .getUnreadMessage(conversationId: conversationId)
        .then((Either<CustomError, UnreadMessageResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (UnreadMessageResponseModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.details != null) {
          unreadMessageFromAdmin.value = response.details?.count ?? 0;
        }
      });
    });
  }

  Future<void> _getUnreadMessageFromEmployee() async {
    unreadMessageFromEmployeeLoading.value = true;
    Either<CustomError, UnreadMessageResponseModelForAdmin> response = await _apiHelper.getUnreadMessageForClient();
    unreadMessageFromEmployeeLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (UnreadMessageResponseModelForAdmin response) async {
      if (response.status == "success" && response.statusCode == 200) {
        unreadMessageFromEmployee.value = response.unreadMsg ?? 0;
      }
    });
  }
}

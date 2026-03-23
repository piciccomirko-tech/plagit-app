import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/widgets/custom_menu.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/models/unread_message_response_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/common_modules/notifications/controllers/notifications_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_dialog_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/review_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_add_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/subscription_plan_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/subscription_widget.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/requested_employees.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../employee/employee_home/models/booking_history_model.dart';
import '../../common/shortlist_controller.dart';

class ClientHomeController extends GetxController {
  final NotificationsController notificationsController =
      Get.find<NotificationsController>();

  BuildContext? context;
  final ShortlistController shortlistController = Get.find();
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();
  Rx<RequestedEmployees> requestedEmployees = RequestedEmployees().obs;
  RxBool isLoading = true.obs;

  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();
  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;

  ScrollController scrollController = ScrollController();
  RxList<DropdownItem> positionList = <DropdownItem>[].obs;

  Rx<CheckInCheckOutHistory> clientPaymentInvoice =
      CheckInCheckOutHistory().obs;

  RxInt unreadMessages = 0.obs;
  RxBool unreadMessagesDataLoading = false.obs;
  Rx<SubscriptionPlanModel> subscriptionPlan = SubscriptionPlanModel().obs;
  RxBool subscriptionPlanDataLoading = false.obs;

  // final ClientEditProfileController clientEditProfileController =
  // Get.put(ClientEditProfileController());

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
    Get.toNamed(Routes.clientPaymentAndInvoice, arguments: "clientHome");
  }

  void onCreateJobPostClick() => Get.toNamed(Routes.createJobPost);

  void onJobRequestsClick() => Get.toNamed(Routes.jobRequests);

  void onPlagItPlusClick() => checkSubscription();

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.clientEditProfile);
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
            toId: appController.user.value.client?.id ?? "",
            toProfilePicture:
                "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
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

  void fetchRequestEmployees() {
    _apiHelper
        .getRequestedEmployees(
            clientId: appController.user.value.client?.id ?? "")
        .then((response) {
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (RequestedEmployees requestedEmployees) async {
        this.requestedEmployees.value = requestedEmployees;
        this.requestedEmployees.refresh();
      });
    });
  }

//  void deleteReqFromClient({required String requestId}) {
//     CustomDialogue.confirmation(
//       context: context!,
//       title: MyStrings.confirmCancellation.tr ,
//       msg: MyStrings.areYouSureCancelRequest.tr,
//       confirmButtonText: MyStrings.yes.toUpperCase().tr,
//       onConfirm: () async {
//         Get.back(); // hide confirmation dialog

//         CustomLoader.show(context!);

//         await _apiHelper
//             .cancelClientRequestFromAdmin(requestId: requestId)
//             .then((response) {
//           CustomLoader.hide(context!);

//           response.fold((CustomError customError) {
//             Utils.errorDialog(context!, customError);
//           }, (BookingHistoryModel response) async {
//             if ((response.statusCode == 200 || response.statusCode == 201) &&
//                 response.status == 'success') {
//               fetchRequestEmployees();
//             }
//           });
//         });
//       },
//     );
//   }
  Future<void> deleteAllRequestsFromClient() async {
    if ((requestedEmployees.value.requestEmployeeList ?? []).isEmpty) {
      CustomDialogue.information(
        context: context!,
        title: "Info",
        description: "No Request found",
      );
      return;
    }

    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirmCancellation.tr,
      msg: "Do you want to cancel all the requests(your)?",
      confirmButtonText: MyStrings.yes.toUpperCase().tr,
      onConfirm: () async {
        Get.back(); // Close the dialog

        CustomLoader.show(Get.context!);

        // Get all request IDs
  
        for (int i = 0;
            i < (requestedEmployees.value.requestEmployeeList ?? []).length;
            i++) {
          var rid = requestedEmployees.value.requestEmployeeList![i].id;

          await _apiHelper
              .cancelClientRequestFromAdmin(requestId: rid!)
              .then((response) {
            response.fold((CustomError customError) {
              Logcat.msg(customError.msg); // Log error and continue
            }, (BookingHistoryModel result) {
             
              log("req result: ${result.message}");
              if (result.statusCode == 200 || result.statusCode == 201) {
                 Utils.showSnackBar(message:"Request ${rid} deleted successfully." ,isTrue:true);
                Logcat.msg("Request ${rid} deleted successfully.");
              }
            });
          });
        }

        // Refresh data after deletions
        CustomLoader.hide(Get.context!);
        fetchRequestEmployees();

        CustomDialogue.information(
          context: Get.context!,
          title: MyStrings.success.tr,
          description:
              "All of your requests for the employee have been deleted",
        );
      },
    );
  }

  int countTotalRequestedEmployees() {
    int total = 0;

    for (RequestedEmployeeModel element
        in requestedEmployees.value.requestEmployeeList ?? []) {
      total += (element.clientRequestDetails ?? []).fold(
          0,
          (previousValue, element) =>
              previousValue + (element.numOfEmployee ?? 0));
    }

    return total;
  }

  int countSuggestedEmployees() {
    int total = 0;

    for (RequestedEmployeeModel element
        in requestedEmployees.value.requestEmployeeList ?? []) {
      total += (element.suggestedEmployeeDetails ?? []).length;
    }

    return total;
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

        Map<String, dynamic> data = {
          "id": appController.user.value.client?.id ?? "",
          "active": false,
          "deactivatedReason":
              "${MyStrings.accountDeactivatedByUser.tr} (${appController.user.value.userId})"
        };

        await _apiHelper.deleteAccount(data).then((response) {
          CustomLoader.hide(context!);

          response.fold((CustomError customError) {
            Utils.errorDialog(
                context!, customError..onRetry = onAccountDeleteClick);
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
    shortlistController.fetchShortListEmployees();
    getMessages();
  }

  void getMessages() {
    _getUnreadMessages();
    notificationsController.getNotificationList();
  }

  void refreshPage() {
    homeMethods();

    Utils.showSnackBar(message: MyStrings.pageRefreshed.tr, isTrue: true);
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
              reviewFor: 'employee',
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

    CustomLoader.show(Get.context!);

    ReviewRequestModel reviewRequestModel = ReviewRequestModel(
        rating: rating.value,
        reviewForId: reviewForId,
        comment: tecReview.text,
        hiredId: id);

    _apiHelper
        .giveReview(reviewRequestModel: reviewRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(Get.context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError);
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

    CustomLoader.show(Get.context!);

    ReviewRequestModel reviewRequestModel = ReviewRequestModel(
        rating: manualRating,
        reviewForId: reviewForId,
        comment: tecReview.text,
        hiredId: id);

    _apiHelper
        .giveReview(reviewRequestModel: reviewRequestModel)
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(Get.context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError);
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
      positionList.addAll(appController.allActivePositions.where(
          (item) => item.name!.toLowerCase().contains(query.toLowerCase())));

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
    Get.toNamed(Routes.mhEmployeesById,
        arguments: {MyStrings.arg.data: position});
  }

  Future<void> clientPaymentInvoiceMethod() async {
    isLoading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getCheckInOutHistory(
      clientId: appController.user.value.client?.id ?? "",
    );
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      clientPaymentInvoice.value = checkInCheckOutHistory;
    });
  }

  Future<void> _getUnreadMessages() async {
    unreadMessagesDataLoading.value = true;
    Either<CustomError, UnreadMessageResponseModel> response =
        await _apiHelper.getUnreadMessages();
    unreadMessagesDataLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (UnreadMessageResponseModel response) async {
      if (response.status == "success") {
        unreadMessages.value = response.unreadConversationsCount ?? 0;
      }
    });
  }

  void checkSubscription() {
    CustomLoader.show(context!);
    _apiHelper
        .checkSubscription()
        .then((Either<CustomError, CommonResponseModel> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = checkSubscription);
      }, (CommonResponseModel response) async {
        if (response.status == "error") {
          getSubscriptionPlans();
        } else {
          Get.toNamed(Routes.clientPremiumRoot);
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
              insetPadding: const EdgeInsets.symmetric(horizontal: 22),
              child: SubscriptionWidget(
                  onTap: onGetStartedClick,
                  module: 'employee',
                  subscriptionPlan: subscriptionPlan.value)));
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
            Get.find<AppController>().user.value.client?.email,
            'clientHome'
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
          Get.toNamed(Routes.clientPremiumRoot);
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        } else {
          Utils.showSnackBar(message: response.message ?? "", isTrue: false);
        }
      });
    });
  }
}

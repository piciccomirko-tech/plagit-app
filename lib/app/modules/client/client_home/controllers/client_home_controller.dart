import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/rating_review_widget.dart';
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
import '../../client_payment_and_invoice/model/client_invoice_model.dart';
import '../../common/shortlist_controller.dart';

class ClientHomeController extends GetxController {
  final NotificationsController notificationsController = Get.find<NotificationsController>();
  BuildContext? context;

  final AppController appController = Get.find();
  final ShortlistController shortlistController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  Rx<RequestedEmployees> requestedEmployees = RequestedEmployees().obs;

  Rx<ClientInvoiceModel> clientInvoice = ClientInvoiceModel().obs;
  RxBool isLoading = true.obs;

  // unread msg track
  RxInt unreadMsgFromEmployee = 0.obs;
  RxInt unreadMsgFromAdmin = 0.obs;

  RxList<Map<String, dynamic>> employeeChatDetails = <Map<String, dynamic>>[].obs;

  RxDouble rating = 0.0.obs;
  TextEditingController tecReview = TextEditingController();
  @override
  void onInit() {
    homeMethods();
    super.onInit();
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

  void onHelpAndSupportClick() {
    ClientHelpOption.show(
      context!,
      msgFromAdmin: unreadMsgFromAdmin.value,
    );
  }

  void onProfileClick() {
    Get.toNamed(Routes.clientSelfProfile);
  }

  void onSettingsClick() {
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

  Future<void> getClientInvoice() async {
    isLoading.value = true;

    await _apiHelper
        .getClientInvoice(appController.user.value.userId)
        .then((Either<CustomError, ClientInvoiceModel> response) {
      isLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = getClientInvoice);
      }, (ClientInvoiceModel clientInvoice) {
        this.clientInvoice.value = clientInvoice;
        this.clientInvoice.refresh();
      });
    });
  }

  void homeMethods() {
    notificationsController.getNotificationList();
    getClientInvoice();
    _trackUnreadMsg();
    fetchRequestEmployees();
  }

  void refreshPage() {
    homeMethods();
    Utils.showSnackBar(message: 'This page has been refreshed...', isTrue: true);
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

}

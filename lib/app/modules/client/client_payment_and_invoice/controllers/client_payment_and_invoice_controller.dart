import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/break_time_picker_widget.dart';
import 'package:mh/app/common/widgets/timer_wheel_for24_h_widget.dart';
import 'package:mh/app/models/check_in_check_out_details.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_bank_info_model.dart';
import 'package:mh/domain/model/payment_model.dart';
import 'package:mh/domain/repositories/payment_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../employee/employee_home/models/home_tab_model.dart';
import '../model/client_subscription_invoice_details_response_model.dart';
import '../model/client_subscription_list_response_model.dart';

class ClientPaymentAndInvoiceController extends GetxController {
  ClientPaymentAndInvoiceController({
    required this.paymentRepository,
  });
  final PaymentRepository paymentRepository;
  
  File? invoiceFile;
  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();
  String companyName = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<DateTime> dashboardDate = DateTime.now().obs;

  Rx<ClientUpdateStatusModel> clientUpdateStatusModel =
      ClientUpdateStatusModel().obs;
  TextEditingController tecComment = TextEditingController();

  Rx<CheckInCheckOutHistory> clientPaymentInvoice =
      CheckInCheckOutHistory().obs;

  RxList<PaymentResult> paymentList = <PaymentResult>[].obs;

  RxBool isLoading = false.obs;
  RxBool isLoadingSubscriptionInvoice = false.obs;
  RxBool isLoadingSubscriptionInvoiceDetails = false.obs;
  RxInt pageSize = 10.obs;
  RxInt currentPage = 1.obs;
  final isLoadingMoreData = false.obs;
  RxBool stopScrolling = false.obs;
  RxList<HomeTabModel> tabs = <HomeTabModel>[
    HomeTabModel(
        titleKey: MyStrings.paymentHistory, isSelected: true, hasUpdate: false),
    HomeTabModel(
        titleKey: MyStrings.subscriptionPaymentHistory, isSelected: false, hasUpdate: false),
  ].obs;
  RxInt selectedTabIndex = 0.obs;

  final cslrm= ClientSubscriptionListResponseModel().obs;
  ClientSubscriptionListResponseModel get clientSubscriptions => cslrm.value;

  final subcdetails= ClientSubscriptionInvoiceDetailsResponseModel().obs;
  ClientSubscriptionInvoiceDetailsResponseModel get clientSubscriptionsDetails => subcdetails.value;

  @override
  void onInit() {
    clientPaymentInvoiceDetails();
    clientSubscriptionPaymentInvoiceDetails();
    // clientPaymentInvoiceMethod();
    getBankInfo();
    super.onInit();
  }

  void selectTab(int index) {
    selectedTabIndex.value = index;
    // Unselect all tabs
    for (int i = 0; i < tabs.length; i++) {
      tabs[i].isSelected = i == index;
    }
    tabs.refresh(); // Notify listeners about the update
  }

  Future<void> clientPaymentInvoiceDetails() async {
    isLoading.value = true;

    final response = await paymentRepository.getPaymentDetails();

    isLoading.value = false;

    if (response?.status != 'success') {
      throw Exception('Failed to get social feed posts ');
    } else {
      paymentList.value = response?.results ?? [];
      debugPrint('Payment Length ${paymentList.length}');
    }
  }

  Future<void> clientPaymentInvoiceMethod() async {
    isLoading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getCheckInOutHistory(
      clientId: appController.user.value.client?.id ?? "",
    );
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(Get.context!, customError);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      clientPaymentInvoice.value = checkInCheckOutHistory;
    });
  }

  Future<void> clientSubscriptionPaymentInvoiceDetails() async {
    isLoadingSubscriptionInvoice.value = true;
    Either<CustomError, ClientSubscriptionListResponseModel> response =
        await _apiHelper.getSubscriptionInvoices(
    );
    isLoadingSubscriptionInvoice.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(Get.context!, customError);
    }, (ClientSubscriptionListResponseModel checkInCheckOutHistory) async {
      cslrm.value = checkInCheckOutHistory;
    });
  }

  Future<void> getSubscriptionPaymentDetails({required String id}) async {
    isLoadingSubscriptionInvoiceDetails.value = true;
    Either<CustomError, ClientSubscriptionInvoiceDetailsResponseModel> response =
        await _apiHelper.getSubscriptionInvoicesDetails(id:id);
    isLoadingSubscriptionInvoiceDetails.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(Get.context!, customError);
    }, (ClientSubscriptionInvoiceDetailsResponseModel checkInCheckOutHistory) async {
      subcdetails.value = checkInCheckOutHistory;
    });
  }

  Future<void> payToEmployeeByClient(Map<String, dynamic> data) async {
    isLoading.value = true;
    Either<CustomError, Response> response =
        await _apiHelper.updateEmployeePaymentByClient(data);
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(Get.context!, customError);
    }, (Response apiResponse) async {
      // clientPaymentInvoice.value = checkInCheckOutHistory;
      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        Utils.showSnackBar(message: 'Paid successfully', isTrue: true);
      } else {
        Utils.showSnackBar(message: 'Failed to pay', isTrue: false);
      }
    });
  }

  void onViewInvoicePress({required PaymentResult invoice}) async {
    if (invoice.paymentStatus != 'PAID' || invoice.paymentStatus == null) {
      Utils.showSnackBar(message: MyStrings.foundNothing.tr, isTrue: false);
    } else {
      onDownloadPressed(invoice.invoiceUrl??'');
    }
    print(invoice.invoiceUrl);
  }
  void onDownloadPressed(String invoiceDownloadLink) async {
    try {
      Uri url = Uri.parse(invoiceDownloadLink);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (_) {}
  }

  void getBankInfo() {
    _apiHelper
        .getBankInfo()
        .then((Either<CustomError, ClientBankInfoModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError..onRetry);
      }, (ClientBankInfoModel response) {
        if (response.status == "success" &&
            response.statusCode == 200 &&
            response.details != null) {
          companyName = response.details?.companyName ?? '';
        }
      });
    });
  }

  bool clientCommentEnable(int index) {
    CheckInCheckOutHistoryElement? element =
        clientPaymentInvoice.value.checkInCheckOutHistory![index];

    if (element.checkInCheckOutDetails != null) {
      CheckInCheckOutDetails? check = element.checkInCheckOutDetails;
      clientUpdateStatusModel.value = ClientUpdateStatusModel(
          clientCheckInTime:
              (check?.clientCheckInTime ?? check?.checkInTime ?? '').toString(),
          clientCheckOutTime:
              (check?.clientCheckOutTime ?? check?.checkOutTime ?? '')
                  .toString(),
          clientBreakTime:
              check?.clientBreakTime == null || check?.clientBreakTime == 0
                  ? check?.breakTime
                  : check?.clientBreakTime);
      tecComment.text = element.checkInCheckOutDetails?.clientComment ?? '';
      clientUpdateStatusModel.refresh();

      // checkout is 24h ago
      if ((element.checkInCheckOutDetails?.checkOutTime != null) &&
          DateTime.now()
                  .difference(
                      element.checkInCheckOutDetails!.checkOutTime!.toLocal())
                  .inHours >
              1) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckOutTime != null) &&
          DateTime.now()
                  .difference(element
                      .checkInCheckOutDetails!.clientCheckOutTime!
                      .toLocal())
                  .inHours >
              1) {
        return false;
      }
      // check in 24h ago (forgot checkout)
      else if ((element.checkInCheckOutDetails?.checkInTime != null) &&
          DateTime.now()
                  .difference(
                      element.checkInCheckOutDetails!.checkInTime!.toLocal())
                  .inHours >
              1) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckInTime != null) &&
          DateTime.now()
                  .difference(element.checkInCheckOutDetails!.clientCheckInTime!
                      .toLocal())
                  .inHours >
              1) {
        return false;
      }
    }

    return true;
  }

  Future<void> onUpdatePressed(int index) async {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      CheckInCheckOutHistoryElement element =
          clientPaymentInvoice.value.checkInCheckOutHistory![index];

      clientUpdateStatusModel.value.id = clientPaymentInvoice
              .value.checkInCheckOutHistory?[index].currentHiredEmployeeId ??
          '';
      clientUpdateStatusModel.value.checkIn =
          element.checkInCheckOutDetails?.checkIn ?? false;
      clientUpdateStatusModel.value.checkOut =
          element.checkInCheckOutDetails?.checkOut ?? false;
      clientUpdateStatusModel.value.clientComment = tecComment.text;

      CustomLoader.show(Get.context!);
      await _apiHelper
          .updateCheckInOutByClient(
              clientUpdateStatusModel: clientUpdateStatusModel.value)
          .then((Either<CustomError, Response> response) {
        CustomLoader.hide(Get.context!);

        response.fold((CustomError customError) {
          Utils.errorDialog(Get.context!, customError);
        }, (result) {
          Get.back(); // hide dialog

          if ([200, 201].contains(result.statusCode)) {
            //clientPaymentInvoiceMethod();
            clientPaymentInvoiceDetails();
          }
        });
      });
    }
  }

  String getComment(int index) {
    CheckInCheckOutDetails? check = clientPaymentInvoice
        .value.checkInCheckOutHistory?[index].checkInCheckOutDetails;
    return check?.clientComment ?? '';
  }

  void onClockPressed({required int index, required String tag}) {
    Get.dialog(Dialog(
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            borderRadius: BorderRadius.circular(5.0)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TimerWheel24HWidget(
                height: 250,
                width: 300,
                centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                initialTime: DateTime.parse(tag == 'checkIn'
                    ? (clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.clientCheckInTime ??
                            clientPaymentInvoice
                                .value
                                .checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails
                                ?.checkInTime)
                        .toString()
                    : (clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.clientCheckOutTime ??
                            clientPaymentInvoice
                                .value
                                .checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails
                                ?.checkOutTime)
                        .toString()),
                onTimeChanged: (String time) {
                  if (tag == "checkIn") {
                    clientUpdateStatusModel.value.clientCheckInTime =
                        "${dashboardDate.value.toString().split(" ").first} $time";
                  } else {
                    clientUpdateStatusModel.value.clientCheckOutTime =
                        "${dashboardDate.value.toString().split(" ").first} $time";
                  }
                  clientUpdateStatusModel.refresh();
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          backgroundColor: MyColors.c_C6A34F,
                        ),
                        onPressed: () => Get.back(),
                        child: Text(MyStrings.ok.tr,
                            style: MyColors.white.semiBold16)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    ));
  }

  void onBreakTimeChange(int totalMinutes) {
    clientUpdateStatusModel.value.clientBreakTime = totalMinutes;
    clientUpdateStatusModel.refresh();
  }

  void onBreakTimePressed() {
    Get.dialog(Dialog(
      child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: MyColors.lightCard(Get.context!)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              BreakTimePickerWidget(onBreakTimeChanged: onBreakTimeChange),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          backgroundColor: MyColors.c_C6A34F,
                        ),
                        onPressed: () => Get.back(),
                        child: Text(MyStrings.ok.tr,
                            style: MyColors.white.semiBold16)),
                  )
                ],
              )
            ],
          )),
    ));
  }

  void loadMoreData() async {
    debugPrint('apiiii');
    if (stopScrolling.value == false) {
      if (isLoadingMoreData.value == true) {
        return;
      } else {
        currentPage.value++;
        isLoadingMoreData(true);
        Future.delayed(Duration(seconds: 10));
        isLoadingMoreData(false);
        // Either<CustomError, CheckInCheckOutHistory> response =
        // await _apiHelper.getEmployeeCheckInOutHistory(
        //     limit: pageSize.value, page: currentPage.value);
        //
        // isLoadingMoreData(false);
        // response.fold((CustomError customError) {
        //   // Utils.errorDialog(
        //   //     context!, customError..onRetry = _fetchCheckInOutHistory);
        // }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
        //   if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).isNotEmpty) {
        //     if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).length <
        //         pageSize.value) {
        //       stopScrolling.value = true;
        //     }
        //     // history.addAll(checkInCheckOutHistory.checkInCheckOutHistory ?? []);
        //     // history.refresh();
        //   } else {
        //     stopScrolling.value = true;
        //   }
        // });
      }
    }
  }
}

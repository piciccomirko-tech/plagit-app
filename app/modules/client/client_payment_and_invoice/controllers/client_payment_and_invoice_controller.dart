import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/break_time_picker_widget.dart';
import 'package:mh/app/common/widgets/timer_wheel_for24_h_widget.dart';
import 'package:mh/app/models/check_in_check_out_details.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_bank_info_model.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../client_home/controllers/client_home_controller.dart';

class ClientPaymentAndInvoiceController extends GetxController {
  BuildContext? context;
  File? invoiceFile;
  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();
  ClientHomeController clientHomeController = Get.find();
  String companyName = '';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Rx<DateTime> dashboardDate = DateTime.now().obs;

  Rx<ClientUpdateStatusModel> clientUpdateStatusModel = ClientUpdateStatusModel().obs;
  TextEditingController tecComment = TextEditingController();

  @override
  void onInit() {
    getBankInfo();
    super.onInit();
  }

  void onViewInvoicePress({required CheckInCheckOutHistoryElement invoice}) async {
    /*if ((Get.find<AppController>().user.value.client?.countryName?.toLowerCase() ?? '') == 'united kingdom') {
      invoiceFile = await Utils.generatePdfWithImageAndTextForUk(invoice: invoice, companyName: companyName);
    } else {
      invoiceFile = await Utils.generatePdfWithImageAndText(invoice: invoice);
    }*/
    invoiceFile = await Utils.generatePdfWithImageAndText(invoice: invoice, companyName: companyName);
    Get.toNamed(Routes.invoicePdf, arguments: [invoiceFile]);
  }

  void getBankInfo() {
    _apiHelper.getBankInfo().then((Either<CustomError, ClientBankInfoModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry);
      }, (ClientBankInfoModel response) {
        if (response.status == "success" && response.statusCode == 200 && response.details != null) {
          companyName = response.details?.companyName ?? '';
        }
      });
    });
  }

  bool clientCommentEnable(int index) {
    CheckInCheckOutHistoryElement? element =
        clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory![index];

    if (element.checkInCheckOutDetails != null) {
      CheckInCheckOutDetails? check = element.checkInCheckOutDetails;
      clientUpdateStatusModel.value = ClientUpdateStatusModel(
          clientCheckInTime: (check?.clientCheckInTime ?? check?.checkInTime ?? '').toString(),
          clientCheckOutTime: (check?.clientCheckOutTime ?? check?.checkOutTime ?? '').toString(),
          clientBreakTime: check?.clientBreakTime == null || check?.clientBreakTime == 0
              ? check?.breakTime
              : check?.clientBreakTime);
      tecComment.text = element.checkInCheckOutDetails?.clientComment ?? '';
      clientUpdateStatusModel.refresh();

      // checkout is 24h ago
      if ((element.checkInCheckOutDetails?.checkOutTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.checkOutTime!.toLocal()).inHours > 1) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckOutTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.clientCheckOutTime!.toLocal()).inHours > 1) {
        return false;
      }
      // check in 24h ago (forgot checkout)
      else if ((element.checkInCheckOutDetails?.checkInTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.checkInTime!.toLocal()).inHours > 1) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckInTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.clientCheckInTime!.toLocal()).inHours > 1) {
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
          clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory![index];

      clientUpdateStatusModel.value.id =
          clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index].currentHiredEmployeeId ?? '';
      clientUpdateStatusModel.value.checkIn = element.checkInCheckOutDetails?.checkIn ?? false;
      clientUpdateStatusModel.value.checkOut = element.checkInCheckOutDetails?.checkOut ?? false;
      clientUpdateStatusModel.value.clientComment = tecComment.text;

      CustomLoader.show(context!);
      await _apiHelper
          .updateCheckInOutByClient(clientUpdateStatusModel: clientUpdateStatusModel.value)
          .then((Either<CustomError, Response> response) {
        CustomLoader.hide(context!);

        response.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (result) {
          Get.back(); // hide dialog

          if ([200, 201].contains(result.statusCode)) {
            clientHomeController.clientPaymentInvoiceMethod();
          }
        });
      });
    }
  }

  String getComment(int index) {
    CheckInCheckOutDetails? check =
        clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index].checkInCheckOutDetails;
    return check?.clientComment ?? '';
  }

  void onClockPressed({required int index, required String tag}) {
    Get.dialog(Dialog(
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(color: MyColors.lightCard(context!), borderRadius: BorderRadius.circular(5.0)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TimerWheel24HWidget(
                height: 250,
                width: 300,
                centerHighlightColor: MyColors.c_DDBD68.withOpacity(0.4),
                initialTime: DateTime.parse(tag == 'checkIn'
                    ? (clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.clientCheckInTime ??
                            clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.checkInTime)
                        .toString()
                    : (clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.clientCheckOutTime ??
                            clientHomeController.clientPaymentInvoice.value.checkInCheckOutHistory?[index]
                                .checkInCheckOutDetails?.checkOutTime)
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          backgroundColor: MyColors.c_C6A34F,
                        ),
                        onPressed: () => Get.back(),
                        child: Text("OK", style: MyColors.white.semiBold16)),
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
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: MyColors.lightCard(context!)),
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                          backgroundColor: MyColors.c_C6A34F,
                        ),
                        onPressed: () => Get.back(),
                        child: Text("OK", style: MyColors.white.semiBold16)),
                  )
                ],
              )
            ],
          )),
    ));
  }
}

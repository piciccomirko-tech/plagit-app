import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/model/client_invoice_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_request_model.dart';
import 'package:mh/app/modules/stripe_payment/models/stripe_response_model.dart';
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

  String _selectedInvoiceId = "";

  void onPayClick(int index) {
    _selectedInvoiceId = clientHomeController.clientInvoice.value.invoices![index].sId ?? "";
    makeStripePayment(
        stripeRequestModel: StripeRequestModel(
            amount: double.parse(clientHomeController.clientInvoice.value.invoices![index].totalAmount?.toStringAsFixed(2)??'0.0'),
            invoiceId: _selectedInvoiceId,
            currency: appController.user.value.client?.countryName?.toLowerCase() == 'united kingdom'
                ? 'gbp'
                : appController.user.value.client?.countryName?.toLowerCase() == 'united arab emirates'
                    ? 'aed'
                    : 'usd'));
  }


  void onViewInvoicePress({required InvoiceModel invoice}) async {
    invoiceFile = await Utils.generatePdfWithImageAndText(invoice: invoice);
    Get.toNamed(Routes.invoicePdf, arguments: [invoiceFile]);
  }

  void makeStripePayment({required StripeRequestModel stripeRequestModel}) {
    CustomLoader.show(context!);
    _apiHelper
        .stripePayment(stripeRequestModel: stripeRequestModel)
        .then((Either<CustomError, StripeResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(Get.context!, customError..onRetry);
      }, (StripeResponseModel response) {
        if (response.status == 'success' &&
            response.details != null &&
            response.details?.url != null &&
            response.details!.url!.isNotEmpty) {
          Get.toNamed(Routes.stripePayment, arguments: [response.details, _selectedInvoiceId]);
        }
      });
    });
  }
}

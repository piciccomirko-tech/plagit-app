import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/shortlisted_employees.dart';
import 'package:mh/app/modules/client/common/shortlist_controller.dart';

import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../models/terms_condition_for_hire.dart';

class ClientTermsConditionForHireController extends GetxController
    with StateMixin<TermsConditionForHire> {
  final ApiHelper _apiHelper = Get.find();

  BuildContext? context;

  final ShortlistController shortlistController = Get.find();

  @override
  void onInit() {
    _fetchTermsCondition();
    super.onInit();
  }

  Future<void> _fetchTermsCondition() async {
    change(null, status: RxStatus.loading());

    await _apiHelper
        .getTermsConditionForHire()
        .then((Either<CustomError, TermsConditionForHire> response) {
      response.fold((l) {
        change(null, status: RxStatus.error(l.msg));
      }, (TermsConditionForHire termsConditionForHire) {
        change(termsConditionForHire, status: RxStatus.success());
      });
    });
  }

  /*void onMakePaymentClick() {
    Get.toNamed(Routes.payment);
  }*/

  void onIAgreeClick() {
    CustomLoader.show(context!);

    _apiHelper
        .userValidation(
            email: Get.find<AppController>().user.value.client?.email ?? "")
        .then((Either<CustomError, Response> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (Response r) {
        if (r.statusCode == 201) {
          hireConfirm();
        } else {
          CustomLoader.hide(context!);
          Get.toNamed(Routes.cardAdd, arguments: [
            Get.find<AppController>().user.value.client?.email,
            'terms'
          ]);
        }
      });
    });
  }

  Future<void> hireConfirm() async {
    List<String> shortlistIds = [];

    for (ShortList element in shortlistController.selectedForHire) {
      shortlistIds.add(element.sId!);
    }

    await _apiHelper
        .hireConfirm({"selectedShortlist": shortlistIds}).then((response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        //  log("selectedShortlist error ${response}"); 
        Utils.errorDialog(context!, customError);
      }, (r) {

        log("selectedShortlist ${r.body}");
        shortlistController.fetchShortListEmployees();
        shortlistController.selectedForHire
          ..clear()
          ..refresh();

        if (Get.isRegistered<ClientPremiumRootController>()) {
          Get.until((Route route) => Get.currentRoute == Routes.clientPremiumRoot);
        } else {
          Get.until((Route route) => Get.currentRoute == Routes.clientPremiumRoot);
        }

        Get.toNamed(Routes.hireStatus);
      });
    });
  }
}

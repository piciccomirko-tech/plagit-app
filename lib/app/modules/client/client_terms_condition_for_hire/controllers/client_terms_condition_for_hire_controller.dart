import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/common/shortlist_controller.dart';

import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../models/terms_condition_for_hire.dart';

class ClientTermsConditionForHireController extends GetxController with StateMixin<TermsConditionForHire> {
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

    await _apiHelper.getTermsConditionForHire().then((response) {
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
    hireConfirm();
  }

  Future<void> hireConfirm() async {
    List<String> shortlistIds = [];

    for (var element in shortlistController.selectedForHire) {
      shortlistIds.add(element.sId!);
    }

    CustomLoader.show(context!);

    await _apiHelper.hireConfirm({"selectedShortlist": shortlistIds}).then((response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (r) {
        shortlistController.fetchShortListEmployees();
        shortlistController.selectedForHire
          ..clear()
          ..refresh();
        Get.until((Route route) => Get.currentRoute == Routes.clientHome);
        Get.toNamed(Routes.hireStatus);
      });
    });
  }
}

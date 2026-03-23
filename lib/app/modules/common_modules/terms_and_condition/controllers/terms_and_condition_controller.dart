import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_terms_condition_for_hire/models/terms_condition_for_hire.dart';
import 'package:mh/app/repository/api_helper.dart';

class TermsAndConditionController extends GetxController with StateMixin<TermsConditionForHire> {


  final ApiHelper _apiHelper = Get.find();

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

}

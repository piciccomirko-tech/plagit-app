import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/check_in_out_histories.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_model.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../models/social_feed_response_model.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';

class EmployeePaymentHistoryController extends GetxController {
  RxBool employeePaymentHistoryDataLoaded = false.obs;
  RxList<CheckInCheckOutHistoryElement> employeePaymentHistoryList = <CheckInCheckOutHistoryElement>[].obs;

  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find();

  BuildContext? context;

  @override
  void onInit() {
    _getEmployeePaymentHistory();
    super.onInit();
  }

  @override
  void onClose() {
    employeePaymentHistoryList.clear();
    super.onClose();
  }
// Conversion function: from ClientId to SocialUser
  SocialUser clientIdToSocialUser(ClientId clientId) {
    return SocialUser(
      id: clientId.id,
      name: clientId.name ?? clientId.restaurantName,
      positionId: clientId.positionId,
      positionName: clientId.positionName,
      email: clientId.email,
      role: clientId.role,
      profilePicture: clientId.profilePicture,
      countryName: clientId.countryName,
    );
  }

  EmployeePaymentModel employeePaymentHistory(int index) =>
      Utils.employeePaymentHistory(employeePaymentHistoryList[index]);

  void _getEmployeePaymentHistory() async {
    Either<CustomError, CheckInCheckOutHistory> response = await _apiHelper.getCheckInOutHistory(
      employeeId: appController.user.value.employee?.id??"",
    );
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _getEmployeePaymentHistory);
    }, (CheckInCheckOutHistory r) async {
      if (r.status == "success" && r.statusCode == 200 && r.checkInCheckOutHistory != null) {
        employeePaymentHistoryList.value = r.checkInCheckOutHistory ?? [];
        employeePaymentHistoryDataLoaded.value = true;
      }
    });
  }

  String getComment(int index) {
    return employeePaymentHistoryList[index].checkInCheckOutDetails?.clientComment ?? "";
  }
}

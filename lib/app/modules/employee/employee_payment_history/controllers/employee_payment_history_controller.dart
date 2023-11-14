import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_history_model.dart';
import 'package:mh/app/modules/employee/employee_payment_history/models/employee_payment_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeePaymentHistoryController extends GetxController {
  RxBool employeePaymentHistoryDataLoaded = false.obs;
  RxList<EmployeePaymentHistoryModel> employeePaymentHistoryList = <EmployeePaymentHistoryModel>[].obs;

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

  EmployeePaymentModel employeePaymentHistory(int index) =>
      Utils.employeePaymentHistory(employeePaymentHistoryList[index]);

  void _getEmployeePaymentHistory() {
    _apiHelper
        .employeePaymentHistory(employeeId: appController.user.value.userId)
        .then((Either<CustomError, EmployeePaymentHistory> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getEmployeePaymentHistory);
      }, (EmployeePaymentHistory response) {
        if (response.status == "success" && response.statusCode == 200 && response.employeePaymentHistoryList != null) {
          employeePaymentHistoryList.value = response.employeePaymentHistoryList ?? [];
          employeePaymentHistoryDataLoaded.value = true;
        }
      });
    });
  }
}

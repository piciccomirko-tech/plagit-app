import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeHiredHistoryController extends GetxController {
  final EmployeeHomeController employeeHomeController = Get.find<EmployeeHomeController>();
  RxBool isLoading = true.obs;
  RxList<RequestDateModel> prevDateList = <RequestDateModel>[].obs;
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  void onDetailsClick({required List<RequestDateModel> bookedDateList}) {
    bookedDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: bookedDateList);
  }

  void calculatePreviousDates({required List<RequestDateModel> bookedDateList}) {
    for (var i in bookedDateList) {
      if (DateTime.parse(i.endDate ?? '').toString().substring(0, 10) == DateTime.now().toString().substring(0, 10)) {
        i.status = '';
      } else if (DateTime.parse(i.endDate ?? '').isBefore(DateTime.now())) {
        i.status = 'Done';
      } else {
        i.status = '';
      }
    }
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: bookedDateList));
  }

  void onPrevDateClicked({required String hiredBy}) async {
    await _getAllHiredEmployees(hiredBy: hiredBy);
    prevDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: prevDateList));
  }

  Future<void> _getAllHiredEmployees({required String hiredBy}) async {
    CustomLoader.show(context!);
    Either<CustomError, ClientMyEmployeesModel> response = await _apiHelper.getClientMyEmployees(
        hiredBy: hiredBy, employeeId: Get.find<AppController>().user.value.employee?.id ?? '');
    CustomLoader.hide(context!);
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ClientMyEmployeesModel emp) {
      if (emp.status == "success" &&
          emp.statusCode == 200 &&
          emp.details != null &&
          emp.details?.result != null &&
          emp.details!.result!.isNotEmpty) {
        prevDateList.value = emp.details!.result?.first.employee?.first.previousDate ?? [];
        prevDateList.refresh();
      }
    });
  }
}

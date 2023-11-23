import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../common/shortlist_controller.dart';

class ClientMyEmployeeController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final ShortlistController shortlistController = Get.find();
  final AppController appController = Get.find<AppController>();
  final ClientHomeController clientHomeController = Get.find<ClientHomeController>();
  RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  RxBool isLoading = true.obs;
  RxString startDate = ''.obs;
  RxString endDate = ''.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxBool hideCalender = false.obs;

  @override
  void onInit() async {
    await _getAllHiredEmployees();
    super.onInit();
  }

  Future<void> _getAllHiredEmployees() async {
    isLoading.value = true;
    Either<CustomError, ClientMyEmployeesModel> response =
        await _apiHelper.getClientMyEmployees(startDate: startDate.value, endDate: endDate.value);
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ClientMyEmployeesModel emp) {
      if (emp.status == "success" &&
          emp.statusCode == 200 &&
          emp.details != null &&
          emp.details?.result != null &&
          emp.details!.result!.isNotEmpty) {
        employees.value = emp.details?.result?.first.employee ?? [];
        employees.refresh();
      }
    });
  }

  void onCalenderClick({required List<RequestDateModel> bookedDateList}) {
    bookedDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: bookedDateList);
  }

  void chatWithEmployee({required String employeeName, required String employeeId}) {
    CustomLoader.show(context!);
    _apiHelper.matchEmployee(employeeId: employeeId).then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseData) {
        if (responseData.status == "success" && responseData.statusCode == 200 && responseData.result == "true") {
          Get.toNamed(Routes.clientEmployeeChat, arguments: {
            MyStrings.arg.receiverName: employeeName,
            MyStrings.arg.fromId: appController.user.value.userId,
            MyStrings.arg.toId: employeeId,
            MyStrings.arg.clientId: appController.user.value.userId,
            MyStrings.arg.employeeId: employeeId,
          });
        } else {
          Utils.showSnackBar(
              message: 'You cannot chat with this employee \nbecause he is not hired today', isTrue: false);
        }
      });
    });
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

  void onRadioButtonTap(String value) {
    startDate.value = value;
    endDate.value = value;
    if (value.isNotEmpty) {
      hideCalender.value = true;
    } else {
      hideCalender.value = false;
    }
    _getAllHiredEmployees();
  }

  void onDatePicked(DateTime dateTime) {
    selectedDate.value = dateTime;
    startDate.value = dateTime.toString().split(' ').first;
    endDate.value = dateTime.toString().split(' ').first;
    startDate.refresh();
    endDate.refresh();

    _getAllHiredEmployees();
  }
}

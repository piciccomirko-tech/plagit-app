import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/widgets/break_time_picker_widget.dart';
import 'package:mh/app/common/widgets/timer_wheel_for24_h_widget.dart';
import 'package:mh/app/models/check_in_check_out_details.dart';
import 'package:mh/app/models/employee_details.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../client_home/controllers/client_home_controller.dart';

class ClientDashboardController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();

  final AppController appController = Get.find();

  final ClientHomeController clientHomeController = Get.find();

  final List<Map<String, dynamic>> fields = [
    {"name": "Employee", "width": 143.0},
    {"name": "Check In", "width": 100.0},
    {"name": "Check Out", "width": 100.0},
    {"name": "Break Time", "width": 100.0},
    {"name": "Total Hours", "width": 100.0},
    {"name": "Chat", "width": 100.0},
    {"name": "More", "width": 100.0},
  ];

  Rx<ClientUpdateStatusModel> clientUpdateStatusModel = ClientUpdateStatusModel().obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController tecTime = TextEditingController();
  TextEditingController tecComment = TextEditingController();

  Rx<DateTime> dashboardDate = DateTime.now().obs;
  RxString selectedDate = "".obs;

  RxBool loading = false.obs;
  Rx<CheckInCheckOutHistory> checkInCheckOutHistory = CheckInCheckOutHistory().obs;
  RxList<String> totalActiveEmployee = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    onDatePicked(DateTime.now());
    _fetchCheckInOutHistory();
  }

  void onDatePicked(DateTime dateTime) {
    dashboardDate.value = dateTime;
    dashboardDate.refresh();
    selectedDate.value = DateFormat('E, d MMM y').format(dashboardDate.value);
    _fetchCheckInOutHistory();
  }

  Future<void> _fetchCheckInOutHistory() async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response = await _apiHelper.getCheckInOutHistory(
      filterDate: dashboardDate.value.toString().split(" ").first,
      clientId: appController.user.value.userId,
    );
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      this.checkInCheckOutHistory.value = checkInCheckOutHistory;
      countTotalActiveEmployees();
    });
  }

  void chatWithEmployee({required EmployeeDetails employeeDetails}) {
    CustomLoader.show(context!);
    _apiHelper
        .matchEmployee(employeeId: employeeDetails.employeeId ?? '')
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseData) {
        if (responseData.status == "success" && responseData.statusCode == 200 && responseData.result == "true") {
          Get.toNamed(Routes.clientEmployeeChat, arguments: {
            MyStrings.arg.receiverName: employeeDetails.name ?? "-",
            MyStrings.arg.fromId: appController.user.value.userId,
            MyStrings.arg.toId: employeeDetails.employeeId ?? "",
            MyStrings.arg.clientId: appController.user.value.userId,
            MyStrings.arg.employeeId: employeeDetails.employeeId ?? "",
          });
        } else {
          Utils.showSnackBar(
              message: 'You cannot chat with this employee \nbecause he is not hired today', isTrue: false);
        }
      });
    });
  }

  void countTotalActiveEmployees() {
    if (checkInCheckOutHistory.value.checkInCheckOutHistory != null &&
        checkInCheckOutHistory.value.checkInCheckOutHistory!.isNotEmpty) {
      totalActiveEmployee.clear();
      for (CheckInCheckOutHistoryElement i in checkInCheckOutHistory.value.checkInCheckOutHistory!) {
        if (!totalActiveEmployee.contains(i.employeeId ?? '')) {
          totalActiveEmployee.add(i.employeeId ?? '');
        }
      }
      totalActiveEmployee.refresh();
    }
  }


}

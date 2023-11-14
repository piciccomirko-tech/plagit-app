import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../client_dashboard/models/current_hired_employees.dart';
import '../../common/shortlist_controller.dart';

class ClientMyEmployeeController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();
  final ShortlistController shortlistController = Get.find();
  final AppController appController = Get.find<AppController>();
  final ClientHomeController clientHomeController = Get.find<ClientHomeController>();

  Rx<HiredEmployeesByDate> employees = HiredEmployeesByDate().obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    _getAllHiredEmployees();
    super.onInit();
  }

  Future<void> _getAllHiredEmployees() async {
    isLoading.value = true;

    await _apiHelper.getHiredEmployeesByDate().then((Either<CustomError, HiredEmployeesByDate> response) {
      isLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getAllHiredEmployees);
      }, (HiredEmployeesByDate employees) {
        this.employees.value = employees;
        this.employees.refresh();
      });
    });
  }

  void onCalenderClick({required List<RequestDateModel> requestDateList}) {
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: requestDateList));
  }

  void chatWithEmployee({required String employeeName, required String employeeId}) {
    Get.toNamed(Routes.clientEmployeeChat, arguments: {
      MyStrings.arg.receiverName: employeeName,
      MyStrings.arg.fromId: appController.user.value.userId,
      MyStrings.arg.toId: employeeId,
      MyStrings.arg.clientId: appController.user.value.userId,
      MyStrings.arg.employeeId: employeeId,
    });
  }
}

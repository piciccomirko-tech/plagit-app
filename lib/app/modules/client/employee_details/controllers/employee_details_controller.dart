import 'package:dartz/dartz.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/repository/api_helper.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../routes/app_pages.dart';
import '../../common/shortlist_controller.dart';

class EmployeeDetailsController extends GetxController {
  BuildContext? context;

  final AppController _appController = Get.find();
  late bool showAsAdmin;
  late String fromWhere;

  final ShortlistController shortlistController = Get.find();
  Rx<Employee> employee = Employee().obs;
  RxBool loading = false.obs;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = Get.find<AppController>();
  String employeeId = '';
  String available = '';
  @override
  void onInit() {
    available = Get.arguments[MyStrings.arg.employeeAvailableDays];
    employeeId = Get.arguments[MyStrings.arg.data];
    showAsAdmin = Get.arguments[MyStrings.arg.showAsAdmin];
    fromWhere = Get.arguments[MyStrings.arg.fromWhere];
    _getDetails();
    super.onInit();
  }

  Future<void> onBookNowClick() async {
    if (!_appController.hasPermission()) return;
    Get.toNamed(Routes.calender, arguments: [employee.value.id ?? '', '', null]);
  }

  // only admin chat with employee
  void onChatClick() {
    Get.toNamed(Routes.supportChat, arguments: {
      MyStrings.arg.fromId: _appController.user.value.userId,
      MyStrings.arg.toId: employee.value.id ?? "",
      MyStrings.arg.supportChatDocId: employee.value.id ?? "",
      MyStrings.arg.receiverName: employee.value.firstName ?? "-",
    });
  }

  void onViewCalenderClick() {
    Get.toNamed(Routes.calender, arguments: [employee.value.id ?? '', '', null]);
  }

  Future<void> _getDetails() async {
    loading.value = true;
    Either<CustomError, EmployeeFullDetails> response = await _apiHelper.employeeFullDetails(employeeId);
    loading.value = false;

    response.fold((CustomError l) {
      Logcat.msg(l.msg);
    }, (EmployeeFullDetails r) {
      if (r.status == "success" && r.statusCode == 200 && r.details != null) {
        employee.value = r.details!;
        employee.refresh();
      }
    });
  }
}

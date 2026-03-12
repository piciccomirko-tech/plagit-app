import 'package:dartz/dartz.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/models/hourly_rate_model.dart';
import 'package:mh/app/models/nationality_model.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../common/shortlist_controller.dart';

class MhEmployeesByIdController extends GetxController {
  BuildContext? context;

  final AppController _appController = Get.find();
  final ShortlistController shortlistController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  late DropdownItem position;

  Rx<Employees> employees = Employees().obs;

  RxBool isLoading = false.obs;

  RxList<NationalityDetailsModel> nationalityList = <NationalityDetailsModel>[].obs;
  RxBool nationalityDataLoaded = false.obs;

  Rx<HourlyRateDetailsModel> hourlyRateDetails = HourlyRateDetailsModel().obs;
  RxBool hourlyDetailsDataLoaded = false.obs;

  @override
  void onInit() {
    position = Get.arguments[MyStrings.arg.data];
    super.onInit();
  }

  @override
  void onReady() async {
    await _getEmployees();
    await _getNationalityList();
    await _getHourlyRate();
    super.onReady();
  }

  Future<void> onBookNowClick(Employee employee) async {
    if (!_appController.hasPermission()) return;
    Get.toNamed(Routes.calender, arguments: [
      employee.id ?? '',
      shortListId(employeeId: employee.id ?? ''),
      employee.hasUniform == true ? null : false
    ]);
  }

  void onEmployeeClick(Employee employee) {
    Get.toNamed(Routes.employeeDetails, arguments: {
      MyStrings.arg.employeeAvailableDays: employee.available??"",
      MyStrings.arg.data: employee.id,
      MyStrings.arg.showAsAdmin: false,
      MyStrings.arg.fromWhere: MyStrings.arg.mhEmployeeViewByIdText
    });
  }

  Future<void> _getEmployees(
      {String? experience,
      String? minTotalHour,
      String? maxTotalHour,
      String? dressSize,
      String? nationality,
      String? minHeight,
      String? maxHeight,
      String? minHourlyRate,
      String? maxHourlyRate}) async {
    if (isLoading.value) return;

    isLoading.value = true;

    await _apiHelper
        .getEmployees(
            positionId: position.id,
            employeeExperience: experience,
            minTotalHour: minTotalHour,
            maxTotalHour: maxTotalHour,
            dressSize: dressSize,
            nationality: nationality,
            minHeight: minHeight,
            maxHeight: maxHeight,
            minHourlyRate: minHourlyRate,
            maxHourlyRate: maxHourlyRate)
        .then((Either<CustomError, Employees> response) {
      isLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _getEmployees);
      }, (Employees employees) {
        this.employees.value = employees;
        this.employees.refresh();
      });
    });
  }

  void onApplyClick(String selectedExp, String minTotalHour, String maxTotalHour, String positionId, String dressSize,
      String nationality, String minHeight, String maxHeight, String minHourlyRate, String maxHourlyRate) {
    _getEmployees(
        experience: selectedExp,
        minTotalHour: minTotalHour,
        maxTotalHour: maxTotalHour,
        dressSize: dressSize,
        nationality: nationality,
        minHourlyRate: minHourlyRate,
        maxHourlyRate: maxHourlyRate,
        minHeight: minHeight,
        maxHeight: maxHeight);
  }

  void onResetClick() {
    Get.back(); // hide dialog
    _getEmployees();
  }

  void goToShortListedPage() {
    Get.toNamed(Routes.clientShortlisted);
  }

  String shortListId({required String employeeId}) {
    for (var i in shortlistController.shortList) {
      if (i.employeeId == employeeId) {
        return i.sId ?? '';
      }
    }
    return '';
  }

  Future<void> _getNationalityList() async {
    Either<CustomError, NationalityModel> response = await _apiHelper.getNationalities();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (NationalityModel responseData) {
      if (responseData.status == "success") {
        nationalityList.value = responseData.nationalities ?? [];
        nationalityList.refresh();
        nationalityList.insert(0, NationalityDetailsModel(sId: '99', country: '', nationality: ''));
      }
    });
    nationalityDataLoaded.value = true;
  }

  Future<void> _getHourlyRate() async {
    Either<CustomError, HourlyRateModel> response = await _apiHelper.getHourlyRate();
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (HourlyRateModel responseData) {
      if (responseData.status == "success" && responseData.result != null) {
        hourlyRateDetails.value = responseData.result!;
        hourlyRateDetails.refresh();
      }
    });
    hourlyDetailsDataLoaded.value = true;
  }
}

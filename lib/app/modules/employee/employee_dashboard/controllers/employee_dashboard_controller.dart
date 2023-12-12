import 'package:dartz/dartz.dart';

import '../../../../common/utils/exports.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';

class EmployeeDashboardController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();

  RxBool loading = true.obs;

  Rx<CheckInCheckOutHistory> checkInCheckOutHistory = CheckInCheckOutHistory().obs;

  RxList<CheckInCheckOutHistoryElement> history = <CheckInCheckOutHistoryElement>[].obs;
  RxList<CheckInCheckOutHistoryElement> dateWiseHistoryList = <CheckInCheckOutHistoryElement>[].obs;
  Rx<DateTime> selectedStartDate = DateTime.now().obs;
  Rx<DateTime> selectedEndDate = DateTime.now().add(const Duration(days: 1)).obs;

  @override
  void onInit() async {
    await _fetchCheckInOutHistory();
    super.onInit();
  }

  String getComment(int index) {
    return history[index].checkInCheckOutDetails?.clientComment ?? "";
  }

  Future<void> _fetchCheckInOutHistory({String? startDate, String? endDate}) async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getEmployeeCheckInOutHistory(startDate: startDate, endDate: endDate);
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      this.checkInCheckOutHistory.value = checkInCheckOutHistory;
      history.value = checkInCheckOutHistory.checkInCheckOutHistory ?? [];
    });
  }

  void onDateRangePicked(DateTimeRange dateTime) async {
    _fetchCheckInOutHistory(
        startDate: dateTime.start.toString().split(" ").first, endDate: dateTime.end.toString().split(" ").first);
  }
}

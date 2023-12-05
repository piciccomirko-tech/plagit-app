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
  Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() async {
    await _fetchCheckInOutHistory();
    super.onInit();
  }

  String getComment(int index) {
    return history[index].checkInCheckOutDetails?.clientComment ?? "";
  }

  Future<void> _fetchCheckInOutHistory() async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response = await _apiHelper.getEmployeeCheckInOutHistory();
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      this.checkInCheckOutHistory.value = checkInCheckOutHistory;
      history.value = checkInCheckOutHistory.checkInCheckOutHistory ?? [];
    });
  }

  void onDatePicked(DateTime dateTime) async {
    selectedDate.value = dateTime;
    dateWiseHistoryList.clear();
    await _fetchCheckInOutHistory();
    for (CheckInCheckOutHistoryElement i in history) {
      if (i.checkInCheckOutDetails?.checkInTime.toString().split(" ").first ==
          selectedDate.value.toString().split(" ").first) {
        dateWiseHistoryList.add(i);
      }
    }
    history.value = dateWiseHistoryList;
    history.refresh();
  }
}

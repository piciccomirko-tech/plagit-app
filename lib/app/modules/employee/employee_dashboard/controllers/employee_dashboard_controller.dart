import 'package:dartz/dartz.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';

class EmployeeDashboardController extends GetxController {
  BuildContext? context;

  final ApiHelper _apiHelper = Get.find();

  RxList<CheckInCheckOutHistoryElement> history = <CheckInCheckOutHistoryElement>[].obs;
  RxList<CheckInCheckOutHistoryElement> dateWiseHistoryList = <CheckInCheckOutHistoryElement>[].obs;
  Rx<DateTime> selectedStartDate = DateTime.now().obs;
  Rx<DateTime> selectedEndDate = DateTime.now().add(const Duration(days: 1)).obs;

  RxBool isInitial = true.obs;

  RxInt pageSize = 10.obs;
  RxInt currentPage = 1.obs;
  RxBool loading = true.obs;
  PageController pageController = PageController();
  RxBool stopScrolling = false.obs;
  @override
  void onInit() async {
    await _fetchCheckInOutHistory(page: currentPage.value, limit: pageSize.value);
    super.onInit();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  String getComment(int index) {
    return history[index].checkInCheckOutDetails?.clientComment ?? "";
  }

  Future<void> _fetchCheckInOutHistory({String? startDate, String? endDate, int? limit, int? page}) async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getEmployeeCheckInOutHistory(startDate: startDate, endDate: endDate, limit: limit, page: page);
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      history.value = checkInCheckOutHistory.checkInCheckOutHistory ?? [];
      // Calculate total pages based on the total items and page size
    });
  }

  void onDateRangePicked(DateTimeRange dateTime) async {
    selectedStartDate.value = dateTime.start;
    selectedEndDate.value = dateTime.end;
    isInitial.value = false;
    await _fetchCheckInOutHistory(
      startDate: dateTime.start.toString().split(" ").first,
      endDate: dateTime.end.toString().split(" ").first,
    );
  }

  void loadMoreData() async {
    if (stopScrolling.value == false) {
      currentPage.value++;
      Either<CustomError, CheckInCheckOutHistory> response =
          await _apiHelper.getEmployeeCheckInOutHistory(limit: pageSize.value, page: currentPage.value);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
      }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
        if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).isNotEmpty) {
          if ((checkInCheckOutHistory.checkInCheckOutHistory ?? []).length < pageSize.value) {
            stopScrolling.value = true;
          }
          history.addAll(checkInCheckOutHistory.checkInCheckOutHistory ?? []);
          history.refresh();
        } else {
          stopScrolling.value = true;
        }
      });
    }
  }
}

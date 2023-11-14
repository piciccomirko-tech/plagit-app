import 'package:dartz/dartz.dart';
import 'package:mh/app/modules/client/client_dashboard/models/current_hired_employees.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employee_daily_statistics.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../repository/api_helper.dart';

class AdminDashboardController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  RxInt uniqueClient = 0.obs;

  RxBool historyLoading = true.obs;
  RxBool clientLoading = true.obs;

  Rx<DateTime> dashboardDate = DateTime.now().obs;

  Rx<HiredEmployeesByDate> hiredEmployeesByDate = HiredEmployeesByDate().obs;

  Rx<CheckInCheckOutHistory> checkInCheckOutHistory = CheckInCheckOutHistory().obs;

  RxList<CheckInCheckOutHistoryElement> history = <CheckInCheckOutHistoryElement>[].obs;

  String? requestType = "CLIENT";
  String? clientId;

  Rx<Employees> clients = Employees().obs;
  RxList<String> restaurants = ["ALL"].obs;

  RxInt totalWorkingTimeInMinutes = 0.obs;
  RxDouble amount = 0.0.obs;

  TextEditingController tecTime = TextEditingController();
  TextEditingController tecComment = TextEditingController();

  List<String> complainType = [
    "Check In Before",
    "Check In After",
    "Check Out Before",
    "Check Out After",
    "Break Time",
  ];

  String selectedComplainType = "Check In Before";

  @override
  void onInit() {
    _fetchClients();
    _fetchCheckInOutHistory();
    super.onInit();
  }

  UserDailyStatistics dailyStatistics(int index) => Utils.checkInOutToStatistics(history[index]);

  void onDatePicked(DateTime dateTime) {
    dashboardDate.value = dateTime;
    dashboardDate.refresh();

    _fetchCheckInOutHistory();
  }

  void onClientChange(String? value) {
    if (value == restaurants.first) {
      clientId = null;
    } else {
      clientId = (clients.value.users ?? []).firstWhere((element) => element.restaurantName == value).id;
    }

    _fetchCheckInOutHistory();
  }

  Future<void> _fetchCheckInOutHistory() async {
    historyLoading.value = true;

    await _apiHelper
        .getCheckInOutHistory(
      filterDate: dashboardDate.value.toString().split(" ").first,
      clientId: clientId,
    )
        .then((Either<CustomError, CheckInCheckOutHistory> response) {
      historyLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchCheckInOutHistory);
      }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
        this.checkInCheckOutHistory.value = checkInCheckOutHistory;
        history
          ..clear()
          ..addAll(checkInCheckOutHistory.checkInCheckOutHistory ?? []);

        _updateSummary();
      });
    });
  }

  Future<void> _fetchClients() async {
    clientLoading.value = true;

    await _apiHelper
        .getAllUsersFromAdmin(
      requestType: "CLIENT")
        .then((response) {
      clientLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchClients);
      }, (Employees clients) {
        this.clients.value = clients;
        this.clients.refresh();

        restaurants.addAll((clients.users ?? []).map((e) => e.restaurantName!).toList());
      });
    });
  }

  void _updateSummary() {
    var uniqueRestaurant = <String>{};

    for (int i = 0; i < history.length; i++) {
      CheckInCheckOutHistoryElement element = history[i];
      uniqueRestaurant.add(element.hiredBy!);

      UserDailyStatistics s = dailyStatistics(i);

      totalWorkingTimeInMinutes.value += s.totalWorkingTimeInMinute;
      amount.value += double.parse(s.amount);
    }

    uniqueClient.value = uniqueRestaurant.length;
  }

  String getComment(int index) {
    return getCheckInOutDate(index)?.checkInCheckOutDetails?.clientComment ?? "";
  }

  CheckInCheckOutHistoryElement? getCheckInOutDate(int index) {
    String employeeId = checkInCheckOutHistory.value.checkInCheckOutHistory![index].employeeDetails!.employeeId!;
    String id = checkInCheckOutHistory.value.checkInCheckOutHistory![index].id!;

    for (CheckInCheckOutHistoryElement element in checkInCheckOutHistory.value.checkInCheckOutHistory ?? []) {
      if (element.employeeDetails!.employeeId! == employeeId && element.id == id) {
        return element;
      }
    }

    return null;
  }
  void onComplainTypeChange(int index, String? type) {
    selectedComplainType = type!;

    setUpdatedDate(index);
  }

  void setUpdatedDate(int index) {
    CheckInCheckOutHistoryElement? element = getCheckInOutDate(index);
    if(element != null) {
      tecComment.text = element.checkInCheckOutDetails?.clientComment ?? "";
      tecTime.clear();

      complainType = [
        "Check In Before",
        "Check In After",
      ];

      if(element.checkInCheckOutDetails?.checkOutTime != null) {
        complainType = [
          "Check In Before",
          "Check In After",
          "Check Out Before",
          "Check Out After",
          "Break Time",
        ];
      }

      if(selectedComplainType == complainType[0] || selectedComplainType == complainType[1]) {
        if(element.checkInCheckOutDetails?.clientCheckInTime != null) {

          int dif = element.checkInCheckOutDetails!.clientCheckInTime!.difference(element.checkInCheckOutDetails!.checkInTime!).inMinutes;
          if(selectedComplainType == complainType[0]) {
            if(dif < 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          } else {
            if(dif > 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          }

        }
      }
      else if(selectedComplainType == complainType[2] || selectedComplainType == complainType[3]) {
        if(element.checkInCheckOutDetails?.clientCheckOutTime != null) {

          var dif = element.checkInCheckOutDetails!.clientCheckOutTime!.difference(element.checkInCheckOutDetails!.checkOutTime!).inMinutes;

          if(selectedComplainType == complainType[2]) {
            if(dif < 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          } else {
            if(dif > 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          }

        }
      }
      else if(selectedComplainType == complainType.last) {
        tecTime.text = (element.checkInCheckOutDetails?.clientBreakTime ?? 0).toString();
      }
    }

  }

}

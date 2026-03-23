
import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/admin/admin_dashboard/models/update_refund_model.dart';
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

  Rx<DateTime> dashboardDate = DateTime.now().obs;

  Rx<HiredEmployeesByDate> hiredEmployeesByDate = HiredEmployeesByDate().obs;

  Rx<CheckInCheckOutHistory> checkInCheckOutHistory =
      CheckInCheckOutHistory().obs;

  RxList<CheckInCheckOutHistoryElement> history =
      <CheckInCheckOutHistoryElement>[].obs;

  String? clientId;

  Rx<Employees> clients = Employees().obs;
  // RxList<String> restaurants = ["ALL"].obs;
  RxBool clientLoading = true.obs;
  RxList<String> workedHoursList = [''].obs;
  RxDouble totalWorkedHours = 0.0.obs;
  RxInt totalWorkingTimeInMinutes = 0.obs;
  RxDouble amount = 0.0.obs;
  RxDouble totalAmountForAdmin = 0.0.obs;

  TextEditingController tecTime = TextEditingController();
  TextEditingController tecComment = TextEditingController();
  TextEditingController tecRemark = TextEditingController();
  TextEditingController tecRefundAmount = TextEditingController();

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
    //_fetchClients();
    _fetchCheckInOutHistory();
    totalAmountForAdmin.value = 0.0;
    workedHoursList.value = ['00:00:00'];
    super.onInit();
  }

  UserDailyStatistics dailyStatistics(int index) =>
      Utils.checkInOutToStatistics(history[index]);

  void onDatePicked(DateTime dateTime) {
    dashboardDate.value = dateTime;
    dashboardDate.refresh();

    _fetchCheckInOutHistory();
    totalAmountForAdmin.value = 0.0;
    workedHoursList.value = ['00:00:00'];
  }

  double calculateTotalHours(List<String> timeList) {
    int totalSeconds = 0;

    for (var time in timeList) {
      // Remove whitespace from the time string
      final cleanedTime = time.trim();

      // Skip empty or invalid time strings
      if (cleanedTime.isEmpty ||
          !RegExp(r'^(\d+):(\d+):(\d+)$').hasMatch(cleanedTime)) {
        continue;
      }

      // Split the cleaned time and parse into parts
      final parts = cleanedTime.split(':').map(int.parse).toList();
      if (parts.length == 3) {
        totalSeconds += parts[0] * 3600 + parts[1] * 60 + parts[2];
      }
    }

    return totalSeconds / 3600.0; // Convert total seconds to hours
  }

  /* void onClientChange(String? value) {
    if (value == restaurants.first) {
      clientId = null;
    } else {
      clientId = (clients.value.users ?? []).firstWhere((element) => element.restaurantName == value).id;
    }

    _fetchCheckInOutHistory();
  }*/

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
        Utils.errorDialog(
            context!, customError..onRetry = _fetchCheckInOutHistory);
      }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
        this.checkInCheckOutHistory.value = checkInCheckOutHistory;
        history
          ..clear()
          ..addAll(checkInCheckOutHistory.checkInCheckOutHistory ?? []);

        _updateSummary();
      });
    });
  }

  /*Future<void> _fetchClients() async {
    clientLoading.value = true;

    await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT").then((response) {
      clientLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchClients);
      }, (Employees clients) {
        this.clients.value = clients;
        this.clients.refresh();

        restaurants.addAll((clients.users ?? []).map((e) => e.restaurantName!).toList());
      });
    });
  }*/

  Future<void> _updateSummary() async {
    var uniqueRestaurant = <String>{};
    for (int i = 0; i < history.length; i++) {
      CheckInCheckOutHistoryElement element = history[i];
      uniqueRestaurant.add(element.hiredBy!);

//log("elelment amount: ${element.totalAmount}");
//log(" amount now: ${myAmount}");
      UserDailyStatistics s = dailyStatistics(i);
      workedHoursList.add(element.workedHour ?? '00:00:00');
      totalWorkingTimeInMinutes.value += s.totalWorkingTimeInSecond * 60;
      amount.value += double.parse(s.amount);
      totalAmountForAdmin.value += element.totalAmount ?? 0.0;
    }
    totalWorkedHours.value =
        double.parse(calculateTotalHours(workedHoursList).toStringAsFixed(2));
    uniqueClient.value = uniqueRestaurant.length;
  }

  String getComment(int index) {
    return getCheckInOutDate(index)?.checkInCheckOutDetails?.clientComment ??
        "";
  }

  CheckInCheckOutHistoryElement? getCheckInOutDate(int index) {
    String employeeId = checkInCheckOutHistory
        .value.checkInCheckOutHistory![index].employeeDetails!.employeeId!;
    String id = checkInCheckOutHistory.value.checkInCheckOutHistory![index].id!;

    for (CheckInCheckOutHistoryElement element
        in checkInCheckOutHistory.value.checkInCheckOutHistory ?? []) {
      if (element.employeeDetails!.employeeId! == employeeId &&
          element.id == id) {
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
    if (element != null) {
      tecComment.text = element.checkInCheckOutDetails?.clientComment ?? "";
      tecTime.clear();

      complainType = [
        "Check In Before",
        "Check In After",
      ];

      if (element.checkInCheckOutDetails?.checkOutTime != null) {
        complainType = [
          "Check In Before",
          "Check In After",
          "Check Out Before",
          "Check Out After",
          "Break Time",
        ];
      }

      if (selectedComplainType == complainType[0] ||
          selectedComplainType == complainType[1]) {
        if (element.checkInCheckOutDetails?.clientCheckInTime != null) {
          int dif = element.checkInCheckOutDetails!.clientCheckInTime!
              .difference(element.checkInCheckOutDetails!.checkInTime!)
              .inMinutes;
          if (selectedComplainType == complainType[0]) {
            if (dif < 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          } else {
            if (dif > 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          }
        }
      } else if (selectedComplainType == complainType[2] ||
          selectedComplainType == complainType[3]) {
        if (element.checkInCheckOutDetails?.clientCheckOutTime != null) {
          var dif = element.checkInCheckOutDetails!.clientCheckOutTime!
              .difference(element.checkInCheckOutDetails!.checkOutTime!)
              .inMinutes;

          if (selectedComplainType == complainType[2]) {
            if (dif < 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          } else {
            if (dif > 0) {
              tecTime.text = dif.abs().toString();
            } else {
              tecTime.text = "";
            }
          }
        }
      } else if (selectedComplainType == complainType.last) {
        tecTime.text =
            (element.checkInCheckOutDetails?.clientBreakTime ?? 0).toString();
      }
    }
  }

  void submitRefundAmount({required int index}) {
    if (tecRefundAmount.text.isEmpty) {
      Utils.showSnackBar(
          message: MyStrings.refundAmountRequired.tr, isTrue: false);
    }
    if (tecRemark.text.isEmpty) {
      Utils.showSnackBar(message: MyStrings.remarkRequired.tr, isTrue: false);
    } else {
      CustomLoader.show(context!);
      UpdateRefundModel updateRefundModel = UpdateRefundModel(
          id: getCheckInOutDate(index)?.id ?? "",
          refundAmount: double.parse(tecRefundAmount.text.trim()),
          remark: tecRemark.text);

      _apiHelper
          .updateRefund(updateRefundModel: updateRefundModel)
          .then((responseData) {
        CustomLoader.hide(context!);
        Utils.unFocus();
        Get.back();
        responseData.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (response) {
          if ([200, 201].contains(response.statusCode)) {
            Utils.showSnackBar(message: response.message ?? "", isTrue: true);
          } else {
            Utils.showSnackBar(message: response.message ?? "", isTrue: false);
          }
        });
      });
    }
  }
}

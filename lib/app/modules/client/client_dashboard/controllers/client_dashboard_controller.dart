import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/models/employee_details.dart';
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

  List<String> complainType = [
    "Check In Before",
    "Check In After",
    "Check Out Before",
    "Check Out After",
    "Break Time",
  ];

  String selectedComplainType = "Check In Before";

  final formKey = GlobalKey<FormState>();
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

  String getComment(int index) {
    return checkInCheckOutHistory.value.checkInCheckOutHistory?[index].checkInCheckOutDetails?.clientComment ?? '';
  }

  /*CheckInCheckOutHistoryElement? getCheckInOutDate(int index) {
    String id = checkInCheckOutHistory.value.checkInCheckOutHistory![index].employeeDetails!.employeeId!;

    for (var element in checkInCheckOutHistory.value.checkInCheckOutHistory ?? []) {
      if (element.employeeDetails!.employeeId! == id) {
        return element;
      }
    }

    return null;
  }*/

  bool clientCommentEnable(int index) {
    CheckInCheckOutHistoryElement? element = checkInCheckOutHistory.value.checkInCheckOutHistory![index];

    if (element.checkInCheckOutDetails != null) {
      // checkout is 24h ago
      if ((element.checkInCheckOutDetails?.checkOutTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.checkOutTime!.toLocal()).inHours > 12) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckOutTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.clientCheckOutTime!.toLocal()).inHours > 12) {
        return false;
      }
      // check in 24h ago (forgot checkout)
      else if ((element.checkInCheckOutDetails?.checkInTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.checkInTime!.toLocal()).inHours > 12) {
        return false;
      } else if ((element.checkInCheckOutDetails?.clientCheckInTime != null) &&
          DateTime.now().difference(element.checkInCheckOutDetails!.clientCheckInTime!.toLocal()).inHours > 12) {
        return false;
      }
    }

    return true;
  }

  void setUpdatedDate(int index) {
    CheckInCheckOutHistoryElement? element = checkInCheckOutHistory.value.checkInCheckOutHistory![index];
    if (element.checkInCheckOutDetails != null) {
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

      if (selectedComplainType == complainType[0] || selectedComplainType == complainType[1]) {
        if (element.checkInCheckOutDetails?.clientCheckInTime != null) {
          var dif = element.checkInCheckOutDetails!.clientCheckInTime!
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
      } else if (selectedComplainType == complainType[2] || selectedComplainType == complainType[3]) {
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
        tecTime.text = (element.checkInCheckOutDetails?.clientBreakTime ?? 0).toString();
      }
    }
  }

  void onDatePicked(DateTime dateTime) {
    dashboardDate.value = dateTime;
    dashboardDate.refresh();

    selectedDate.value = DateFormat('E, d MMM ,y').format(dashboardDate.value);

    _fetchCheckInOutHistory();
  }

  void onComplainTypeChange(int index, String? type) {
    selectedComplainType = type!;

    setUpdatedDate(index);
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

  Future<void> onUpdatePressed(int index) async {
    Utils.unFocus();

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      CheckInCheckOutHistoryElement element = checkInCheckOutHistory.value.checkInCheckOutHistory![index];

      int checkInDiff = 0, checkOutDiff = 0, breakTime = 0;

      if (element.checkInCheckOutDetails!.clientCheckInTime != null) {
        checkInDiff = element.checkInCheckOutDetails!.clientCheckInTime!
            .difference(element.checkInCheckOutDetails!.checkInTime!)
            .inMinutes;
      }

      if (element.checkInCheckOutDetails!.clientCheckOutTime != null) {
        checkOutDiff = element.checkInCheckOutDetails!.clientCheckOutTime!
            .difference(element.checkInCheckOutDetails!.checkOutTime!)
            .inMinutes;
      }

      if (element.checkInCheckOutDetails!.clientBreakTime != null) {
        breakTime = element.checkInCheckOutDetails?.clientBreakTime ?? 0;
      }

      Map<String, dynamic> data = {
        "id": element.currentHiredEmployeeId,
        "checkIn": (element.checkInCheckOutDetails?.checkIn ?? false) ||
            (element.checkInCheckOutDetails?.emmergencyCheckIn ?? false),
        "checkOut": (element.checkInCheckOutDetails?.checkOut ?? false) ||
            (element.checkInCheckOutDetails?.emmergencyCheckOut ?? false),
        if (tecComment.text.isNotEmpty) "clientComment": tecComment.text,
        "clientBreakTime": selectedComplainType == complainType.last ? int.parse(tecTime.text) : breakTime,
        "clientCheckInTime": complainType[0] == selectedComplainType
            ? -(int.parse(tecTime.text))
            : complainType[1] == selectedComplainType
                ? int.parse(tecTime.text)
                : checkInDiff,
        "clientCheckOutTime": complainType.length > 2
            ? complainType[2] == selectedComplainType
                ? -(int.parse(tecTime.text))
                : complainType[3] == selectedComplainType
                    ? int.parse(tecTime.text)
                    : checkOutDiff
            : 0,
      };

      CustomLoader.show(context!);
      await _apiHelper.updateCheckInOutByClient(data).then((Either<CustomError, Response> response) {
        CustomLoader.hide(context!);

        response.fold((CustomError customError) {
          Utils.errorDialog(context!, customError);
        }, (result) {
          Get.back(); // hide dialog

          if ([200, 201].contains(result.statusCode)) {
            _fetchCheckInOutHistory();
          }
        });
      });
    }
  }

  void chatWithEmployee({required EmployeeDetails employeeDetails}) {
    Get.toNamed(Routes.clientEmployeeChat, arguments: {
      MyStrings.arg.receiverName: employeeDetails.name ?? "-",
      MyStrings.arg.fromId: appController.user.value.userId,
      MyStrings.arg.toId: employeeDetails.employeeId ?? "",
      MyStrings.arg.clientId: appController.user.value.userId,
      MyStrings.arg.employeeId: employeeDetails.employeeId ?? "",
    });
  }

  void countTotalActiveEmployees() {
    if (checkInCheckOutHistory.value.checkInCheckOutHistory != null &&
        checkInCheckOutHistory.value.checkInCheckOutHistory!.isNotEmpty) {
      totalActiveEmployee.clear();
      for (var i in checkInCheckOutHistory.value.checkInCheckOutHistory!) {
        if (!totalActiveEmployee.contains(i.employeeId ?? '')) {
          totalActiveEmployee.add(i.employeeId ?? '');
        }
      }
      totalActiveEmployee.refresh();
    }
  }
}

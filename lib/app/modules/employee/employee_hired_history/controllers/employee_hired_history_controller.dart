import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/repository/api_helper.dart';

class EmployeeHiredHistoryController extends GetxController {
  // final EmployeeHomeController employeeHomeController = Get.find<EmployeeHomeController>();
  RxBool isLoading = true.obs;
  RxList<RequestDateModel> prevDateList = <RequestDateModel>[].obs;
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();

  void onDetailsClick({required List<RequestDateModel> bookedDateList}) {
    bookedDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: bookedDateList);
  }

  void calculatePreviousDates({required List<RequestDateModel> bookedDateList}) {
    for (var i in bookedDateList) {
      if (DateTime.parse(i.endDate ?? '').toString().substring(0, 10) == DateTime.now().toString().substring(0, 10)) {
        i.status = '';
      } else if (DateTime.parse(i.endDate ?? '').isBefore(DateTime.now())) {
        i.status = MyStrings.done.tr;
      } else {
        i.status = '';
      }
    }
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: bookedDateList));
  }
// x
  // void onPrevDateClicked({required String hiredBy}) async {
  //   await _getAllHiredEmployees(hiredBy: hiredBy);
  //   prevDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
  //   Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: prevDateList));
  // }
void onPrevDateClicked({required String hiredBy}) async {
  await _getAllHiredEmployees(hiredBy: hiredBy);

  if (prevDateList.isNotEmpty) {
    // Sort `prevDateList` by parsing `startDate` as a `DateTime`
    prevDateList.sort((a, b) {
      // DateTime startA = DateTime.parse("${a.startDate}-01");
      // DateTime startB = DateTime.parse("${b.startDate}-01");
      DateTime startA = DateTime.parse("${a.startDate}");
      DateTime startB = DateTime.parse("${b.startDate}");
      return startA.compareTo(startB);
    });

    // Open the bottom sheet with sorted data
    Get.bottomSheet(
      EmployeeHiredHistoryDetailsWidget(requestDateList: prevDateList),
    );
  }
}



Future<void> _getAllHiredEmployees({required String hiredBy}) async {
  CustomLoader.show(context!);
  
  // Fetching data from the API
  Either<CustomError, ClientMyEmployeesModel> response = await _apiHelper.getClientMyEmployees(
      hiredBy: hiredBy, 
      employeeId: Get.find<AppController>().user.value.employee?.id ?? '');

  CustomLoader.hide(context!);

  // Handling response and updating `prevDateList`
  response.fold(
    (CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, 
    (ClientMyEmployeesModel emp) {
      // Check if response has the expected data structure before accessing it
      if (emp.status == "success" &&
          emp.statusCode == 200 &&
          emp.details?.result != null &&
          emp.details!.result!.employee!.isNotEmpty &&
          emp.details!.result!.employee!.first.bookedDate != null &&
          emp.details!.result!.employee!.first.bookedDate!.isNotEmpty) {

        // Update `prevDateList` with fetched `previousDate`
        // prevDateList.value = emp.details!.result!.employee!.first.bookedDate! ?? [];
            // Get the current date for comparison
        DateTime currentDate = DateTime.now();
              // Filter out dates that are in the past
        List<RequestDateModel> filteredDates = emp.details!.result!.employee!.first.bookedDate!
          .where((requestDate) {
            log("req dates: ${requestDate.startDate} - ${requestDate.endDate}");
            DateTime startDate = DateTime.tryParse(requestDate.startDate ?? '') ?? DateTime.now();
            return startDate.isBefore(currentDate);  // Only keep future dates
            // return startDate.isAfter(currentDate) || startDate.isBefore(currentDate) || startDate.isAtSameMomentAs(currentDate);  // Only keep future dates
          }).toList();

        // Update `prevDateList` with filtered dates
        prevDateList.value = filteredDates;
        log("filtered dates: $filteredDates");
        prevDateList.refresh();
      } else {
        // Handle case where `previousDate` or other required fields are missing
        prevDateList.clear();
        Utils.showSnackBar(message: "No previous dates found for this employee.", isTrue: true);
      }
      if(prevDateList.isEmpty){
        Utils.showSnackBar(message: "No previous dates found for this employee.", isTrue: true);
      }
    },
  );
}

// Helper function to add suffix to day number (1 -> 1st, 2 -> 2nd, etc.)
String addDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return "${day}th";
  }
  switch (day % 10) {
    case 1:
      return "${day}st";
    case 2:
      return "${day}nd";
    case 3:
      return "${day}rd";
    default:
      return "${day}th";
  }
}

// Function to format date range with time (conditionally showing time)
String formatDateRangeWithTime(String? startDateStr, String? startTimeStr, String? endDateStr, String? endTimeStr) {
  // Parse start and end dates (without time)
  DateTime? startDate = DateTime.tryParse(startDateStr ?? '');
  DateTime? endDate = DateTime.tryParse(endDateStr ?? '');

  // If startDate or endDate are invalid (null), just use the date part without time
  if (startDate == null || endDate == null) {
    return 'Invalid Date(s)';
  }

  // Format dates with or without time based on availability of time strings
  String startFormatted = DateFormat('d MMM yyyy').format(startDate);  // Default date format (no time)
  String endFormatted = DateFormat('d MMM yyyy').format(endDate);

  // Add time if time strings are valid and non-empty
  if (startTimeStr != null && startTimeStr.isNotEmpty) {
    try {
      // Combine date and time if both are valid
      startDate = DateTime.parse("$startDateStr $startTimeStr");
      startFormatted = DateFormat('d MMM yyyy HH:mm').format(startDate);  // Add time to start date
    } catch (e) {
      // If parsing fails, just keep the date without time
      if (kDebugMode) {
        print("Error parsing start date and time: $e");
      }
    }
  }

  if (endTimeStr != null && endTimeStr.isNotEmpty) {
    try {
      // Combine date and time if both are valid
      endDate = DateTime.parse("$endDateStr $endTimeStr");
      endFormatted = DateFormat('d MMM yyyy HH:mm').format(endDate);  // Add time to end date
    } catch (e) {
      // If parsing fails, just keep the date without time
      if (kDebugMode) {
        print("Error parsing end date and time: $e");
      }
    }
  }

  // Add day suffix
  int startDay = startDate!.day;
  int endDay = endDate!.day;

  String startWithSuffix = startFormatted.replaceFirst("$startDay", addDaySuffix(startDay));
  String endWithSuffix = endFormatted.replaceFirst("$endDay", addDaySuffix(endDay));

  // Return the formatted range string with or without time
  return "from $startWithSuffix\nto $endWithSuffix";
}
  // Future<void> _getAllHiredEmployees({required String hiredBy}) async {
  //   CustomLoader.show(context!);
  //   Either<CustomError, ClientMyEmployeesModel> response = await _apiHelper.getClientMyEmployees(
  //       hiredBy: hiredBy, employeeId: Get.find<AppController>().user.value.employee?.id ?? '');
  //   CustomLoader.hide(context!);
  //   response.fold((CustomError customError) {
  //     Utils.errorDialog(context!, customError);
  //   }, (ClientMyEmployeesModel emp) {
  //     if (emp.status == "success" &&
  //         emp.statusCode == 200 &&
  //         emp.details != null &&
  //         emp.details?.result != null &&
  //         emp.details!.result!.isNotEmpty) {
  //       prevDateList.value = emp.details!.result?.first.employee?.first.previousDate ?? [];
  //       prevDateList.refresh();
  //     }
  //   });
  // }


}

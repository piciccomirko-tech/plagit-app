import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/models/employee_details.dart';
import 'package:mh/app/modules/client/client_dashboard/models/client_update_status_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/domain/repositories/check_in_check_out_repository.dart';
import '../../../../../domain/model/check_in_check_out_history_model.dart' as checkInHistory;
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/check_in_out_histories.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../client_home/controllers/client_home_controller.dart';
import '../../client_payment_and_invoice/controllers/client_payment_and_invoice_controller.dart';
import '../models/confirm_employee_task.dart';
import '../models/today_checkOutIn_details_model.dart';
import '../views/client_dashboard_history_view.dart';

class ClientDashboardController extends GetxController {
  BuildContext? context;

  final CheckInCheckOutRepository checkInCheckOutRepository=Get.find();

  final DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final DateFormat timeFormat = DateFormat("hh:mm a");
  final ApiHelper _apiHelper = Get.find();

  final AppController appController = Get.find();

  // Rx<SocketLocationModel> socketLocationModel = SocketLocationModel().obs;

  var candidates = <Employee>[].obs;
  RxInt candidateCount = 0.obs;

  RxBool todayEmployeeLoading = false.obs;
  final ClientHomeController clientHomeController = Get.find();

  final List<Map<String, dynamic>> fields = [
    {"name": MyStrings.employee.tr, "width": 143.0},
    {"name": MyStrings.checkIn.tr, "width": 100.0},
    {"name": MyStrings.checkOut.tr, "width": 100.0},
    {"name": MyStrings.breakTime.tr, "width": 100.0},
    {"name": MyStrings.totalHours.tr, "width": 100.0},
    {"name": MyStrings.chat.tr, "width": 100.0},
    {"name": MyStrings.more.tr, "width": 100.0},
  ];
  TextEditingController tecCheckIn = TextEditingController();
  TextEditingController tecCheckOut = TextEditingController();
  String? tmpCheckIn = '';
  String? tmpCheckOut = '';
  TextEditingController tecBreakTime = TextEditingController();
  TextEditingController tecTravelCost = TextEditingController();
  TextEditingController tecTips = TextEditingController();
  TextEditingController tecTotalHours = TextEditingController();
  TextEditingController tecTotalAmount = TextEditingController();
  TextEditingController tecComment2 = TextEditingController();
  // RxDouble grossTotalAmount = 0.0.obs;
  RxDouble originalAmount = 0.0.obs;
  Rx<ClientUpdateStatusModel> clientUpdateStatusModel =
      ClientUpdateStatusModel().obs;

  TextEditingController employeeCheckIn = TextEditingController();
  TextEditingController employeeCheckOut = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController tecTime = TextEditingController();
  TextEditingController tecComment = TextEditingController();

  Rx<DateTime> dashboardDate = DateTime.now().obs;
  RxString selectedDate = "".obs;
  RxBool isCheckOutHide = false.obs;
  RxBool loading = false.obs;
  RxBool loadingCheckInCheckOutHistory = false.obs;
  Rx<CheckInCheckOutHistory> checkInCheckOutHistory =
      CheckInCheckOutHistory().obs;
  final checkInCheckOutEditHistory =checkInHistory.CheckInCheckOutHistoryModel().obs;
  RxList<String> totalActiveEmployee = <String>[].obs;
  // Observable fields for calculated values
  RxString totalHours = "00:00:00".obs;
  RxString totalAmount = "0.00".obs;
  RxString vatAmount = "0.00".obs;
  RxString hourlyRate = "0.00".obs;
  RxString plagitPlatformFee = "0.00".obs;
  final DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");

  void togglePaymentStatusSwitch(int index,String userId, bool value) {
    var updateMap= {"id":userId,"employeePaymentStatus":value};
    if (value) {
      CustomDialogue.confirmation(
        context: Get.context!,
        title: "${MyStrings.confirm.tr}?",
        msg: "${MyStrings.sureWantTo.tr} ${MyStrings.pay.tr}?",
        confirmButtonText: MyStrings.yes.tr,
        onConfirm: () async {
          Get.back();
          //{"id":"67840c52076c304b749ad0d2","employeePaymentStatus":false}
          payToEmployeeByClient(updateMap);
        },
      );
    }else{
      payToEmployeeByClient(updateMap);
    }
  }

  Future<void> payToEmployeeByClient(Map<String, dynamic> data) async {
    loading.value = true;
    Either<CustomError, Response> response =
    await _apiHelper.updateEmployeePaymentByClient(data);
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (Response apiResponse) async {
      if (apiResponse.statusCode == 200 || apiResponse.statusCode == 201) {
        Utils.showSnackBar(message: (apiResponse.body)['message'], isTrue: true);
      } else {
        Utils.showSnackBar(message: 'Failed to pay', isTrue: false);
      }
      _fetchCheckInOutHistory();
    });
  }

  bool isCheckInChanged() {
    DateTime? tmpCheckInTime = tmpCheckIn?.trim().isNotEmpty == true
        ? format.parse(tmpCheckIn!.trim(), true)
        : null;
    DateTime? employeeCheckInTime = tecCheckIn.text.trim().isNotEmpty
        ? format.parse(tecCheckIn.text.trim(), true)
        : null;

    log("Parsed tmpCheckInTime: $tmpCheckInTime");
    log("Parsed employeeCheckInTime: $employeeCheckInTime");

    return tmpCheckInTime != employeeCheckInTime;
  }

  bool isCheckOutChanged() {
    DateTime? tmpCheckOutTime = tmpCheckOut?.trim().isNotEmpty == true
        ? format.parse(tmpCheckOut!.trim(), true)
        : null;
    DateTime? employeeCheckOutTime = tecCheckOut.text.trim().isNotEmpty
        ? format.parse(tecCheckOut.text.trim(), true)
        : null;

    log("Parsed tmpCheckOutTime: $tmpCheckOutTime");
    log("Parsed employeeCheckOutTime: $employeeCheckOutTime");

    return tmpCheckOutTime != employeeCheckOutTime;
  }

  /// Adjusts the checkOut time to the next day if it is smaller than the checkIn time.
  /// Updates the tecCheckOut field with the adjusted value.
  void ensureCheckOutTimeIsValid() {
    DateTime? checkInTime = tecCheckIn.text.trim().isNotEmpty
        ? dateTimeFormat.parse(tecCheckIn.text.trim())
        : null;
    DateTime? checkOutTime = tecCheckOut.text.trim().isNotEmpty
        ? dateTimeFormat.parse(tecCheckOut.text.trim())
        : null;

    if (checkInTime == null || checkOutTime == null) {
      log("Check-in or Check-out time is null. No adjustment made.");
      return;
    }

    Duration totalDuration = checkOutTime.difference(checkInTime);

    if (totalDuration.inHours >= 24) {
      log("Check-out time results in duration >= 24 hours. Adjusting check-out time.");
      checkOutTime = checkOutTime.subtract(const Duration(days: 1));
      tecCheckOut.text = dateTimeFormat.format(checkOutTime);
    } else if (totalDuration.isNegative) {
      log("Check-out time is before check-in. Adjusting to the next day.");
      checkOutTime = checkOutTime.add(const Duration(days: 1));
      tecCheckOut.text = dateTimeFormat.format(checkOutTime);
    }

    log("Adjusted Check-out time (if necessary): $checkOutTime");
  }

  Future<void> selectTimeOnly(
      BuildContext context, TextEditingController controller) async {
    // Use the existing time or the current time as the initial value
    DateTime initialDateTime =
        DateTime.tryParse(controller.text) ?? DateTime.now();
    TimeOfDay initialTime = TimeOfDay.fromDateTime(initialDateTime);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final DateTime updatedDateTime = DateTime(
        initialDateTime.year,
        initialDateTime.month,
        initialDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      controller.text = dateTimeFormat.format(updatedDateTime);

      if (controller == tecCheckIn || controller == tecCheckOut) {
        ensureCheckOutTimeIsValid(); // Adjust times
        calculateTotalHours(); // Recalculate total hours
      }
    }
  }

  void calculateTotalHours() {
    try {
      // Parse the check-in and check-out times
      DateTime checkInTime = dateTimeFormat.parse(tecCheckIn.text.trim());
      DateTime checkOutTime = dateTimeFormat.parse(tecCheckOut.text.trim());

      // Adjust check-out time if the duration exceeds or equals 24 hours
      Duration totalDuration = checkOutTime.difference(checkInTime);

      if (totalDuration.inHours >= 24) {
        log("Total duration is greater than or equal to 24 hours. Adjusting check-out time.");
        checkOutTime = checkOutTime.subtract(const Duration(days: 1));
        tecCheckOut.text =
            dateTimeFormat.format(checkOutTime); // Update the text field
        totalDuration = checkOutTime.difference(checkInTime); // Recalculate
      } else if (totalDuration.isNegative) {
        log("Total duration is negative. Adjusting check-out time.");
        checkOutTime = checkOutTime.add(const Duration(days: 1));
        tecCheckOut.text =
            dateTimeFormat.format(checkOutTime); // Update the text field
        totalDuration = checkOutTime.difference(checkInTime); // Recalculate
      }

      // Calculate the effective duration after applying the break time
      int breakMinutes = int.tryParse(tecBreakTime.text.trim()) ?? 0;
      Duration breakDuration = Duration(minutes: breakMinutes);
      Duration effectiveDuration = totalDuration - breakDuration;

      // Ensure the effective duration is not negative
      if (effectiveDuration.isNegative) {
        log("Effective duration is negative after applying break time. Setting break time to 0.");
        breakDuration = Duration.zero; // Reset break time to 0
        tecBreakTime.text = '0';
        effectiveDuration = totalDuration; // Recalculate effective duration
      }
      if (hourlyRate.value.isEmpty ||
          double.tryParse(hourlyRate.value.trim()) == null) {
        log("Invalid hourly rate: ${hourlyRate.value}");
        hourlyRate.value = "0"; // Default to 0 if invalid
      }

      var ratePerSecond = double.parse(hourlyRate.value.trim()) / 3600;
      var totalWorkingSeconds = (effectiveDuration.inHours * 3600) +
          (effectiveDuration.inMinutes.remainder(60) * 60) +
          effectiveDuration.inSeconds.remainder(60);
// Convert strings to numeric values with fallback to 0 if invalid
      double vat = double.tryParse(vatAmount.value.trim()) ?? 0.0;
      double tips = double.tryParse(tecTips.text.trim()) ?? 0.0;
      double travelCost = double.tryParse(tecTravelCost.text.trim()) ?? 0.0;
      double platformFee =
          double.tryParse(plagitPlatformFee.value.trim()) ?? 0.0;
//totalAmount.value='0';
      log('Total Working Seconds: $totalWorkingSeconds');
      log('Rate Per Second: $ratePerSecond');
      log('VAT: $vat');
      log('Tips: $tips');
      log('Travel Cost: $travelCost');
      log('Platform Fee: $platformFee');
// Calculate the total amount
      double total = (totalWorkingSeconds * ratePerSecond) +
          tips +
          travelCost +
          platformFee +
          vat;
      log("totalllllll: ${total}");
// Update totalAmount with the calculated value, formatted as a string
      totalAmount.value = total.toStringAsFixed(2);

      log("totalll: ${totalAmount.value} vat: ${vatAmount.value}");
      // Format and display the total hours
      totalHours.value = [
        effectiveDuration.inHours,
        effectiveDuration.inMinutes.remainder(60),
        effectiveDuration.inSeconds.remainder(60),
      ].map((seg) => seg.toString().padLeft(2, '0')).join(':');
    } catch (e) {
      log("Error calculating total hours: $e");
      totalHours.value = "00:00:00"; // Default if parsing fails
    }
  }

  // Function to calculate total amount
  void calculateTotalAmount() {
    double travelCost = double.tryParse(tecTravelCost.text) ?? 0;
    double tips = double.tryParse(tecTips.text) ?? 0;

    double total = originalAmount.value + travelCost + tips;
    totalAmount.value = total.toStringAsFixed(2);
  }

  String formatWorkedHours(String workedHour) {
    List<String> parts = workedHour.split(':');

    if (parts.length == 3) {
      String hours = parts[0];
      String minutes = parts[1];
      String seconds = parts[2];

      return '${hours}h:${minutes}m:${seconds}s';
    }

    // Return original format if it doesn't match expected "HH:MM:SS" format
    return workedHour;
  }

  @override
  void onInit() {
    super.onInit();

    onDatePicked(DateTime.now());

    // Set up listeners for real-time calculations
    tecCheckIn.addListener(calculateTotalHours);
    tecCheckOut.addListener(calculateTotalHours);
    tecBreakTime.addListener(calculateTotalHours);

    tecTravelCost.addListener(calculateTotalAmount);
    tecTravelCost.addListener(calculateTotalHours);
    tecTips.addListener(calculateTotalAmount);
    tecTips.addListener(calculateTotalHours);
    if (isCheckOutHide.value == false) {
      fetchTodayEmployees(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
      );
    }
    // grossTotalAmount.value =double.tryParse( totalAmount.value)??0.0;
  }

  Future<void> fetchTodayEmployees(
      {required DateTime startDate, required DateTime endDate}) async {
    todayEmployeeLoading.value = true;
    candidates.clear();

    // Call the API helper function with DateTime parameters directly
    final response = await _apiHelper.getTodayEmployeeList(
      startDate: startDate,
      endDate: endDate,
    );

    response.fold(
      (error) {
        log("error: ${error.msg}");
      },
      (data) {
        log("Data structure: ${data.result}");
        for (var employee in data.result ?? []) {
          candidates.add(employee);
        }
        candidateCount.value = candidates.length;
      },
    );

    todayEmployeeLoading.value = false;
  }


  @override
  void onClose() {
    // Dispose of controllers to avoid memory leaks
    tecCheckIn.dispose();
    tecCheckOut.dispose();
    tecBreakTime.dispose();
    tecTravelCost.dispose();
    tecTips.dispose();
    tecTotalHours.dispose();
    tecTotalAmount.dispose();
    tecComment.dispose();
    tecComment2.dispose();
    // Remove listeners when controller is disposed
    tecCheckIn.removeListener(calculateTotalHours);
    tecCheckOut.removeListener(calculateTotalHours);
    tecBreakTime.removeListener(calculateTotalHours);

    tecTravelCost.removeListener(calculateTotalAmount);
    tecTips.removeListener(calculateTotalAmount);
    super.onClose();
  }

  bool isMoreThan12Hours(DateTime? clientCheckOutTime) {
    if (clientCheckOutTime == null) {
      return false; // Return false if no check-out time is provided
    }

    // Get the current time
    DateTime currentTime = DateTime.now();

    // Calculate the duration difference
    Duration difference = currentTime.difference(clientCheckOutTime);

    // Check if the difference is 12 hours or more
    return difference.inHours >= 12;
  }

  void onDatePicked(DateTime dateTime) {
    dashboardDate.value = dateTime;
    dashboardDate.refresh();
    selectedDate.value = DateFormat('E, d MMM y').format(dashboardDate.value);
    _fetchCheckInOutHistory();
  }

  Future<void> _fetchCheckInOutHistory() async {
    loading.value = true;
    Either<CustomError, CheckInCheckOutHistory> response =
        await _apiHelper.getCheckInOutHistory(
      filterDate: dashboardDate.value.toString().split(" ").first,
      clientId: appController.user.value.client?.id ?? "",
    );
    loading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(
          context!, customError..onRetry = _fetchCheckInOutHistory);
    }, (CheckInCheckOutHistory checkInCheckOutHistory) async {
      this.checkInCheckOutHistory.value = checkInCheckOutHistory;
      countTotalActiveEmployees();
    });
  }

  void chatWithEmployee(
      {required EmployeeDetails employeeDetails, required String bookingId}) {
    CustomLoader.show(context!);
    _apiHelper
        .matchEmployee(employeeId: employeeDetails.employeeId ?? '')
        .then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseData) {
        if (responseData.status == "success" &&
            responseData.statusCode == 200 &&
            responseData.result == "true") {
          Get.toNamed(Routes.liveChat,
              arguments: LiveChatDataTransferModel(
                  toName: employeeDetails.name ?? "",
                  toId: employeeDetails.employeeId ?? "",
                  senderId: appController.user.value.client?.id ?? "",
                  bookedId: bookingId, //bookingId,
                  toProfilePicture:
                      (employeeDetails.profilePicture ?? "").imageUrl));
        } else {
          Utils.showSnackBar(
              message: MyStrings.cannotChatWithEmployeeNotHiredToday.tr,
              isTrue: false);
        }
      });
    });
  }

  void countTotalActiveEmployees() {
    if (checkInCheckOutHistory.value.checkInCheckOutHistory != null &&
        checkInCheckOutHistory.value.checkInCheckOutHistory!.isNotEmpty) {
      totalActiveEmployee.clear();
      for (CheckInCheckOutHistoryElement i
          in checkInCheckOutHistory.value.checkInCheckOutHistory!) {
        if (!totalActiveEmployee.contains(i.employeeId ?? '')) {
          totalActiveEmployee.add(i.employeeId ?? '');
        }
      }
      totalActiveEmployee.refresh();
    }
  }

  String? dateToTimeString(String? dateString) {
    if (dateString == null) return null;
    // Parse the fullDateTime string
    DateTime parsedFullDateTime = DateTime.parse(dateString);

    // Extract the time portion from the full DateTime object
    String formattedTime =
        "${parsedFullDateTime.hour.toString().padLeft(2, '0')}:${parsedFullDateTime.minute.toString().padLeft(2, '0')}:${parsedFullDateTime.second.toString().padLeft(2, '0')}";
    return formattedTime.replaceAll(' ', '');
  }

  bool areDatesEqual(String? date1, String? date2) {
    if (date1 == null || date2 == null) {
      // If either date is null, return false
      return false;
    }

    try {
      // Parse the fullDateTime string
      DateTime parsedFullDateTime = DateTime.parse(date1);

      // Extract the time portion from the full DateTime object
      String formattedTime =
          "${parsedFullDateTime.hour.toString().padLeft(2, '0')}:${parsedFullDateTime.minute.toString().padLeft(2, '0')}:${parsedFullDateTime.second.toString().padLeft(2, '0')}";

      // Compare the DateTime objects
      return formattedTime == date2;
    } catch (e) {
      // Log the error and return false if parsing fails
      debugPrint("Error comparing dates: $e");
      return false;
    }
  }

  Future<void> submitData({
    required String id,
    bool? checkIn,
    bool? checkOut,
    required String clientComment,
    required String clientCheckInTime,
    required String clientCheckOutTime,
    required int clientBreakTime,
    required double travelCost,
    required double tips,
  }) async {
    loading.value = true;
    CustomLoader.show(Get.context!);
    //{"id":"6798ee7d531d52f511e794e1","checkIn":false,"checkOut":false,"clientComment":"","clientCheckInTime":"2025-01-28 20:49:28","clientCheckOutTime":"2025-01-29 02:49:28","clientBreakTime":1,"tips":0,"travel_cost":0}
//{"id":"67913c9ae97bc4350befd425","checkIn":false,"checkOut":true,"clientComment":"test 3","clientCheckInTime":"2025-01-23 00:44:41","clientCheckOutTime":"2025-01-23 06:45:41","clientBreakTime":1,"tips":5,"travel_cost":10}
    // Construct the ClientUpdateStatusModel using parameters
    ClientUpdateStatusModel updateModel = ClientUpdateStatusModel(
      id: id,
      checkIn: checkIn,
      checkOut: checkOut,
      clientComment: clientComment,
      clientCheckInTime: clientCheckInTime,
      clientCheckOutTime: clientCheckOutTime,
      clientBreakTime: clientBreakTime,
      travelCost: travelCost,
      tips: tips,
    );

    log("Payload being sent: ${updateModel.toJson()}");

    // Call the update function in the controller
    Either<CustomError, Response> response = await _apiHelper
        .updateCheckInOutByClient(clientUpdateStatusModel: updateModel);
    log("response: ${response.asRight.body}");
    // Handle response
    response.fold(
      (error) {
        if (Get.isBottomSheetOpen!) {
          Get.back();
        }
        Utils.showSnackBar(
            message: "Failed to update status: ${error.msg}", isTrue: false);
        loading.value = false;
      },
      (success) {
        // Get.back(); // Close modal after successful update
        if (Get.isBottomSheetOpen!) {
          Get.back();
        }
        Utils.showSnackBar(
            message: "Status updated successfully.", isTrue: true);

        // Get.back(); // Close modal after successful update
        // Get.back();
        loading.value = false;
      },
      // Get.back(); // Close modal after successful update
      // Get.back();
    );

    // Hide loader regardless of the outcome
    CustomLoader.hide(Get.context!);
    _fetchCheckInOutHistory();
  }

  Future<void> onConfirmTask(
      ConfirmEmployeeTaskModel confirmEmployeeTaskModel) async {
    log("Sending accept booking request: ${confirmEmployeeTaskModel.toJson()}");
    CustomLoader.show(Get.context!);
    // Call the API request
    Either<CustomError, Response> response =
        await _apiHelper.confirmEmployeeTask(
      confirmEmployeeTaskModel: confirmEmployeeTaskModel,
    );
    log("confirm response: ${response.asRight.body}");
// log("confirm response left: ${response.asLeft.msg}");
    CustomLoader.hide(Get.context!);
    // Get.back();
    // Handle response
    response.fold(
      (error) {
        Utils.showSnackBar(
            message: "Failed to accept Employee: ${error.msg}", isTrue: false);
      },
      (success) {
        Utils.showSnackBar(
            message: " Employee Accepted Successfully.", isTrue: true);
      },
    );
    Get.find<ClientPaymentAndInvoiceController>().clientPaymentInvoiceMethod();
    _fetchCheckInOutHistory();
    //Get.back();
  }

  Future<void> viewCheckInCheckOutHistory(String currentHiredEmployeeId) async {
    if(loading.value==true) {
      return;
    }else {
      Get.to(() => ClientDashboardHistoryView());
      _fetchCheckInOutUpdateHistory(currentHiredEmployeeId);
    }
  }

  Future<void> _fetchCheckInOutUpdateHistory(String currentHiredEmployeeId) async {
    loadingCheckInCheckOutHistory(true);

    final response = await checkInCheckOutRepository.getCheckInOutUpdateHistory(currentHiredEmployeeId: currentHiredEmployeeId);

    if (response?.status != 'success') {
      throw Exception('Failed to get history ');
    } else {
      checkInCheckOutEditHistory.value = response!;
      // debugPrint('New social call done with length ${socialPostList.length}');
    }
    loadingCheckInCheckOutHistory(false);
  }
}

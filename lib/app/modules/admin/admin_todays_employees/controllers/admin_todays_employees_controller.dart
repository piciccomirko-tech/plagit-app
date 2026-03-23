

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../models/admin_todays_employee_response_model.dart' as atel;

class AdminTodaysEmployeesController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxList<atel.Employee> todaysEmployeesList = <atel.Employee>[].obs;
  RxBool todaysEmployeesDataLoaded = false.obs;
  final ApiHelper _apiHelper = Get.find();
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  BuildContext? context;

  ///Restaurants
  Rx<Employees> clients = Employees().obs;
  RxList<String> restaurants = ["Select Business"].obs;
  RxBool clientLoading = true.obs;
  RxString selectedRestaurantName = 'Select Business'.obs;

  ///Employees
  RxString selectedEmployeeName = 'All Employees'.obs;
  Rx<Employees> employees = Employees().obs;
  RxList<String> todaysEmployees = ["All Employees"].obs;
  RxBool employeeDataLoading = true.obs;


RxMap<String, String> restaurantMap = {"All Restaurants": ""}.obs;
RxString selectedRestaurantId = ''.obs; // To store the selected restaurant's _id

  @override
  void onInit() async {
    await _fetchClients();
    await _getTodaysEmployees();
    super.onInit();
  }

  Future<void> _getTodaysEmployees() async {
    todaysEmployeesDataLoaded.value = false;
    Either<CustomError, atel.AdminTodaysEmployeeResponseModel> response = await _apiHelper.getTodaysEmployeesFromAdmin(
        startDate: startDate.value.toString().substring(0, 10),
        endDate: endDate.value.toString().substring(0, 10),
        hiredBy: selectedRestaurantId.value
        // hiredBy: '64a81b6dedf0f2cc079d19a4'
        );
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (atel.AdminTodaysEmployeeResponseModel data) async {
      if (data.statusCode == 200 && data.status == "success") {
        todaysEmployeesList.value = data.details?.result?.employee ?? [];
        todaysEmployeesDataLoaded.value = true;
      }
    });
  }

  void onDatePicked(DateTime dateTime) {
    startDate.value = dateTime;
    endDate.value = dateTime;
    startDate.refresh();
    endDate.refresh();

    _getTodaysEmployees();
  }

  void onDateRangePicked(DateTimeRange dateTime) {
    startDate.value = dateTime.start;
    endDate.value = dateTime.end;
    startDate.refresh();
    endDate.refresh();

    _getTodaysEmployees();
  }

  // void onClientChange(String? value) {
  //   if (value == restaurants.first) {
  //     selectedRestaurantName.value = 'All Restaurants';
  //   } else {
  //     selectedRestaurantName.value =
  //         (clients.value.users ?? []).firstWhere((element) => element.restaurantName == value).restaurantName ?? '';
  //   }

  //   _getTodaysEmployees();
  // }

  Future<void> _fetchClients() async {
    clientLoading.value = true;

    await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT").then((Either<CustomError, Employees> response) {
      clientLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = _fetchClients);
      }, (Employees clients) {
        this.clients.value = clients;
        this.clients.refresh();

        // restaurants.addAll((clients.users ?? []).map((e) => e.restaurantName!).toList());
          // Clear and repopulate the map
      restaurantMap.clear();
      restaurantMap["Select Business"] = ""; // Default option
      for (var user in (clients.users ?? [])) {
        if (user.restaurantName != null && user.id != null) {
          restaurantMap[user.restaurantName!] = user.id!;
        }
      }

      // Update the restaurants list for dropdown
      restaurants.value = restaurantMap.keys.toList();
      selectedRestaurantId.value = restaurantMap.values.toList()[1];
      });
    });
  }
void onClientChange(String? selectedName) {
  if (selectedName != null) {
    selectedRestaurantName.value = selectedName;
    selectedRestaurantId.value = restaurantMap[selectedName] ?? '';
  }
  if(selectedName?.toLowerCase() != 'Select Business'.toLowerCase()) {
      _getTodaysEmployees();
    }
  }


  // String getTime({required int index, required String tag}) {
  //   final List<RequestDateModel> bookingDateList = todaysEmployeesList[index].bookedDate ?? [];
  //   DateTime currentDateTime = DateTime.parse(startDate.value.toString().split(' ').first);
  //
  //   for (RequestDateModel bookingDate in bookingDateList) {
  //     log("booking date strat: ${bookingDate.startDate}");
  //     log("booking date strat: ${bookingDate.endDate}");
  //     DateTime startDate = DateTime.parse(bookingDate.startDate!.split(' ').first);
  //     DateTime endDate = DateTime.parse(bookingDate.endDate!.split(' ').first);
  //
  //     // if ((currentDateTime.isAfter(startDate) || currentDateTime.isAtSameMomentAs(startDate)) &&
  //     //         (currentDateTime.isBefore(endDate) ||
  //     //     currentDateTime.isAtSameMomentAs(endDate))) {
  //       return tag == 'start' ? bookingDate.startTime ?? '' : bookingDate.endTime ?? '';
  //     // }
  //   }
  //   return 'N/A';
  // }

  void onFilterPressed() {
    scaffoldKey.currentState?.openEndDrawer();
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/models/todays_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class AdminTodaysEmployeesController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxList<TodaysEmployeesDataModel> todaysEmployeesList = <TodaysEmployeesDataModel>[].obs;
  RxBool todaysEmployeesDataLoaded = false.obs;
  final ApiHelper _apiHelper = Get.find();
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;
  BuildContext? context;

  ///Restaurants
  Rx<Employees> clients = Employees().obs;
  RxList<String> restaurants = ["All Restaurants"].obs;
  RxBool clientLoading = true.obs;
  RxString selectedRestaurantName = 'All Restaurants'.obs;

  ///Employees
  RxString selectedEmployeeName = 'All Employees'.obs;
  Rx<Employees> employees = Employees().obs;
  RxList<String> todaysEmployees = ["All Employees"].obs;
  RxBool employeeDataLoading = true.obs;

  @override
  void onInit() async {
    await _fetchClients();
    await _fetchEmployees();
    await _getTodaysEmployees();
    super.onInit();
  }

  Future<void> _getTodaysEmployees() async {
    todaysEmployeesDataLoaded.value = false;
    Either<CustomError, TodaysEmployeesModel> response = await _apiHelper.getTodaysEmployees(
        startDate: startDate.value.toString().substring(0, 10),
        endDate: endDate.value.toString().substring(0, 10),
        employeeName: selectedEmployeeName.value,
        restaurantName: selectedRestaurantName.value);
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry);
    }, (TodaysEmployeesModel data) async {
      if (data.statusCode == 200 && data.status == "success") {
        todaysEmployeesList.value = data.data ?? [];
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

  void onClientChange(String? value) {
    if (value == restaurants.first) {
      selectedRestaurantName.value = 'All Restaurants';
    } else {
      selectedRestaurantName.value =
          (clients.value.users ?? []).firstWhere((element) => element.restaurantName == value).restaurantName ?? '';
    }

    _getTodaysEmployees();
  }

  Future<void> _fetchClients() async {
    clientLoading.value = true;

    await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT").then((Either<CustomError, Employees> response) {
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

  void onEmployeeChange(String? value) {
    if (value == todaysEmployees.first) {
      selectedEmployeeName.value = 'All Employees';
    } else {
      selectedEmployeeName.value =
          (employees.value.users ?? []).firstWhere((element) => element.firstName == value).firstName ?? '';
    }

    _getTodaysEmployees();
  }

  Future<void> _fetchEmployees() async {
    employeeDataLoading.value = true;

    await _apiHelper.getAllUsersFromAdmin(requestType: "EMPLOYEE").then((Either<CustomError, Employees> response) {
      employeeDataLoading.value = false;

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry);
      }, (Employees e) {
        employees.value = e;
        employees.refresh();

        todaysEmployees.addAll((e.users ?? []).map((Employee e) => e.firstName ?? '').toList());
      });
    });
  }

  String getTime({required int index, required String tag}) {
    final List<RequestDateModel> bookingDateList = todaysEmployeesList[index].bookedDate ?? [];
    DateTime currentDateTime = DateTime.parse(startDate.value.toString().split(' ').first);

    for (RequestDateModel bookingDate in bookingDateList) {
      DateTime startDate = DateTime.parse(bookingDate.startDate!.split(' ').first);
      DateTime endDate = DateTime.parse(bookingDate.endDate!.split(' ').first);

      if ((currentDateTime.isAfter(startDate) || currentDateTime.isAtSameMomentAs(startDate)) &&
              currentDateTime.isBefore(endDate) ||
          currentDateTime.isAtSameMomentAs(endDate)) {
        return tag == 'start' ? bookingDate.startTime ?? '' : bookingDate.endTime ?? '';
      }
    }
    return '';
  }

  void onFilterPressed() {
    scaffoldKey.currentState?.openEndDrawer();
  }
}

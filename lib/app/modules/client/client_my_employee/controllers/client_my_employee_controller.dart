import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mh/app/common/app_info/app_credentials.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/location_controller.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/live_location/controllers/live_location_controller.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/socket_location_model.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../common/shortlist_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;

class ClientMyEmployeeController extends GetxController {
  BuildContext? context;

  Rx<SocketLocationModel> socketLocationModel = SocketLocationModel().obs;
  final ApiHelper _apiHelper = Get.find();
  final ShortlistController shortlistController = Get.find();
  final AppController appController = Get.find<AppController>();
  final ClientHomeController clientHomeController = Get.find<ClientHomeController>();
  RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  RxBool isLoading = true.obs;
  RxString startDate = DateTime.now().toString().split(" ").first.obs;
  RxString endDate = DateTime.now().toString().split(" ").first.obs;
  Rx<DateTime> selectedDate = DateTime.now().obs;
  RxList<RequestDateModel> prevDateList = <RequestDateModel>[].obs;
  io.Socket? socket;

  RxList<LatLng> polylineCoordinates = <LatLng>[].obs;
  @override
  void onInit() async {
    await _getAllHiredEmployees();
    connectWithSocket();
    super.onInit();
  }

  @override
  void onClose() async {
    socket?.disconnect();
    socket?.dispose();
    super.onInit();
  }

  Future<void> _getAllHiredEmployees() async {
    print('destination: ${appController.user.value.client?.lat}, ${appController.user.value.client?.long}');
    isLoading.value = true;
    Either<CustomError, ClientMyEmployeesModel> response = await _apiHelper.getClientMyEmployees(
        startDate: startDate.value, endDate: endDate.value, hiredBy: appController.user.value.client?.id ?? '');
    isLoading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ClientMyEmployeesModel emp) async {
      if (emp.status == "success" &&
          emp.statusCode == 200 &&
          emp.details != null &&
          (emp.details?.result ?? []).isNotEmpty) {
        employees.value = emp.details?.result?.first.employee ?? [];
        for (EmployeeModel i in employees) {
          print('origin: ${i.employeeDetails?.lat}, ${i.employeeDetails?.long}');
          print('origin: ${AppCredentials.googleMapKey}');
          PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
              AppCredentials.googleMapKey,
              PointLatLng(
                  double.parse(i.employeeDetails?.lat ?? "0.0"), double.parse(i.employeeDetails?.long ?? "0.0")),
              PointLatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
                  double.parse(appController.user.value.client?.long ?? "0.0")));

          socketLocationModel.value.distance = ((result.distanceValue ?? 0) / 1609).toStringAsFixed(2);
          i.employeeDetails?.distance = ((result.distanceValue ?? 0) / 1609).toStringAsFixed(2);

          if (result.points.isNotEmpty) {
            for (var point in result.points) {
              polylineCoordinates.add(LatLng(point.latitude, point.longitude));
            }
          }
        }
        polylineCoordinates.refresh();
        employees.refresh();
        print('ClientMyEmployeeController._getAllHiredEmployees: ${polylineCoordinates.length}');
      }
    });
  }

  void onCalenderClick({required List<RequestDateModel> bookedDateList}) {
    bookedDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: bookedDateList);
  }

  void chatWithEmployee({required String employeeName, required String employeeId}) {
    CustomLoader.show(context!);
    _apiHelper.matchEmployee(employeeId: employeeId).then((Either<CustomError, CommonResponseModel> response) {
      CustomLoader.hide(context!);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (CommonResponseModel responseData) {
        if (responseData.status == "success" && responseData.statusCode == 200 && responseData.result == "true") {
          Get.toNamed(Routes.clientEmployeeChat, arguments: {
            MyStrings.arg.receiverName: employeeName,
            MyStrings.arg.fromId: appController.user.value.userId,
            MyStrings.arg.toId: employeeId,
            MyStrings.arg.clientId: appController.user.value.userId,
            MyStrings.arg.employeeId: employeeId,
          });
        } else {
          Utils.showSnackBar(
              message: 'You cannot chat with this employee \nbecause he is not hired today', isTrue: false);
        }
      });
    });
  }

  void calculatePreviousDates({required List<RequestDateModel> bookedDateList}) {
    for (var i in bookedDateList) {
      if (DateTime.parse(i.endDate ?? '').toString().substring(0, 10) == DateTime.now().toString().substring(0, 10)) {
        i.status = '';
      } else if (DateTime.parse(i.endDate ?? '').isBefore(DateTime.now())) {
        i.status = 'Done';
      } else {
        i.status = '';
      }
    }
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: bookedDateList));
  }

  void onRadioButtonTap(String value) {
    startDate.value = value;
    endDate.value = value;
    if (value.isNotEmpty) {
      _selectDate(context!);
    }
    _getAllHiredEmployees();
  }

  void onDatePicked(DateTime dateTime) {
    selectedDate.value = dateTime;
    startDate.value = dateTime.toString().split(' ').first;
    endDate.value = dateTime.toString().split(' ').first;
    startDate.refresh();
    endDate.refresh();

    _getAllHiredEmployees();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.parse(startDate.value)) {
      onDatePicked(picked);
    }
  }

  void onPrevDatePressed({required String employeeId}) async {
    await _getPreviousDate(employeeId: employeeId);
    if (prevDateList.isNotEmpty) {
      prevDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    }
    Get.bottomSheet(EmployeeHiredHistoryDetailsWidget(requestDateList: prevDateList));
  }

  Future<void> _getPreviousDate({required String employeeId}) async {
    CustomLoader.show(context!);
    Either<CustomError, ClientMyEmployeesModel> response = await _apiHelper.getClientMyEmployees(
        hiredBy: appController.user.value.client?.id ?? '', employeeId: employeeId);
    CustomLoader.hide(context!);
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ClientMyEmployeesModel emp) {
      if (emp.status == "success" &&
          emp.statusCode == 200 &&
          emp.details != null &&
          emp.details?.result != null &&
          emp.details!.result!.isNotEmpty) {
        prevDateList.value = emp.details!.result?.first.employee?.first.previousDate ?? [];
        prevDateList.refresh();
      }
    });
  }

  void connectWithSocket() {
    try {
      socket = io.io("wss://server.mhpremierstaffingsolutions.com", <String, dynamic>{
        "transports": ["websocket"],
        "autoConnect": false
      });
      socket?.connect();
      socket?.onConnect((_) {
        socket?.on('location:move', (data) async {
          socketLocationModel.value = SocketLocationModel.fromJson(data);
          for (EmployeeModel i in employees) {
            if (i.employeeId == socketLocationModel.value.sender) {
              polylineCoordinates.clear();

              PolylinePoints polylinePoints = PolylinePoints();
              PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
                  AppCredentials.googleMapKey,
                  PointLatLng(socketLocationModel.value.cords?.latitude ?? 0.0,
                      socketLocationModel.value.cords?.longitude ?? 0.0),
                  PointLatLng(double.parse(appController.user.value.client?.lat ?? "0.0"),
                      double.parse(appController.user.value.client?.long ?? "0.0")));

              socketLocationModel.value.employeeName = i.employeeDetails?.name ?? "";
              socketLocationModel.value.employeePicture = (i.employeeDetails?.profilePicture ?? "").imageUrl;
              socketLocationModel.value.distance = ((result.distanceValue ?? 0) / 1609).toStringAsFixed(2);
              i.employeeDetails?.distance = socketLocationModel.value.distance;
              socketLocationModel.value.currentPosition = result.endAddress;
              socketLocationModel.value.totalEta = parseDurationInMinutes(durationText: result.duration ?? "");

              if (result.points.isNotEmpty) {
                for (var point in result.points) {
                  polylineCoordinates.add(LatLng(point.latitude, point.longitude));
                }
              }
            }
          }
          if (Get.isRegistered<LiveLocationController>() == true) {
            Get.find<LiveLocationController>().loadMarkers();
          }
          polylineCoordinates.refresh();
          employees.refresh();
          socketLocationModel.refresh();
        });
      });
    } catch (_) {}
  }

  void onMapsPressed() {
    Get.toNamed(Routes.liveLocation);
  }

  int parseDurationInMinutes({required String durationText}) {
    if (durationText.isNotEmpty) {
      List<String> parts = durationText.split(' ');

      int hours = 0;
      int minutes = 0;

      for (int i = 0; i < parts.length; i += 2) {
        int value = int.parse(parts[i]);
        String unit = parts[i + 1].toLowerCase();

        if (unit == 'hour' || unit == 'hours') {
          hours += value;
        } else if (unit == 'min' || unit == 'mins' || unit == 'minute' || unit == 'minutes') {
          minutes += value;
        }
      }

      return hours * 60 + minutes;
    } else {
      return 0;
    }
  }
}

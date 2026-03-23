import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/requested_employees.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import '../../../../common/utils/exports.dart';
import '../../../../routes/app_pages.dart';

class AdminClientRequestController extends GetxController {
  BuildContext? context;
  final ApiHelper _apiHelper = Get.find();
  final AppController appController = AppController();

  RxBool loading = true.obs;
  Rx<RequestedEmployees> requestedEmployees = RequestedEmployees().obs;

  int numberOfRequestFromClient = 0;
  String requestId = '';

  @override
  void onInit() {
    super.onInit();
    fetchRequest();
  }

  int getTotalRequestByPosition(int index) {
    return (requestedEmployees
                .value.requestEmployeeList?[index].clientRequestDetails ??
            [])
        .fold(
            0,
            (previousValue, element) =>
                previousValue + (element.numOfEmployee ?? 0));
  }

  int getTotalSuggestByPosition(int index) {
    return requestedEmployees.value.requestEmployeeList?[index]
            .suggestedEmployeeDetails?.length ??
        0;
  }
bool detectSuggestedEmployees(String userId) {
  var employeeList = requestedEmployees.value.requestEmployeeList;
  
  if (employeeList != null) {
    for (var employee in employeeList) {
      var suggestedEmployees = employee.suggestedEmployeeDetails;
      log("suggested length: ${suggestedEmployees?.length}");
      if (suggestedEmployees != null && suggestedEmployees.any((emp) => emp.id == userId)) {
        return true;
      }
    }
  }
  
  return false;
}


  int get getTotalSuggestLeft {
    int total = 0;

    for (int i = 0;
        i < (requestedEmployees.value.requestEmployeeList ?? []).length;
        i++) {
      total += getTotalRequestByPosition(i) - getTotalSuggestByPosition(i);
    }

    return total;
  }

  void calculateNumberOfRequestFromClient() {
    numberOfRequestFromClient = 0;
    for (var i in requestedEmployees.value.requestEmployeeList!) {
      if (i.suggestedEmployeeDetails!.isEmpty) {
        numberOfRequestFromClient += 1;
      }
    }
  }

  String getRestaurantName(int index) {
    return requestedEmployees
            .value.requestEmployeeList?[index].clientDetails?.restaurantName ??
        "-";
  }

  String getSuggested(int index) {
    int total = getTotalRequestByPosition(index);
    int suggested = getTotalSuggestByPosition(index);
    return "Already suggested $suggested of $total";
  }

  void onItemClick(int index) {
    Get.toNamed(Routes.adminClientRequestPositions, arguments: {
      MyStrings.arg.data: index,
    });
  }

  void onCancelClick({required String requestId}) {
    CustomDialogue.confirmation(
      context: context!,
      title: MyStrings.confirmCancellation.tr ,
      msg: MyStrings.areYouSureCancelRequest.tr,
      confirmButtonText: MyStrings.yes.toUpperCase().tr,
      onConfirm: () async {
        Get.back(); // hide confirmation dialog

        CustomLoader.show(context!);

        await _apiHelper
            .cancelClientRequestFromAdmin(requestId: requestId)
            .then((response) {
          CustomLoader.hide(context!);

          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (BookingHistoryModel response) async {
            if ((response.statusCode == 200 || response.statusCode == 201) &&
                response.status == 'success') {
              fetchRequest();
            }
          });
        });
      },
    );
  }

  Future<void> fetchRequest() async {
    loading.value = true;
  
    Either<CustomError, RequestedEmployees> response =
        await _apiHelper.getRequestedEmployees(clientId:appController.user.value.userId); 
    loading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (RequestedEmployees requestedEmployees) async {
      // this.requestedEmployees.value = requestedEmployees;
        //  List<RequestedEmployeeModel> filteredList = requestedEmployees
        // .requestEmployeeList
        // ?.where((employee) =>
        //     employee.clientDetails?.countryName ==
        //     appController.user.value.admin?.countryName)
        // .toList() ?? [];
            // Update the requestedEmployees observable
    // this.requestedEmployees.value = RequestedEmployees(
    //   status: requestedEmployees.status,
    //   statusCode: requestedEmployees.statusCode,
    //   message: requestedEmployees.message,
    //   total: filteredList.length,
    //   count: filteredList.length,
    //   next: requestedEmployees.next,
    //   requestEmployeeList: filteredList,
    // );
 this.requestedEmployees.value = requestedEmployees;
       this.requestedEmployees.refresh();
      calculateNumberOfRequestFromClient();
    });
  }
}

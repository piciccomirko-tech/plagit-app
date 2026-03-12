import 'package:dartz/dartz.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employee_full_details.dart';
import 'package:mh/app/modules/employee/employee_home/models/booking_history_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/requested_employees.dart';
import '../../client_home/controllers/client_home_controller.dart';
import '../../common/shortlist_controller.dart';

class ClientSuggestedEmployeesController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  final ClientHomeController clientHomeController = Get.find();
  final ShortlistController shortlistController = Get.find();

  String requestId = '';

  List<ClientRequestDetail> getUniquePositions() {
    List<String> ids = [];
    List<ClientRequestDetail> idsWithCounts = [];

    for (RequestedEmployeeModel element in clientHomeController.requestedEmployees.value.requestEmployeeList ?? []) {
      for (ClientRequestDetail positions in element.clientRequestDetails ?? []) {
        if (ids.contains(positions.id)) {
          idsWithCounts[ids.indexOf(positions.id!)].numOfEmployee =
              (positions.numOfEmployee ?? 0) + (idsWithCounts[ids.indexOf(positions.id!)].numOfEmployee ?? 0);
        } else {
          ids.add(positions.id!);
          idsWithCounts.add(positions);
        }
      }
    }

    return idsWithCounts;
  }

  List<SuggestedEmployeeDetail> getUniquePositionEmployees(String positionId) {
    List<SuggestedEmployeeDetail> employees = [];

    for (RequestedEmployeeModel element in clientHomeController.requestedEmployees.value.requestEmployeeList ?? []) {
      for (SuggestedEmployeeDetail employee in element.suggestedEmployeeDetails ?? []) {
        if (employee.positionId == positionId) {
          employees.add(employee);
        }
      }
    }

    return employees;
  }

  void onEmployeeItemClick({required String employeeId}) {
    CustomLoader.show(context!);
    _apiHelper.employeeFullDetails(employeeId).then((Either<CustomError, EmployeeFullDetails> responseData) {
      CustomLoader.hide(context!);
      responseData.fold((CustomError l) {
        Logcat.msg(l.msg);
      }, (EmployeeFullDetails r) {
        Get.toNamed(Routes.employeeDetails, arguments: {
          MyStrings.arg.data: r.details,
          MyStrings.arg.showAsAdmin: false,
          MyStrings.arg.fromWhere: MyStrings.arg.clientSuggestedViewText
        });
      });
    });
  }

  void onCancelClick({required String employeeId}) {
    CustomDialogue.confirmation(
      context: context!,
      title: "Confirm Cancellation",
      msg: "Are you sure you want to cancel this suggestion?",
      confirmButtonText: "YES",
      onConfirm: () async {
        Get.back(); // hide confirmation dialog

        CustomLoader.show(context!);
        findRequestId(employeeId: employeeId);
        await _apiHelper
            .cancelEmployeeSuggestionFromAdmin(employeeId: employeeId, requestId: requestId)
            .then((response) {
          CustomLoader.hide(context!);
          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (BookingHistoryModel response) async {
            if ((response.statusCode == 200 || response.statusCode == 201) && response.status == 'success') {
              clientHomeController.homeMethods();
            }
          });
        });
      },
    );
  }

  void findRequestId({required String employeeId}) {
    for (var i in clientHomeController.requestedEmployees.value.requestEmployeeList!) {
      for (var v in i.suggestedEmployeeDetails!) {
        if (v.employeeId == employeeId) {
          requestId = i.id ?? "";
          return;
        }
      }
    }
  }

  String getRequestId({required String employeeId}) {
    for (var i in clientHomeController.requestedEmployees.value.requestEmployeeList!) {
      for (var v in i.suggestedEmployeeDetails!) {
        if (v.employeeId == employeeId) {
          return i.id ?? "";
        }
      }
    }
    return '';
  }
}

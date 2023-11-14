import 'package:get/get.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee_hired_history/widgets/employee_hired_history_details_widget.dart';

class EmployeeHiredHistoryController extends GetxController {
  final EmployeeHomeController employeeHomeController = Get.find<EmployeeHomeController>();

  void onDetailsClick({required List<RequestDateModel> bookedDateList}) {
    bookedDateList.sort((RequestDateModel a, RequestDateModel b) => a.startDate!.compareTo(b.startDate!));
    calculatePreviousDates(bookedDateList: bookedDateList);
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
}

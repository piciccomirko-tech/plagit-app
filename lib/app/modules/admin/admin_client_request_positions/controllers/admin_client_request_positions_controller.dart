import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/admin/admin_client_request/controllers/admin_client_request_controller.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/requested_employees.dart';
import '../../../../routes/app_pages.dart';

class AdminClientRequestPositionsController extends GetxController {

  BuildContext? context;

  final AppController appController = Get.find();
  final AdminClientRequestController adminClientRequestController = Get.find<AdminClientRequestController>();

  late int selectedIndex;

  RxList<DropdownItem> positions = <DropdownItem>[].obs;

  @override
  void onInit() {
    selectedIndex = Get.arguments[MyStrings.arg.data];

    for (DropdownItem element in appController.allActivePositions) {
      for(ClientRequestDetail requestedPosition in adminClientRequestController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []) {
        if(requestedPosition.positionId == element.id) {
          positions.add(element);
        }
      }
    }

    super.onInit();

  }


  String getSuggested(DropdownItem position) {
    int total = (adminClientRequestController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []).firstWhere((element) => element.positionId == position.id).numOfEmployee ?? 0;
    int suggested = (adminClientRequestController.requestedEmployees.value.requestEmployeeList?[selectedIndex].suggestedEmployeeDetails ?? []).where((element) => element.positionId == position.id).length;
    return "$suggested of $total";
  }

  void onPositionClick(DropdownItem position) {
    ClientRequestDetail clientRequestDetail = (adminClientRequestController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []).firstWhere((element) => element.positionId == position.id);
    Get.toNamed(Routes.adminClientRequestPositionEmployees, arguments: {
      MyStrings.arg.data : clientRequestDetail,
    });
  }



}

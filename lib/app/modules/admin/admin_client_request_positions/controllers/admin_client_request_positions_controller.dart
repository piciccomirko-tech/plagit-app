import 'package:mh/app/models/dropdown_item.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/requested_employees.dart';
import '../../../../routes/app_pages.dart';
import '../../admin_home/controllers/admin_home_controller.dart';

class AdminClientRequestPositionsController extends GetxController {

  BuildContext? context;

  final AppController appController = Get.find();
  final AdminHomeController adminHomeController = Get.find();

  late int selectedIndex;

  RxList<DropdownItem> positions = <DropdownItem>[].obs;

  @override
  void onInit() {
    selectedIndex = Get.arguments[MyStrings.arg.data];

    for (DropdownItem element in appController.allActivePositions) {
      for(ClientRequestDetail requestedPosition in adminHomeController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []) {
        if(requestedPosition.positionId == element.id) {
          positions.add(element);
        }
      }
    }

    super.onInit();

  }


  String getSuggested(DropdownItem position) {
    int total = (adminHomeController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []).firstWhere((element) => element.positionId == position.id).numOfEmployee ?? 0;
    int suggested = (adminHomeController.requestedEmployees.value.requestEmployeeList?[selectedIndex].suggestedEmployeeDetails ?? []).where((element) => element.positionId == position.id).length;
    return "$suggested of $total";
  }

  void onPositionClick(DropdownItem position) {
    ClientRequestDetail clientRequestDetail = (adminHomeController.requestedEmployees.value.requestEmployeeList?[selectedIndex].clientRequestDetails ?? []).firstWhere((element) => element.positionId == position.id);
    Get.toNamed(Routes.adminClientRequestPositionEmployees, arguments: {
      MyStrings.arg.data : clientRequestDetail,
    });
  }



}

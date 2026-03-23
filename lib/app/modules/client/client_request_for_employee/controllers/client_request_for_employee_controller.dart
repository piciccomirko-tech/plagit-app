import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_dialog.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../repository/api_helper.dart';
import '../../client_home/controllers/client_home_controller.dart';

class ClientRequestForEmployeeController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper apiHelper = Get.find();
  final ClientHomeController clientHomeController = Get.find();

  RxList<int> selectedEmployee = <int>[].obs;

  List<int> dropdownValues = [];
  // Total count observable
  RxInt totalEmployeeCount = 0.obs;
  @override
  void onInit() {
    for (int i = 0; i <= 50; i++) {
      dropdownValues.add(i);
    }

    for (int i = 0; i < appController.allActivePositions.length; i++) {
      selectedEmployee.add(0);
    }
     // Recalculate total count whenever selectedEmployee changes
    ever(selectedEmployee, (_) {
      totalEmployeeCount.value = selectedEmployee.reduce((a, b) => a + b);
    });
    super.onInit();
  }

  void onDropdownChange(int value, int index) {
    selectedEmployee[index] = value;
  }

  Future<void> onRequestPressed() async {
    List<Map<String, dynamic>> idsWihCount = [];

    for (int i = 0; i < selectedEmployee.length; i++) {
      if (selectedEmployee[i] > 0) {
        idsWihCount.add({"positionId": appController.allActivePositions[i].id, "numOfEmployee": selectedEmployee[i]});
      }
    }

    Map<String, dynamic> data = {"requestClientId": appController.user.value.client?.id??"", "employees": idsWihCount};

    CustomLoader.show(context!);
    await apiHelper.clientRequestForEmployee(data).then((response) {
      CustomLoader.hide(context!);

      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError..onRetry = onRequestPressed);
      }, (r) {
        if ([200, 201].contains(r.statusCode)) {
          clientHomeController.onInit();
          Get.back();
          CustomDialogue.information(
            context: Get.context!,
            title: MyStrings.requested.tr, 
            description: MyStrings.requestPlacedSuccessfully.tr,
          );
        } else {
          CustomDialogue.information(
            context: Get.context!,
            title: MyStrings.error.tr,
            description: MyStrings.somethingWentWrong.tr,
          );
        }
      });
    });
  }
}

import 'package:mh/app/models/dropdown_item.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../routes/app_pages.dart';

class MhEmployeesController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  RxList<DropdownItem> positionList = <DropdownItem>[].obs;

  @override
  void onInit() {
    shufflePositionList();
    super.onInit();
  }

  void onPositionClick(DropdownItem position) {
    if (appController.user.value.isGuest) {
      Get.toNamed(Routes.login);
      return;
    }

    Get.toNamed(Routes.mhEmployeesById, arguments: {MyStrings.arg.data: position});
  }

  void shufflePositionList() {
    positionList = appController.allActivePositions;
    // positionList.shuffle();
  }
}

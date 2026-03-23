import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/employee/employee_home/views/employee_home_view.dart';
import 'package:mh/app/modules/employee/employee_payment_history/views/employee_payment_history_view.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeeRootController extends GetxController {
  RxInt selectedIndex = 0.obs;

  List<Widget> pages = [
    const EmployeeHomeView(),
    Container(),
    const EmployeePaymentHistoryView(),
    Container(),
  ];

  List<Map<String, String>> bottomNavbarItems = [
    {'title': MyStrings.home.tr, 'icon': MyAssets.home},
    {'title': MyStrings.search.tr, 'icon': MyAssets.search},
    {'title': MyStrings.payments.tr, 'icon': MyAssets.payments},
    {'title': MyStrings.support.tr, 'icon': MyAssets.support},
  ];

  @override
  void onInit() {
    selectedIndex.value = Get.arguments ?? 0;
    super.onInit();
  }

  Widget get currentPage => pages[selectedIndex.value];

  Future<void> changePageOutRoot(int index) async {
    selectedIndex.value = index;
    await Get.offNamedUntil(Routes.employeeRoot, (Route route) {
      return false;
    }, arguments: index);
  }

  void changePage(int page) => selectedIndex.value = page;

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.employeeProfile);
  }
  void navigateToSearch() {
    Get.back();
    Get.toNamed(Routes.commonSearch);
  }

  void onSupportClick() => Get.toNamed(Routes.liveChat,
      arguments: LiveChatDataTransferModel(
          toName: "Support",
          toId: Get.find<AppController>().user.value.employee?.id ?? "",
          toProfilePicture:
              "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
}

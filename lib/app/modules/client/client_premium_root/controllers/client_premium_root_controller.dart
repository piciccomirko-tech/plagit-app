import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/views/client_home_premium_view.dart';
import 'package:mh/app/modules/client/client_payment_and_invoice/views/client_payment_and_invoice_view.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../location/views/location_view.dart';

class ClientPremiumRootController extends GetxController {
  RxInt selectedIndex = 0.obs;

  RxBool showExpandable = false.obs;

  List<Widget> pages = [
    ClientHomePremiumView(),
    // const ClientSearchView(),
    LocationView(),
    const ClientPaymentAndInvoiceView(),
    Container(),
  ];

  List<Map<String, String>> bottomNavbarItems = [
    {'title': MyStrings.home.tr, 'icon': MyAssets.home},
    {'title': MyStrings.nearBy.tr, 'icon': MyAssets.nearBy},
    {'title': MyStrings.payments.tr, 'icon': MyAssets.payments},
    {'title': MyStrings.support.tr, 'icon': MyAssets.support},
  ];

  @override
  void onInit() {
    selectedIndex.value = Get.arguments ?? 0;
    super.onInit();
  }

  Widget get currentPage => pages[selectedIndex.value];
  void requestEmployees() {
    Get.back(); // hide dialogue

    Get.toNamed(Routes.clientRequestForEmployee);
  }

  // void navigateToSearch() {
  //   Get.back(); // hide dialogue
  //   // Get.toNamed(Routes.commonSearch);
  //   Get.toNamed(Routes.location);
  // }

  Future<void> changePageOutRoot(int index) async {
    selectedIndex.value = index;
    await Get.offNamedUntil(Routes.clientPremiumRoot, (Route route) {
      return false;
    }, arguments: index);
  }

  void changePage(int page) => selectedIndex.value = page;

  void onProfileClick() {
    Get.back();
    Get.toNamed(Routes.employeeProfile);
  }

  void onSupportClick() {
    Get.back();
    Get.toNamed(
      Routes.liveChat,
      arguments: LiveChatDataTransferModel(
          toName: "Support",
          toId: Get.find<AppController>().user.value.client?.id ?? "",
          toProfilePicture:
              "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"),
    );
  }

  void onFloatingButtonClick() => showExpandable.value = !showExpandable.value;
}

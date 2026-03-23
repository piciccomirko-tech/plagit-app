import 'dart:developer';

import 'package:mh/app/modules/admin/admin_client_request/views/admin_client_request_view.dart';
import 'package:mh/app/modules/admin/admin_home/views/admin_home_view.dart';
import 'package:mh/app/modules/admin/admin_search/views/admin_search_view.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';

class AdminRootController extends GetxController {
  RxInt selectedIndex = 0.obs;

  List<Widget> pages = [
    AdminHomeView(),
    const AdminSearchView(),
    //  CommonSearchView(),
    const AdminClientRequestView(),
    Container(),
  ];

  List<Map<String, String>> bottomNavbarItems = [
    {'title': MyStrings.home.tr, 'icon': MyAssets.home},
    {'title': MyStrings.search.tr, 'icon': MyAssets.search},
    {'title': MyStrings.requests.tr, 'icon': MyAssets.requests},
    {'title': MyStrings.users.tr, 'icon': MyAssets.users},
  ];

  @override
  void onInit() {
    selectedIndex.value = Get.arguments ?? 0;
    super.onInit();
  }

  Widget get currentPage => pages[selectedIndex.value];

  Future<void> changePageOutRoot(int index) async {
    selectedIndex.value = index;
    await Get.offNamedUntil(Routes.adminRoot, (Route route) {
      return false;
    }, arguments: index);
  }

  // void changePage(int page) => selectedIndex.value = page;
  void changePage(int page) {
    if (page == 1) {
      navigateToSearch();
    } else {
      selectedIndex.value = page;
    }
  }

  void onEmployeeClick() {
    Get.toNamed(Routes.adminAllEmployees);
  }
  // void onAdminSearchClick() {
  //   Get.toNamed(Routes.adminSearch);
  // }

  void onClientClick() {
    Get.toNamed(Routes.adminAllClients);
  }

  void navigateToSearch() {
    Get.back();
    Get.toNamed(Routes.commonSearch);
  }

  void onUsersClick({required BuildContext context}) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              onTap: () => onEmployeeClick(),
              leading:
                  Image.asset(MyAssets.myEmployees, width: 25.w, height: 25.w),
              title: Text(MyStrings.candidates.tr,
                  style: MyColors.l111111_dwhite(context).medium13),
              trailing:
                  Image.asset(MyAssets.trailing, width: 25.w, height: 25.w),
            ),
            ListTile(
              onTap: () => onClientClick(),
              leading: Image.asset(MyAssets.clientFixedLogo,
                  width: 25.w, height: 25.w),
              title: Text(MyStrings.business.tr,
                  style: MyColors.l111111_dwhite(context).medium13),
              trailing:
                  Image.asset(MyAssets.trailing, width: 25.w, height: 25.w),
            ),
          ],
        ),
      ),
    ));
  }
}

import 'package:mh/app/common/utils/exports.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/client/location/controllers/nearby_employee_controller.dart';

import '../../../../routes/app_pages.dart';
import '../../../admin/admin_home/controllers/admin_home_controller.dart';

class ClientPremiumBottomNavBarWidget extends StatefulWidget {
  const ClientPremiumBottomNavBarWidget({super.key});
  @override
  State<ClientPremiumBottomNavBarWidget> createState() =>
      _ClientPremiumBottomNavBarWidgetState();
}

class _ClientPremiumBottomNavBarWidgetState
    extends State<ClientPremiumBottomNavBarWidget>
    with TickerProviderStateMixin {
  ClientPremiumRootController controller =
      Get.put(ClientPremiumRootController());

  late AnimationController fabAnimationController;
  NearbyEmployeeController? nearbyEmployeeController;

  @override
  void initState() {
    fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    super.initState();
  }

  void _handleTabChange(int index) {
    final previousIndex = controller.selectedIndex.value;

    // If the user is already on index 1 and taps it again, do nothing
    if (previousIndex == 1 && index == 1) return;

    if (previousIndex == 1) {
      // Get instance of controller only once
      nearbyEmployeeController ??= Get.find<NearbyEmployeeController>();
      nearbyEmployeeController?.onTabExit();
    }

    if (index == 3) {
      showCustomBottomSheet();
      return; // Prevent updating selectedIndex when opening bottom sheet
    }

    // Update the selected index
    controller.selectedIndex.value = index;

    if (index == 1) {
      nearbyEmployeeController ??= Get.find<NearbyEmployeeController>();
      nearbyEmployeeController?.onTabEnter();
    }

    if (index == 0 && Get.isRegistered<ClientHomePremiumController>()) {
      Get.find<ClientHomePremiumController>().onRefresh(fromHome: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedBottomNavigationBar.builder(
        height: Get.width * .18,
        notchMargin: 8.0,
        hideAnimationController: fabAnimationController,
        activeIndex: controller.selectedIndex.value,
        gapLocation: GapLocation.center,
        backgroundColor: MyColors.lightCard(context),
        notchSmoothness: NotchSmoothness
            .defaultEdge, //for more curve use NotchSmoothness.verySmoothEdge
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: _handleTabChange,
        tabBuilder: (int index, bool isActive) {
          return GestureDetector(
            onTap: () {
              if (index == 3) {
                showCustomBottomSheet();
              } else {
                _handleTabChange(index);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 3,
                    color: controller.selectedIndex.value == index
                        ? MyColors.c_C6A34F
                        : MyColors.noColor),
                // SizedBox(height: Get.width * 0.01),
                Image.asset(
                  controller.bottomNavbarItems[index]['icon']!,
                  height: 25.w,
                  width: 25.w,
                  color: controller.selectedIndex.value == index
                      ? MyColors.c_C6A34F
                      : MyColors.c_9A9A9A,
                ),
                Obx(() {
                  int count = Get.isRegistered<AdminHomeController>()
                      ? Get.find<AdminHomeController>()
                              .unreadMessageCount
                              .value
                      : 0;
                  return Badge(
                      isLabelVisible: index == 3 && count > 0,
                      alignment: Alignment
                          .topRight, // Places the badge at the top-right
                      offset: Offset(3, -35), // Adjust the position as needed
                      largeSize: 12,
                      backgroundColor: MyColors.c_C6A34F,
                      label: Text(
                        "${count}",
                        style: TextStyle(color: Colors.white),
                      ),
                      child: Text(
                        controller.bottomNavbarItems[index]['title']!,
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontFamily: MyAssets.fontKlavika,
                            fontSize: Get.width > 600 ? 11.sp : 11,
                            color: controller.selectedIndex.value == index
                                ? MyColors.c_C6A34F
                                : MyColors.c_9A9A9A),
                      ));
                })
              ],
            ),
          );
        },
        itemCount: 4,
        //other params
      );
    });
  }

  void showCustomBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
                onTap: controller.onSupportClick,
                child: ListTile(
                  leading: Image.asset(MyAssets.chat,
                      height: 25.w, width: 25.w, color: MyColors.primaryLight),
                  title: Text(
                    MyStrings.chatWithAdmin.tr,
                    style: TextStyle(
                        color: MyColors.c_C6A34F,
                        fontSize: 15,
                        fontFamily: MyAssets.fontKlavika),
                  ),
                  onTap: controller.onSupportClick,
                )),
            Divider(),
            GestureDetector(
              onTap: controller.requestEmployees,
              child: ListTile(
                leading: Icon(Icons.people_alt, color: MyColors.primaryLight),
                title: Text('${MyStrings.candidate.tr} ${MyStrings.request.tr}',
                    style: TextStyle(
                        color: MyColors.c_C6A34F,
                        fontSize: 15,
                        fontFamily: MyAssets.fontKlavika)),
                onTap: controller.requestEmployees,
              ),
            ),
            Divider(),
            GestureDetector(
              onTap: () {
                Get.back();
                Get.toNamed(Routes.chatBot);
              },
              child: ListTile(
                  leading: Image.asset(
                    MyAssets.chatBot,
                    height: 30.w,
                    width: 30.w,
                    color: MyColors.primaryLight,
                  ),
                  title: Text('${MyStrings.plagIt.tr} ${MyStrings.chatBot.tr}',
                      style: TextStyle(
                          color: MyColors.c_C6A34F,
                          fontSize: 15,
                          fontFamily: MyAssets.fontKlavika)),
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.chatBot);
                  }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

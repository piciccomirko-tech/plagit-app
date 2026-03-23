import 'package:mh/app/common/utils/exports.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/admin_root/controllers/admin_root_controller.dart';

class AdminBottomNavBarWidget extends StatefulWidget {
  const AdminBottomNavBarWidget({super.key});

  @override
  State<AdminBottomNavBarWidget> createState() =>
      _AdminBottomNavBarWidgetState();
}

class _AdminBottomNavBarWidgetState extends State<AdminBottomNavBarWidget>
    with TickerProviderStateMixin {
  AdminRootController controller = Get.put(AdminRootController());

  late AnimationController fabAnimationController;

  @override
  void initState() {
    fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return AnimatedBottomNavigationBar.builder(
        height: Get.width * .18,
        hideAnimationController: fabAnimationController,
        activeIndex: controller.selectedIndex.value,
        gapLocation: GapLocation.none,
        backgroundColor: MyColors.lightCard(
            context), //for more curve use NotchSmoothness.verySmoothEdge
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (index) {},
        tabBuilder: (int index, bool isActive) {
          return GestureDetector(
            onTap: () {
              if (index == 3) {
                controller.onUsersClick(context: context);
              } else if (index == 1) {
                controller.navigateToSearch();
              } else {
                controller.selectedIndex.value = index;
                if (Get.isRegistered<AdminHomeController>() &&
                    controller.selectedIndex.value == 0) {
                  Get.find<AdminHomeController>()
                      .reloadPage(needToJumpTop: true, fromHome: true);
                }
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
                Text(
                  controller.bottomNavbarItems[index]['title']!,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 11.sp,
                      fontFamily: MyAssets.fontKlavika,
                      color: controller.selectedIndex.value == index
                          ? MyColors.c_C6A34F
                          : MyColors.c_9A9A9A),
                )
              ],
            ),
          );
        },
        itemCount: 4,
        //other params
      );
    });
  }
}

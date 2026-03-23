import 'package:mh/app/common/utils/exports.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_root/controllers/employee_root_controller.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../common_modules/live_chat/models/live_chat_data_transfer_model.dart';

class EmployeeBottomNavBarWidget extends StatefulWidget {
  const EmployeeBottomNavBarWidget({super.key});

  @override
  State<EmployeeBottomNavBarWidget> createState() =>
      _EmployeeBottomNavBarWidgetState();
}

class _EmployeeBottomNavBarWidgetState extends State<EmployeeBottomNavBarWidget>
    with TickerProviderStateMixin {
  EmployeeRootController controller = Get.put(EmployeeRootController());

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
        height:
            ResponsiveHelper.isTab(context) ? Get.width * .1 : Get.width * .18,
        notchMargin: 8.0,
        hideAnimationController: fabAnimationController,
        activeIndex: controller.selectedIndex.value,
        gapLocation: GapLocation.center,
        backgroundColor: MyColors.lightCard(context),
        notchSmoothness: NotchSmoothness
            .defaultEdge, //for more curve use NotchSmoothness.verySmoothEdge
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: (index) {
          if (index == 3) {
            // controller.onSupportClick();
            showCustomBottomSheetForEmployee();
          } else if (index == 1) {
            controller.navigateToSearch();
          } else {
            controller.selectedIndex.value = index;
            if (Get.isRegistered<EmployeeHomeController>() &&
                controller.selectedIndex.value == 0) {
              Get.find<EmployeeHomeController>().onRefresh(fromHome: true);
            }
          }
        },
        tabBuilder: (int index, bool isActive) {
          return GestureDetector(
            onTap: () {
              if (index == 3) {
                // controller.onSupportClick();
                showCustomBottomSheetForEmployee();
              } else if (index == 1) {
                controller.navigateToSearch();
              } else {
                controller.selectedIndex.value = index;
                if (Get.isRegistered<EmployeeHomeController>() &&
                    controller.selectedIndex.value == 0) {
                  Get.find<EmployeeHomeController>().onRefresh(fromHome: true);
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
                  height: ResponsiveHelper.isTab(context) ? 20.h : 25.h,
                  width: ResponsiveHelper.isTab(context) ? 20.w : 25.w,
                  color: controller.selectedIndex.value == index
                      ? MyColors.c_C6A34F
                      : MyColors.c_9A9A9A,
                ),
                Text(
                  controller.bottomNavbarItems[index]['title']!,
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: ResponsiveHelper.isTab(context) ? 9.sp : 11,
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

void showCustomBottomSheetForEmployee() {
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
              onTap: () {
                Get.back();
                Get.toNamed(Routes.liveChat,
                    arguments: LiveChatDataTransferModel(
                        toName: "Support",
                        toId:
                            Get.find<AppController>().user.value.employee?.id ??
                                "",
                        toProfilePicture:
                            "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
              },
              child: ListTile(
                  leading: Image.asset(MyAssets.chat,
                      height: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      width: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                      color: MyColors.primaryLight),
                  title: Text(
                    MyStrings.chatWithAdmin.tr,
                    style: TextStyle(
                        color: MyColors.c_C6A34F,
                        fontSize: 15,
                        fontFamily: MyAssets.fontKlavika),
                  ),
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.liveChat,
                        arguments: LiveChatDataTransferModel(
                            toName: "Support",
                            toId: Get.find<AppController>()
                                    .user
                                    .value
                                    .employee
                                    ?.id ??
                                "",
                            toProfilePicture:
                                "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));
                  })),
          Divider(),
          GestureDetector(
            onTap: () {
              Get.back();
              Get.toNamed(Routes.chatBot);
            },
            child: ListTile(
                leading: Image.asset(
                  MyAssets.chatBot,
                  height: ResponsiveHelper.isTab(Get.context) ? 15.w : 30.w,
                  width: ResponsiveHelper.isTab(Get.context) ? 15.w : 30.w,
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

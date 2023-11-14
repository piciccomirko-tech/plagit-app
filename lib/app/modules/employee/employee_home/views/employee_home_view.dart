import 'package:flutter/cupertino.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_bottom_nav_bar_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_home_body_widget.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_menu.dart';
import '../controllers/employee_home_controller.dart';

class EmployeeHomeView extends GetView<EmployeeHomeController> {
  const EmployeeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return WillPopScope(
      onWillPop: () => Utils.appExitConfirmation(context),
      child: Scaffold(
          appBar: CustomAppbar.appbar(
            context: context,
            title: 'Features',
            centerTitle: false,
            visibleBack: false,
            actions: [
              Obx(() => controller.notificationsController.unreadCount.value == 0
                  ? IconButton(
                      onPressed: () {
                        Get.toNamed(Routes.notifications,
                            arguments: controller.appController.user.value.employee?.id ?? '');
                      },
                      icon: const Icon(CupertinoIcons.bell))
                  : InkWell(
                      onTap: () {
                        Get.toNamed(Routes.notifications);
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 15.h, right: 15.w),
                        child: Badge(
                          backgroundColor: MyColors.c_C92C1A,
                          label: Obx(() {
                            return Text(
                                controller.notificationsController.unreadCount.value == 20
                                    ? '20+'
                                    : controller.notificationsController.unreadCount.toString(),
                                style: MyColors.white.semiBold12);
                          }),
                          child: const Icon(CupertinoIcons.bell),
                        ),
                      ),
                    )),
              IconButton(
                onPressed: () {
                  CustomMenu.accountMenu(
                    context,
                    onProfileTap: controller.onProfileClick,
                  );
                },
                icon: const Icon(
                  CupertinoIcons.person,
                ),
              )
            ],
          ),
          bottomNavigationBar: const EmployeeBottomNavBarWidget(),
          body: const EmployeeHomeBodyWidget()),
    );
  }
}

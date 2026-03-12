import 'package:flutter/cupertino.dart';
import 'package:mh/app/modules/auth/login/widgets/language_drop_down.dart';
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
      onWillPop: () async => Utils.appExitConfirmation(context),
      child: Scaffold(
          appBar: CustomAppbar.appbar(
            context: context,
            title: MyStrings.features.tr,
            centerTitle: false,
            visibleBack: false,
            actions: [
              const SizedBox(width: 10),
              const LanguageDropdown(),
              const SizedBox(width: 10),
              Obx(() => controller.notificationsController.unreadCount.value == 0
                  ? InkResponse(onTap: () => Get.toNamed(Routes.notifications), child: const Icon(CupertinoIcons.bell))
                  : InkResponse(
                onTap: () => Get.toNamed(Routes.notifications),
                child: Badge(
                  backgroundColor: MyColors.c_C6A34F,
                  label: Obx(() {
                    return Text(
                        controller.notificationsController.unreadCount.value == 20
                            ? '20+'
                            : controller.notificationsController.unreadCount.toString(),
                        style:  TextStyle(fontSize: Get.width>600?13:12, color: MyColors.white));
                  }),
                  child:  Icon(CupertinoIcons.bell, size: Get.width>600?30:21),
                ),
              )),
              const SizedBox(width: 20),
              InkResponse(
                onTap: () {
                  CustomMenu.accountMenu(
                    context,
                    onProfileTap: controller.onProfileClick,
                  );
                },
                child:  Icon(
                    CupertinoIcons.person,
                    size: Get.width>600?30:21
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          bottomNavigationBar: const EmployeeBottomNavBarWidget(),
          body: const EmployeeHomeBodyWidget()),
    );
  }
}

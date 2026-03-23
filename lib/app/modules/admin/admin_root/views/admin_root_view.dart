import 'package:flutter/services.dart';
import 'package:mh/app/modules/admin/admin_root/controllers/admin_root_controller.dart';
import 'package:mh/app/modules/admin/admin_root/widgets/admin_bottom_nav_bar_widget.dart';
import '../../../../common/utils/exports.dart';

class AdminRootView extends GetWidget<AdminRootController> {
  const AdminRootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          if (controller.selectedIndex.value != 0) {
            controller.selectedIndex.value = 0;
          } else {
            final exitConfirmed = await Get.dialog<bool>(
              AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                title: Text('Exit App'),
                content: Text('Do you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      'No',
                      style: TextStyle(color: MyColors.primaryLight),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text(
                      'Yes',
                      style: TextStyle(color: MyColors.primaryLight),
                    ),
                  ),
                ],
              ),
            );

            if (exitConfirmed == true) {
              SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
            extendBody: true,
            body: controller.currentPage,
            bottomNavigationBar: const AdminBottomNavBarWidget()),
      );
    });
  }
}

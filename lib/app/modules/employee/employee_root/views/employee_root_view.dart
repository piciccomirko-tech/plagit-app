import 'package:flutter/services.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_root/controllers/employee_root_controller.dart';
import 'package:mh/app/modules/employee/employee_root/widgets/employee_bottom_nav_bar_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeeRootView extends GetView<EmployeeRootController> {
  const EmployeeRootView({super.key});

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
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: ClipRRect(
              borderRadius: BorderRadius.circular(30.sp),
              child: FloatingActionButton(
                onPressed: () => Get.toNamed(Routes.createPost),
                backgroundColor: MyColors.primaryDark,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: Get.width > 600 ? 20.sp : null,
                ),
              ),
            ),
            bottomNavigationBar: const EmployeeBottomNavBarWidget()),
      );
    });
  }
}

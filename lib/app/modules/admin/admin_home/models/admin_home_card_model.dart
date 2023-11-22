import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class AdminHomeCardModel {
  final String title;
  final String icon;
  final bool visibleMH;
  final Function() onTap;
  final double? iconHeight;
  final bool loading;
  final double? height;
  final Color backgroundColor;

  AdminHomeCardModel(
      {required this.title,
      required this.icon,
      this.visibleMH = false,
      required this.onTap,
      this.iconHeight,
      this.loading = false,
      this.height,
      required this.backgroundColor});
}

List<AdminHomeCardModel> adminHomeCardList = <AdminHomeCardModel>[
  AdminHomeCardModel(
    backgroundColor: Colors.teal,
    title: MyStrings.dashboard.tr,
    icon: MyAssets.dashboard,
    onTap: Get.find<AdminHomeController>().onAdminDashboardClick,
  ),
  AdminHomeCardModel(
      backgroundColor: Colors.red,
      title: "Requested Employees",
      icon: MyAssets.request,
      onTap: Get.find<AdminHomeController>().onRequestClick),
  AdminHomeCardModel(
      backgroundColor: Colors.blue,
      title: "All Employees",
      icon: MyAssets.myEmployees,
      onTap: Get.find<AdminHomeController>().onEmployeeClick),
  AdminHomeCardModel(
      backgroundColor: Colors.purple,
      title: "All Clients",
      icon: MyAssets.kitchenPorter,
      onTap: Get.find<AdminHomeController>().onClientClick),
  AdminHomeCardModel(
      backgroundColor: Colors.orange,
      title: "Today's Employees",
      icon: MyAssets.assistantManager,
      onTap: () {
        Get.toNamed(Routes.adminTodaysEmployees);
      }),
];

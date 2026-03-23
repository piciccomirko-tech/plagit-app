import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';

class AdminHeaderWidget extends GetWidget<AdminHomeController> {
  const AdminHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Obx(() =>
              // controller.adminDataLoading.value == true
              //     ? const CupertinoActivityIndicator()
              //     :
              GestureDetector(
                onTap: () => controller.onProfileClick(),
                child: Container(
                  width: Get.width > 600 ? 95.h : 80.h,
                  height: Get.width > 600 ? 95.h : 75.h,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2.5,
                        color: MyColors.primaryLight,
                      )),
                  child: (controller.appController.user.value.admin
                                      ?.profilePicture ??
                                  "")
                              .isEmpty ||
                          (controller.appController.user.value.admin
                                  ?.profilePicture ==
                              "undefined")
                      ? const DefaultImageWidget(
                          defaultImagePath: MyAssets.adminDefault)
                      : CustomNetworkImage(
                          url: (controller.appController.user.value.admin
                                      ?.profilePicture ??
                                  "")
                              .imageUrl,
                          radius: 100,
                          fit: BoxFit.cover,
                        ),
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
              child: Container(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 15.0),
            decoration: BoxDecoration(
                border: Border.all(width: 0.5, color: MyColors.noColor),
                borderRadius: BorderRadius.circular(50.0),
                color: MyColors.lightCard(context)),
            child: Row(
              children: [
                Expanded(
                    child: InkResponse(
                  onTap: controller.onAdminDashboardClick,
                  child: Column(
                    children: [
                      Image.asset(MyAssets.mhEmployees,
                          height: 29.h, width: 29.w),
                      SizedBox(height: 5.w),
                      Text(MyStrings.dashboard.tr,
                          style: MyColors.l111111_dwhite(context).regular15)
                    ],
                  ),
                )),
                const VerticalDivider(
                  indent: 13,
                  endIndent: 13,
                  thickness: 1,
                  width: 10,
                  color: MyColors.lightGrey,
                ),
                Expanded(
                    child: InkResponse(
                  onTap: controller.onTodaysEmployeesPressed,
                  child: Column(
                    children: [
                      Image.asset(MyAssets.myEmployees,
                          height: 29.h, width: 29.h),
                      SizedBox(height: 5.h),
                      Text(MyStrings.todaysCandidates.tr,
                          style: MyColors.l111111_dwhite(context).regular15)
                    ],
                  ),
                )),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

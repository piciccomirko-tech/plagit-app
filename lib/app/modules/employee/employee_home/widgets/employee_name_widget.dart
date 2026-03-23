import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/helpers/responsive_helper.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeeNameWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          _buildEmployeeImage(),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.5, color: MyColors.noColor),
                  borderRadius: BorderRadius.circular(50.0),
                  color: MyColors.lightCard(context)),
              child: Row(
                children: [
                  Expanded(
                      child: InkResponse(
                        key: controller.keyDashboard,
                    onTap: controller.onDashboardClick,
                    child: Column(
                      children: [
                        Image.asset(MyAssets.mhEmployees,
                            height:
                                ResponsiveHelper.isTab(Get.context) ? 40 : 29,
                            width:
                                ResponsiveHelper.isTab(Get.context) ? 40 : 29),
                        const SizedBox(height: 5),
                        Text(MyStrings.dashboard.tr,
                            style: ResponsiveHelper.isTab(Get.context)
                                ? MyColors.l111111_dwhite(context).regular10
                                : MyColors.l111111_dwhite(context).regular15)
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
                        key: controller.keyCalender,
                    onTap: controller.onCalenderClick,
                    child: Column(
                      children: [
                        Image.asset(MyAssets.calendar,
                            height:
                                ResponsiveHelper.isTab(Get.context) ? 40 : 29,
                            width:
                                ResponsiveHelper.isTab(Get.context) ? 40 : 29),
                        const SizedBox(height: 5),
                        Text(MyStrings.calendar.tr,
                            style: ResponsiveHelper.isTab(Get.context)
                                ? MyColors.l111111_dwhite(context).regular10
                                : MyColors.l111111_dwhite(context).regular15)
                      ],
                    ),
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmployeeImage() {
    return Obx(
      () => Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(Routes.employeeProfile),
            child: Container(
              width: ResponsiveHelper.isTab(Get.context) ? 40.w : 70.w,
              height: ResponsiveHelper.isTab(Get.context) ? 40.w : 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2.0,
                  color: MyColors.primaryLight,
                ),
              ),
              child: (controller.employee.value.details?.profilePicture ?? '')
                      .isEmpty
                  ? const DefaultImageWidget(
                      // radius: 80,
                      defaultImagePath: MyAssets.employeeDefault,
                    )
                  : CustomNetworkImage(
                      // url: (controller.appController.user.value.employee
                      //             ?.profilePicture ??
                      //         "")
                      //     .imageUrl,
                      url: controller
                          .employee.value.details!.profilePicture!.imageUrl,
                      radius: 60.w,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

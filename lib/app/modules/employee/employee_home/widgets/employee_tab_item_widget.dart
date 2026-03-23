import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_job_posts_widget.dart';

import '../../../../helpers/responsive_helper.dart';
import '../../../common_modules/common_social_feed/views/common_social_feed_view.dart';

class EmployeeTabItemWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.selectedTabIndex.value == 0) {
        // return const EmployeeSocialFeedWidget();
        return Padding(
          padding: EdgeInsets.all(15.0.w),
          child: const EmployeeJobPostsWidget(),
          // child: const CommonJobPostsView(userType: 'employee',),
        );
      } else if (controller.selectedTabIndex.value == 1) {
        return CommonSocialFeedView();
      } else {
        return Padding(
          padding: EdgeInsets.all(15.0.w),
          child: Column(
            children: [
              InkResponse(
                onTap: controller.onHiredHistoryClick,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  margin: const EdgeInsets.only(top: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: MyColors.noColor),
                      borderRadius: BorderRadius.circular(10.84),
                      color: MyColors.lightCard(context)),
                  child: ListTile(
                    leading: Image.asset(MyAssets.hiredHistory,
                        height: 36.w, width: 36.w),
                    title: Row(
                      children: [
                        Text(MyStrings.hiredHistory.tr,
                            style: MyColors.l111111_dwhite(context).medium15),
                        const SizedBox(width: 10),
                        Obx(
                          () => Visibility(
                            visible: controller.hiredHistoryList.isNotEmpty,
                            child: CustomBadge(
                              controller.hiredHistoryList.length.toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        Image.asset(MyAssets.trailing, height: 25.h, width: 25.w),
                  ),
                ),
              ),
              InkResponse(
                onTap: controller.onBookedHistoryClick,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  margin: const EdgeInsets.only(top: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: MyColors.noColor),
                      borderRadius: BorderRadius.circular(10.84),
                      color: MyColors.lightCard(context)),
                  child: ListTile(
                    leading: Image.asset(MyAssets.bookedHistory,
                        height: 36.w, width: 36.w),
                    title: Row(
                      children: [
                        Text(MyStrings.bookedHistory.tr,
                            style: ResponsiveHelper.isTab(Get.context)?MyColors.l111111_dwhite(context)
                                .medium10:MyColors.l111111_dwhite(context).medium15),
                        const SizedBox(width: 10),
                        Obx(
                          () => Visibility(
                            visible: controller.bookingHistoryList.isNotEmpty,
                            child: CustomBadge(
                              controller.bookingHistoryList.length.toString(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing:
                        Image.asset(MyAssets.trailing, height: 25.h, width: 25.w),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    });
  }
}

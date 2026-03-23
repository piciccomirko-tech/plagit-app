import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_job_post_widget.dart';

import '../../../../helpers/responsive_helper.dart';

class EmployeeJobPostsWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeJobPostsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (controller.jobPostDataLoaded.value == false) {
            return Center(
              child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 100),
            );
          } else if (controller.jobPostDataLoaded.value == true &&
              controller.jobPostList.isEmpty) {
            return const Center(child: NoItemFound());
          } else {
            return Padding(
              padding: EdgeInsets.only(top: 15.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("${MyStrings.allJobPosts.tr} (${controller.grossTotalAllJobPosts.value})",
                        style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium10:MyColors.l111111_dwhite(context).medium15),
                  ),
                  SizedBox(height: 15.w),
                  ListView.builder(
                    itemCount: (controller.jobPostList).length,
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      if (index == controller.jobPostList.length - 1 &&
                          controller.moreJobPostsAvailable.value == true) {
                        return const SpinKitThreeBounce(
                          color: MyColors.primaryLight,
                          size: 30,
                        );
                      }
                      return EmployeeJobPostWidget(
                          jobPost: (controller.jobPostList)[index], isMyJobPost: false,);
                    },
                  ),
                          // Page Indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // IconButton(
                        //   onPressed: controller.myJobCurrentPage.value > 1
                        //       ? controller.goToPreviousPage
                        //       : null,
                        //   icon: Icon(Icons.arrow_back),
                        // ),
                        CustomButtons.button(
                            text: "Prev",
                            fontSize: ResponsiveHelper.isTab(context)?8.sp:17.sp,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30.h,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.allJobCurrentPage.value > 1
                                ? controller.goToAllJobPreviousPage
                                : null),
                        Obx(() => Text(
                              "Page ${controller.allJobCurrentPage.value} of ${controller.totalAllJobPosts.value}",
                              style: TextStyle(fontSize: ResponsiveHelper.isTab(context)?20:16,fontFamily: MyAssets.fontKlavika),
                            )),
                            
                        CustomButtons.button(
                            text: "Next",
                          fontSize: ResponsiveHelper.isTab(context)?8.sp:17.sp,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30.h,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.allJobCurrentPage.value <
                                  controller.totalAllJobPosts.value
                              ? controller.goToAllJobNextPage
                              : null,),
                        // IconButton(
                        //   onPressed: controller.myJobCurrentPage.value <
                        //           controller.totalMyJobPosts.value
                        //       ? controller.goToNextPage
                        //       : null,
                        //   icon: Icon(Icons.arrow_forward),
                        // ),
                      ],
                    ),
                  ),
                  SizedBox(height: 115.h)
                ],
              ),
            );
          }
        })
      ],
    );
  }
}

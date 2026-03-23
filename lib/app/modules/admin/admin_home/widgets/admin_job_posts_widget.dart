import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';

import 'admin_job_post_widget.dart';

class AdminJobPostsWidget extends GetWidget<AdminHomeController> {
  const AdminJobPostsWidget({super.key});


  @override
  Widget build(BuildContext context) {
      
  // return 
  // Column(
  //   children: [
  //     Text("${(controller.jobPostList.value.first.clientId?.countryName)}"),
  //     Text("${(controller.jobPostList.value.first.minRatePerHour)}"),
  //     Text("${controller.jobPostDataLoaded.value}"),
  //     // Text("${controller.jobPostList.value.}"),
  //   ],
  // );
    return Obx(() {
      if (controller.jobPostDataLoaded.value == false) {
        return Center(
          child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 115),
        );
      } else if (controller.jobPostDataLoaded.value == true &&
          controller.jobPostList.isEmpty) {
        return const Center(child: NoItemFound());
      } else {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text("${(controller.jobPostList).length}"),
                Text("${MyStrings.allJobPosts.tr} (${controller.grossTotalAllJobPosts.value})",
                    style: MyColors.l111111_dwhite(context).medium13),
                SizedBox(height: 10.h),
              
                ListView.builder(
                 
                   itemCount: (controller.jobPostList).length,
                   shrinkWrap: true,
                   primary: false,
                   reverse:false,
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
                            return AdminJobPostWidget(isMyJobPost: true, jobPost:controller.jobPostList[index] ,);
                         //  isClientUser: controller.appController.user.value.client?.client ?? false,
                          //  return Text("${(controller.jobPostList)[index].country}");
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
                            fontSize: 17.sp,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30.h,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.allJobCurrentPage.value > 1
                                ? controller.goToAllJobPreviousPage
                                : null),
                        Obx(() => Text(
                              "Page ${controller.allJobCurrentPage.value} of ${controller.totalAllJobPosts.value}",
                              style: TextStyle(fontSize: 16,fontFamily: MyAssets.fontKlavika),
                            )),
                    
                        CustomButtons.button(
                            text: "Next",
                            fontSize: 17.sp,
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
          ),
        );
      }
    });
  }
}
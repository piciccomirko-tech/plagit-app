import 'dart:developer';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';

import '../controllers/common_job_posts_cntroller.dart';
import 'common_job_post_widget.dart';

class CommonJobPostsWidget extends GetWidget<CommonJobPostsController> {
  const CommonJobPostsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (controller.isMyJobPost != null && controller.isMyJobPost == true)
          Obx(() {
            if (controller.myJobPostDataLoaded.value == false) {
              return Center(
                child:
                    ShimmerWidget.clientMyEmployeesShimmerWidget(height: 100),
              );
            } else if (controller.myJobPostDataLoaded.value == true &&
                controller.myJobPostList.isEmpty) {
              return Center(
                  child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: const Text("No job post available"),
              ));
            } else {
              int startIndex = (controller.myJobCurrentPage.value - 1) *
                  controller.itemsMyJobPerPage;
              int endIndex = startIndex + controller.itemsMyJobPerPage;
              endIndex = endIndex > controller.myJobPostList.length
                  ? controller.myJobPostList.length
                  : endIndex;

              return Padding(
                padding: EdgeInsets.only(top: 15.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            "${MyStrings.myJobPosts.tr} (${(controller.grossTotalMyJobPosts.value)})",
                            style: MyColors.l111111_dwhite(context).medium13),
                      ],
                    ),
                    SizedBox(height: 15.h),

                    //  if (itemCount > 0)
                    ListView.builder(
                      itemCount: controller.myJobPostList.length,
                      // itemCount: itemCount,
                      shrinkWrap: true,
                      reverse: false,
                      physics: const NeverScrollableScrollPhysics(),
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        // int actualIndex = startIndex + index;
                        log(" client id: ${controller.myJobPostList[index].clientId!.id!}");
                        log(" client country: ${controller.myJobPostList[index].clientId!.countryName}");
                        return CommonJobPostWidget(
                            isMyJobPost: true,
                            isClientUser: controller
                                    .appController.user.value.client?.client ??
                                false,
                            jobPost: (controller.myJobPostList)[index]);
                        // jobPost: (controller.myJobPostList)[actualIndex]);
                      },
                    ),
                    // Page Indicator my job post
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CustomButtons.button(
                              text: "Prev",
                              fontSize: 13.sp,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 30.h,
                              customButtonStyle:
                                  CustomButtonStyle.radiusTopBottomCorner,
                              onTap: controller.myJobCurrentPage.value > 1
                                  ? controller.goToMyJobPreviousPage
                                  : null),
                          Obx(() => Text(
                                "Page ${controller.myJobCurrentPage.value} of ${controller.totalMyJobPosts.value}",
                                style: TextStyle(fontSize: 16,fontFamily: MyAssets.fontKlavika),
                              )),
                          CustomButtons.button(
                            text: "Next",
                            fontSize: 13.sp,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30.h,
                            customButtonStyle:
                                CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.myJobCurrentPage.value <
                                    controller.totalMyJobPosts.value
                                ? controller.goToMyJobNextPage
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (controller.clientId == null ||
                              controller.clientName == null)
                          ? Text(
                              "${MyStrings.allJobPosts.tr} (${controller.grossTotalAllJobPosts.value})",
                              style: MyColors.l111111_dwhite(context).medium13)
                          : Text(
                              "${controller.clientName}'s Job Posts: (${controller.grossTotalAllJobPosts.value})",
                              style: MyColors.l111111_dwhite(context).medium13),
                    ],
                  ),
                  SizedBox(height: 15.w),

                  ListView.builder(
                    itemCount: (controller.jobPostList).length,
                    shrinkWrap: true,
                    reverse: false,
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
                      return CommonJobPostWidget(
                          isMyJobPost: false,
                          // isClientUser: controller.appController.user.value.client?.client ?? false,
                          jobPost: (controller.jobPostList)[index]);
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
                            fontSize: 13.sp,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            height: 30.h,
                            customButtonStyle:
                                CustomButtonStyle.radiusTopBottomCorner,
                            onTap: controller.allJobCurrentPage.value > 1
                                ? controller.goToAllJobPreviousPage
                                : null),
                        Obx(() => Text(
                              "Page ${controller.allJobCurrentPage.value} of ${controller.totalAllJobPosts.value}",
                              style: TextStyle(fontSize: 16,fontFamily: MyAssets.fontKlavika),
                            )),

                        CustomButtons.button(
                          text: "Next",
                          fontSize: 13.sp,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 30.h,
                          customButtonStyle:
                              CustomButtonStyle.radiusTopBottomCorner,
                          onTap: controller.allJobCurrentPage.value <
                                  controller.totalAllJobPosts.value
                              ? controller.goToAllJobNextPage
                              : null,
                        ),
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

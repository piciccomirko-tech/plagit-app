import 'dart:developer';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import '../controllers/individual_social_feeds_controller.dart';
import 'individual_job_post_widget.dart';

class IndividualJobPostsWidget
    extends GetWidget<IndividualSocialFeedsController> {
  const IndividualJobPostsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
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

              // Ensure itemCount is non-negative
              int itemCount = endIndex > startIndex ? endIndex - startIndex : 0;

              return Padding(
                padding: EdgeInsets.only(top: 15.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${controller.socialUser.name!.length > 20 ? controller.socialUser.name!.substring(0, 20) + '...' : controller.socialUser.name}'s Job Posts (${controller.grossTotalMyJobPosts.value})",
                          style: MyColors.l111111_dwhite(context).medium13,
                        ),
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
                        int actualIndex = startIndex + index;
                        log(" client id: ${controller.myJobPostList[index].clientId!.id!}");
                        log(" client country: ${controller.myJobPostList[index].clientId!.countryName}");
                        return IndividualJobPostWidget(
                            isMyJobPost:
                                controller.appController.user.value.userId ==
                                        (controller.myJobPostList)[index]
                                            .clientId
                                            ?.id
                                    ? true
                                    : false,
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
        ],
      ),
    );
  }
}

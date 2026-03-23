import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';

import '../../../../common/style/my_decoration.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/job_post_details_controller.dart';

class EmployeeJobPostClientInfoCard
    extends GetWidget<JobPostDetailsController> {
  const EmployeeJobPostClientInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 15.0.h),
      padding: const EdgeInsets.all(15.0),
      decoration: MyDecoration.cardBoxDecorationTransparent(context: context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text("${controller.appController.user.value.isEmployee}"), 
          // Text("${Utils.getPositionName("${controller.appController.user.value.employee!.positionId}")}"), 
          // Text("${controller.jobPostDetails.value.positionId?.name?.toLowerCase()}"), 
          Text(
            "Posted By:",
            style: const Color.fromARGB(255, 117, 116, 116).medium13.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          // Text(" clinet info : ${controller.jobPostDetails.value.clientId!.profilePicture}"),

                    Row(
            children: [
              // Profile Picture
              
            if (controller.jobPostDetails.value.clientId != null &&
    controller.jobPostDetails.value.clientId?.profilePicture != null &&
    controller.jobPostDetails.value.clientId!.profilePicture!.isNotEmpty)        GestureDetector(
                  onTap: () => Get.toNamed(
                    Routes.individualSocialFeeds,
                    arguments: controller.clientIdToSocialUser(
                        controller.jobPostDetails.value.clientId!),
                  ),
                  child: SizedBox(
                    width: 60,
                    child: CustomNetworkImage(
                      url: controller.jobPostDetails.value.clientId!
                              .profilePicture?.imageUrl ??
                          '',
                      radius: 30, // Set radius to make it circular
                      fit: BoxFit.cover, // Control how the image fits inside
                    ),
                  ),
                ),

              const SizedBox(width: 15),
              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Name
                    GestureDetector(
                      onTap: () => Get.toNamed(
                        Routes.individualSocialFeeds,
                        arguments: controller.clientIdToSocialUser(
                            controller.jobPostDetails.value.clientId!),
                      ),
                      child: Text(
                        controller.jobPostDetails.value.clientId!
                                .restaurantName ??
                            '',
                        style:
                            MyColors.l111111_dwhite(context).medium13.copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Country
                    Row(
                      children: [
                        Icon(Icons.flag,
                            size: 13.sp,
                            color: const Color.fromARGB(255, 165, 164, 164)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            controller.jobPostDetails.value.clientId!
                                    .countryName ??
                                '',
                            style: MyColors.l111111_dwhite(context)
                                .medium13
                                .copyWith(
                                  fontSize: 11.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13.sp,
                            color: const Color.fromARGB(255, 165, 164, 164)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            controller.jobPostDetails.value.clientId!
                                    .restaurantAddress ??
                                '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: MyColors.l111111_dwhite(context)
                                .medium13
                                .copyWith(
                                  fontSize: 11.sp,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

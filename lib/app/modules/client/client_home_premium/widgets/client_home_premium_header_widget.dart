import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/common/widgets/profile_picture_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/utils/exports.dart';

class ClientHomePremiumHeaderWidget
    extends GetWidget<ClientHomePremiumController> {
  const ClientHomePremiumHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Obx(() => controller.clientDataLoading.value == true
          //     ? const CupertinoActivityIndicator()
          //     : InkResponse(
          //         onTap: () => Get.toNamed(Routes.clientProfile),
          //         child: Container(
          //           width: Get.width > 600 ? 40.w : 70.w,
          //           height: Get.width > 600 ? 40.w : 70.w,
          //           decoration: BoxDecoration(
          //               shape: BoxShape.circle,
          //               border: Border.all(
          //                 width: 0.0,
          //                 color: MyColors.primaryLight,
          //               )),
          //           child: ((controller.appController.user.value.client
          //                               ?.profilePicture ??
          //                           "")
          //                       .isEmpty ||
          //                   controller.appController.user.value.client
          //                           ?.profilePicture ==
          //                       "undefined")
          //               ? const DefaultImageWidget(
          //                   defaultImagePath: MyAssets.clientDefault)
          //               : ProfilePictureWidget(
          //                   height: 60.w,
          //                   viewOnly: true,
          //                   profilePictureUrl: (controller.appController.user
          //                       .value.client?.profilePicture ??
          //                           "")
          //                       .imageUrl,
          //                   // profilePictureUrl: (controller
          //                   //             .client.value.details?.profilePicture ??
          //                   //         "")
          //                   //     .imageUrl,
          //                 ),
          //         ),
          //       )),
          Obx(() => InkResponse(
                onTap: () => Get.toNamed(Routes.clientProfile),
                child: Container(
                  width: Get.width > 600 ? 40.w : 70.w,
                  height: Get.width > 600 ? 40.w : 70.w,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 0.0,
                        color: MyColors.primaryLight,
                      )),
                  child:
                      ((controller.client.value.details?.profilePicture ?? "")
                                  .isEmpty ||
                              controller.client.value.details?.profilePicture ==
                                  "undefined")
                          ? const DefaultImageWidget(
                              defaultImagePath: MyAssets.clientDefault)
                          : ProfilePictureWidget(
                              height: 60.w,
                              viewOnly: true,
                              // profilePictureUrl: (controller.appController.user
                              //     .value.client?.profilePicture ??
                              //     "")
                              //     .imageUrl,
                              profilePictureUrl: (controller.client.value
                                          .details?.profilePicture ??
                                      "")
                                  .imageUrl,
                            ),
                ),
              )),
          SizedBox(width: 10.w),
          Expanded(
              child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
                border: Border.all(width: 0.8, color: MyColors.noColor),
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
                      Image.asset(MyAssets.mhEmployees, height: 29, width: 29),
                      const SizedBox(height: 5),
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
                      key: controller.keyMyCandidate,
                  onTap: controller.onMyCandidateClick,
                  child: Column(
                    children: [
                      Image.asset(MyAssets.myEmployees, height: 29, width: 29),
                      const SizedBox(height: 5),
                      Text(MyStrings.myCandidates.tr,
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

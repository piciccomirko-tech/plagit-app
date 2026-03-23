
import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';

import '../../../../common/local_storage/storage_helper.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../common_job_posts/controllers/common_job_posts_cntroller.dart';
import '../controllers/individual_social_feeds_controller.dart';

class IndividualJobPostWidget extends StatelessWidget {
  final Job jobPost;
  final bool isMyJobPost;
  final bool? isClientUser;
  final AppController appController = Get.find();
  final IndividualSocialFeedsController individualSocialFeedsController = Get.find();
  IndividualJobPostWidget(
      {super.key,
      required this.jobPost,
      required this.isMyJobPost,
      this.isClientUser});

  @override
  Widget build(BuildContext context) {
    String currencySymbol =
        jobPost.clientId == null || jobPost.clientId!.countryName!.isEmpty
            ? '\$'
            : Utils.getCurrencySymbolModified(
                jobPost.clientId!.countryName.toString());

    return Stack(
      children: [
        Container(
            padding: EdgeInsets.symmetric(
                vertical: Get.width > 600 ? 40.0.h : 20.w, horizontal: 15),
            margin: EdgeInsets.only(bottom: 10.w),
            decoration: BoxDecoration(
                border: Border.all(color: MyColors.noColor, width: 0.5),
                borderRadius: BorderRadius.circular(10.0),
                color: MyColors.lightCard(context)),
            width: Get.width,
            child: Column(
              children: [
                // Text("${appController.user.value.client?.client}"),
                // Text("${appController.user.value.userId== jobPost.clientId?.id}"),
                // Text("${appController.user.value.userId}"),
                // Text("${jobPost.clientId?.countryName}"),
                // Text("${
                // jobPost.clientId!.countryName.toString()}"),

                SizedBox(
                    height: (jobPost.users ?? []).isNotEmpty ||
                        appController.user.value.isAdmin == true ||
                        appController.user.value.isEmployee == true
                        ? 20
                        : 0),
                Row(
                  children: [
                    SizedBox(
                        height: 28.h,
                        width: 25,
                        child: CustomNetworkImage(
                            url: (jobPost.positionId?.logo ?? "")
                                .uniformImageUrl)),
                    Text(
                        " ${jobPost.positionId?.name ?? jobPost.positionName ?? ""}",
                        style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium10:MyColors.l111111_dwhite(context).medium15),
                    const SizedBox(width: 20),
                    _detailsItem(
                        MyAssets.exp,
                        MyStrings.exp.tr,
                        (jobPost.experience == null)
                            ? ' ${jobPost.minExperience == null || jobPost.minExperience == 'null' ? "" : jobPost.minExperience} - ${jobPost.minExperience == null || jobPost.maxExperience == 'null' ? "" : jobPost.maxExperience} Years'
                            : ' ${jobPost.experience != null && jobPost.experience!.toString().length > 10 ? jobPost.experience!.toString().substring(0, 10) + '...' : jobPost.experience!}',
                        context),
                    if (isMyJobPost)
                      InkResponse(
                        onTap: () =>
                            individualSocialFeedsController.onEditClick(jobRequest: jobPost),
                        child: CircleAvatar(
                          radius: 12.sp,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.edit,
                              color: MyColors.white, size: 12.sp),
                        ),
                      ),
                    if (isMyJobPost) SizedBox(width: 5.w),
                    if (isMyJobPost)
                      InkResponse(
                        onTap: () =>
                            individualSocialFeedsController.onDeleteClick(jobId: jobPost.id ?? ""),
                        child: CircleAvatar(
                          radius: 12.sp,
                          backgroundColor: Colors.red,
                          child: Icon(CupertinoIcons.delete_solid,
                              color: MyColors.white, size: 12.sp),
                        ),
                      ),
                    SizedBox(width: 5.w),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  if(Utils.getCurrencySymbolModified(jobPost.clientId!.countryName.toString()).isNotEmpty) Text("${Utils.getCurrencySymbolModified(jobPost.clientId!.countryName.toString())}${jobPost.minRatePerHour} ${jobPost.maxRatePerHour} "),
                    // if (currencySymbol.isNotEmpty &&
                    //     jobPost.minRatePerHour != null &&
                    //     jobPost.maxRatePerHour != null)
                    if (currencySymbol.isNotEmpty && jobPost.salary != null)
                    // _detailsItem(
                    //   MyAssets.rate,
                    //   "",
                    //   "$currencySymbol ${jobPost.minRatePerHour!.toStringAsFixed(2)}"
                    //       " - $currencySymbol ${jobPost.maxRatePerHour!.toStringAsFixed(2)}",
                    //   context,
                    // ),
                      _detailsItem(
                        MyAssets.rate,
                        "",
                        (jobPost.salary!.isEmpty || jobPost.salary == null)
                            ? '${currencySymbol} ${jobPost.minRatePerHour ?? ''} - ${currencySymbol} ${jobPost.maxRatePerHour ?? ''}'
                            : ' ${jobPost.salary != null && jobPost.salary!.toString().length > 15 ? jobPost.salary!.toString().substring(0, 15) + '...' : jobPost.salary!}',
                        context,
                      ),
// Text("hee: ${jobPost.clientId!.id}"),

                    _detailsItem(
                        MyAssets.calendar,
                        "",
                        "${(jobPost.publishedDate ?? DateTime.now()).dMMMy} - ${(jobPost.endDate ?? DateTime.now()).dMMMy}",
                        context),
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _detailsItem(
                        MyAssets.location,
                        "",
                        jobPost.clientId?.countryName ?? jobPost.country ?? "",
                        context),
                  ],
                )
              ],
            )),
        if (isMyJobPost && appController.user.value.isClient == true)
          Positioned(
              top: 0,
              right: 0,
              child: Visibility(
                visible: (jobPost.users ?? []).isNotEmpty,
                child: SizedBox(
                  width: Get.width > 600 ? 80.w : 100.w,
                  child: CustomButtons.button(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    height: Get.width > 600 ? 25.h : 30,
                    text: 'View',
                    margin: EdgeInsets.zero,
                    fontSize: Get.width > 600 ? 9.sp : 11,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    onTap: () => Get.find<ClientHomePremiumController>()
                        .onFullViewClick(
                        jobPostId: jobPost.id ?? "",
                        isMyJobPost: isMyJobPost),
                  ),
                ),
              )),
        if (isMyJobPost && appController.user.value.isClient == true)
          Positioned(
              top: 0,
              left: 0,
              child: Visibility(
                  visible: (jobPost.users ?? []).isNotEmpty,
                  child: CircleAvatar(
                    radius: 13.sp,
                    backgroundColor: MyColors.c_C6A34F,
                    child: Text("${(jobPost.users ?? []).length}",
                        style: MyColors.white.semiBold14),
                  ))),
        // end of my job posts for client only
        //for employee
        if (jobPost.users
            ?.any((user) => user.id == appController.user.value.userId) ==
            true)
          Positioned.fill(
            child: Align(
              alignment: StorageHelper.getLanguage == 'ar'
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: SizedBox(
                width: Get.width > 600
                    ? StorageHelper.getLanguage == 'it'
                    ? 90.w
                    : 85.w
                    : StorageHelper.getLanguage == 'it'
                    ? 80.w
                    : 65.w,
                child: CustomButtons.button(
                  height: Get.width > 600 ? 25.h : 30,
                  text: "Applied",
                  margin: EdgeInsets.zero,
                  fontSize: Get.width > 600
                      ? 9.sp
                      : StorageHelper.getLanguage == 'it'
                      ? 9
                      : 11,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                ),
              ),
            ),
          ),
        if ((!isMyJobPost && appController.user.value.isEmployee == true) ||
            (!isMyJobPost && appController.user.value.isClient == true))
          Positioned.fill(
            child: Align(
              alignment: StorageHelper.getLanguage == 'ar'
                  ? Alignment.topLeft
                  : Alignment.topRight,
              child: SizedBox(
                width: Get.width > 600
                    ? StorageHelper.getLanguage == 'it'
                    ? 90.w
                    : 80.w
                    : StorageHelper.getLanguage == 'it'
                    ? 120.w
                    : 100.w,
                child: CustomButtons.button(
                    height: Get.width > 600 ? 25.h : 30,
                    onTap: () {
                      if (Get.isRegistered<CommonJobPostsController>()) {
                        Get.find<CommonJobPostsController>().onFullViewClick(
                          jobPostId: jobPost.id ?? "",
                          isMyJobPost: false,
                        );
                      } else {
                        // Log an error or handle the case where the controller is not registered
                        print("CommonJobPostsController is not registered.");
                        // Optionally, register the controller dynamically if needed
                        Get.put(CommonJobPostsController(
                            userType: appController.user.value.userRole))
                            .onFullViewClick(
                            jobPostId: jobPost.id ?? "",
                            isMyJobPost: false);
                      }
                    },
                    margin: EdgeInsets.zero,
                    fontSize: Get.width > 600
                        ? 9.sp
                        : StorageHelper.getLanguage == 'it'
                        ? 9
                        : 11,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    text: MyStrings.viewJobDetails.tr),
              ),
            ),
          ),
        // for admin
        if (!isMyJobPost && appController.user.value.isAdmin == true)
          Positioned(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkResponse(
                      onTap: () =>
                          individualSocialFeedsController.onDeleteClick(jobId: jobPost.id ?? ""),
                      child: CircleAvatar(
                        radius: 12.sp,
                        backgroundColor: Colors.red,
                        child: Icon(CupertinoIcons.delete_solid,
                            color: MyColors.white, size: 12.sp),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    InkResponse(
                      onTap: () => individualSocialFeedsController.onFullViewClick(
                          jobPostId: jobPost.id ?? "", isMyJobPost: false),
                      child: CircleAvatar(
                        radius: 12.sp,
                        backgroundColor: MyColors.primaryLight,
                        child: Icon(CupertinoIcons.eye_fill,
                            color: MyColors.white, size: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (!isMyJobPost && appController.user.value.isAdmin == true)
          Positioned.fill(
            child: Align(
              alignment: StorageHelper.getLanguage == 'ar'
                  ? Alignment.topRight
                  : Alignment.topLeft,
              child: SizedBox(
                width: Get.width > 600
                    ? StorageHelper.getLanguage == 'it'
                    ? 90.w
                    : 80.w
                    : StorageHelper.getLanguage == 'it'
                    ? 120.w
                    : 100.w,
                child: CustomButtons.button(
                    height: Get.width > 600 ? 25.h : 30,
                    // onTap: () => controller.onViewDetailsClicked(
                    //     jobPostId: jobPost.id ?? "", isMyJobPost: false),
                    margin: EdgeInsets.zero,
                    fontSize: Get.width > 600
                        ? 9.sp
                        : StorageHelper.getLanguage == 'it'
                        ? 9
                        : 11,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    text: "${jobPost.status}"),
              ),
            ),
          )
        //end of admin
      ],
    );
  }

  Widget _detailsItem(
      String icon, String title, String value, BuildContext context) =>
      Expanded(
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 14.w,
              height: 14.w,
            ),
            SizedBox(width: ResponsiveHelper.isTab(context)?5.w:10.w),
            Text(
              title,
              style: ResponsiveHelper.isTab(context)?MyColors.dividerColor.medium9:MyColors.dividerColor.medium11,
            ),
            Visibility(visible: title.isNotEmpty, child: SizedBox(width: 3.w)),
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium11,
              ),
            ),
          ],
        ),
      );
}

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';

import '../../../../common/local_storage/storage_helper.dart';

class ClientJobPostWidget extends StatelessWidget {
  final Job jobPost;
  final bool isMyJobPost;
  final bool? isClientUser;
  final AppController appController = Get.find();
  final ClientHomePremiumController clientHomePremiumController = Get.find();
  ClientJobPostWidget(
      {super.key,
      required this.jobPost,
      required this.isMyJobPost,
      this.isClientUser});

  @override
  Widget build(BuildContext context) {
    log("${appController.user.value.client}");
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

                // SizedBox(height: (jobPost.users ?? []).isNotEmpty ? 20 : 0),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                        height: 28.h,
                        width: 25,
                        child: CustomNetworkImage(
                            url: (jobPost.positionId?.logo ?? "")
                                .uniformImageUrl)),
                    Expanded(
                      child: Text(" ${jobPost.positionId?.name ?? ""}",
                          style: MyColors.l111111_dwhite(context).medium17, overflow: TextOverflow.ellipsis,),
                    ),
                    const SizedBox(width: 20),
                    _detailsItem(
                        MyAssets.exp,
                        MyStrings.exp.tr,
                       (jobPost.experience!.isEmpty || jobPost.experience==null)? ' ${jobPost.minExperience==null || jobPost.minExperience=='null'? "":jobPost.minExperience} - ${jobPost.minExperience==null || jobPost.maxExperience=='null'? "":jobPost.maxExperience} Years':  ' ${jobPost.experience != null && jobPost.experience!.toString().length > 10 ? jobPost.experience!.toString().substring(0, 10) + '...' : jobPost.experience!}',
                        context),
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
                    if (currencySymbol.isNotEmpty &&
                        jobPost.salary != null )
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
                       (jobPost.salary!.isEmpty || jobPost.salary==null)? '${currencySymbol} ${jobPost.minRatePerHour ??''} - ${currencySymbol} ${jobPost.maxRatePerHour ??''}':  ' ${jobPost.salary != null && jobPost.salary!.toString().length > 15 ? jobPost.salary!.toString().substring(0, 15) + '...' : jobPost.salary!}',
                            
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
                Row(children: [
                  _detailsItem(MyAssets.location, "", jobPost.clientId?.countryName ?? "", context),
                ],)
              ],
            )),
        if (isMyJobPost)
          Positioned.fill(
              top: 0,
              left: 0,
              child: Visibility(
                  visible: (jobPost.users ?? []).isNotEmpty,
                  child: Align(
                    alignment: StorageHelper.getLanguage=='ar'? Alignment.topRight: Alignment.topLeft,child:  CircleAvatar(
                      radius: 13.sp,
                      backgroundColor: MyColors.c_C6A34F,
                      child: Text("${(jobPost.users ?? []).length}",
                          style: MyColors.white.semiBold14),
                    ),
                  ))),
        if (!isMyJobPost)
          Positioned.fill(
            child: Align(
              alignment: StorageHelper.getLanguage=='ar'? Alignment.topLeft: Alignment.topRight,
              child: SizedBox(
                width: Get.width > 600 ? StorageHelper.getLanguage=='it'?90.w: 80.w : StorageHelper.getLanguage=='it'? 120.w:100.w,
                child: CustomButtons.button(
                    height: Get.width > 600 ? 25.h : 30,
                    onTap: () =>
                        //  Get.isRegistered<EmployeeHomeController>()
                        //     ?
                        clientHomePremiumController.onFullViewClick(
                            jobPostId: jobPost.id ?? ""),
                    // : Get.find<AdminHomeController>()
                    //     .onViewDetailsClicked(jobPostId: jobPost.id ?? ""),
                    margin: EdgeInsets.zero,
                    fontSize: Get.width > 600 ? 9.sp : StorageHelper.getLanguage=='it'?9:11,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    text: MyStrings.viewJobDetails.tr),
              ),
            ),
          ),

        if (isMyJobPost)
          Positioned.fill(
            top: 10,
              right: 10,
              child: Align(
                  alignment: StorageHelper.getLanguage=='ar'? Alignment.topLeft: Alignment.topRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: (jobPost.users ?? []).isNotEmpty,
                        child: InkResponse(
                          onTap: () => Get.find<ClientHomePremiumController>().onFullViewClick(jobPostId: jobPost.id ?? "",isMyJobPost:isMyJobPost),
                          child: CircleAvatar(
                            radius: 12.sp,
                            backgroundColor: MyColors.primaryLight,
                            child: Icon(CupertinoIcons.eye_fill,
                                color: MyColors.white, size: 12.sp),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkResponse(
                                  onTap: () => clientHomePremiumController.onEditClick(
                                      jobRequest: jobPost),
                                  child: CircleAvatar(
                                    radius: 12.sp,
                                    backgroundColor: MyColors.primaryLight,
                                    child: Icon(Icons.edit,
                      color: MyColors.white, size: 12.sp),
                                  ),
                                ),
                      SizedBox(width: 10.w),
                      InkResponse(
                        onTap: () => clientHomePremiumController.onDeleteClick(
                            jobId: jobPost.id ?? ""),
                        child: CircleAvatar(
                          radius: 12.sp,
                          backgroundColor: Colors.red,
                          child: Icon(CupertinoIcons.delete_solid,
                              color: MyColors.white, size: 12.sp),
                        ),
                      )
                    ],
                  ),
          ),
          ),
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
            SizedBox(width: 10.w),
            Text(
              title,
              style: MyColors.dividerColor.medium16,
            ),
            Visibility(visible: title.isNotEmpty, child: SizedBox(width: 3.w)),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(context).medium17,
              ),
            ),
          ],
        ),
      );
}

import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../helpers/responsive_helper.dart';

class EmployeeJobPostWidget extends StatelessWidget {
  final Job jobPost;
  final bool isMyJobPost;
  EmployeeJobPostWidget(
      {super.key, required this.jobPost, required this.isMyJobPost});
  final EmployeeHomeController employeeHomeController = Get.find();
  final AppController appController = Get.find();
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
            padding: const EdgeInsets.all(15.0),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                border: Border.all(color: MyColors.noColor, width: 0.5),
                borderRadius: BorderRadius.circular(10.0),
                color: MyColors.lightCard(context)),
            width: Get.width,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                        height: 25,
                        width: 25,
                        child: CustomNetworkImage(
                            url: (jobPost.positionId?.logo ?? "")
                                .uniformImageUrl)),
                    Text(" ${jobPost.positionId?.name ?? ""}",
                        style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium15),
                    const SizedBox(width: 20),
                    _detailsItem(
                        MyAssets.exp,
                        MyStrings.exp.tr,
                        (jobPost.experience!.isEmpty ||
                                jobPost.experience == null)
                            ? ' ${jobPost.minExperience==null || jobPost.minExperience=='null'? "":jobPost.minExperience} - ${jobPost.minExperience==null || jobPost.maxExperience=='null'? "":jobPost.maxExperience}  Years'
                            : ' ${jobPost.experience != null && jobPost.experience!.toString().length > 10 ? '${jobPost.experience!.toString().substring(0, 10)}...' : jobPost.experience!}',
                        context),
                  ],                       

                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  if (currencySymbol.isNotEmpty &&
                    // jobPost.minRatePerHour != null &&
                    // jobPost.maxRatePerHour != null)
                    if (currencySymbol.isNotEmpty && jobPost.salary != null)
                      // _detailsItem(
                      //   MyAssets.rate,
                      //   "",

                      //   "$currencySymbol${jobPost.minRatePerHour!.toStringAsFixed(2)}"
                      //       "- $currencySymbol ${jobPost.maxRatePerHour!.toStringAsFixed(2)}",
                      //   context,
                      // ),
                      _detailsItem(
                        MyAssets.rate,
                        "",
                        (jobPost.salary!.isEmpty || jobPost.salary == null)
                            ? '$currencySymbol ${jobPost.minRatePerHour} - $currencySymbol ${jobPost.maxRatePerHour}'
                            : ' ${jobPost.salary != null && jobPost.salary!.toString().length > 15 ? '${jobPost.salary!.toString().substring(0, 15)}...' : jobPost.salary!}',
                        context,
                      ),
                    // _detailsItem(
                    //     MyAssets.rate,
                    //     "${MyStrings.rate.tr}:",
                    //     "${Utils.getCurrencySymbolModified(jobPost.clientId!.countryName.toString())}${jobPost.minRatePerHour} - ${Utils.getCurrencySymbolModified(jobPost.clientId!.countryName.toString())}${jobPost.maxRatePerHour}",
                    //     context),
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
                    _detailsItem(MyAssets.location, "",
                        jobPost.clientId?.countryName ?? "", context),
                  ],
                )
              ],
            )),
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
        if (!isMyJobPost)
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
                    onTap: () =>
                        //  Get.isRegistered<EmployeeHomeController>()
                        //     ?
                        employeeHomeController.onFullViewClick(
                            jobPostId: jobPost.id ?? "", isMyJobPost: false),
                    // : Get.find<AdminHomeController>()
                    //     .onViewDetailsClicked(jobPostId: jobPost.id ?? ""),
                    margin: EdgeInsets.zero,
                    fontSize: ResponsiveHelper.isTab(context)?17:13,
                    customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                    text: MyStrings.viewJobDetails.tr),
              ),
            ),
          )
        // Positioned.fill(
        //   child: Align(
        //     alignment: Alignment.topRight,
        //     child: SizedBox(
        //       width: Get.width>600?90.w:150.w,
        //       child: CustomButtons.button(
        //           height: Get.width>600? 25.h:30,
        //           onTap: () => Get.isRegistered<EmployeeHomeController>()
        //               ? Get.find<EmployeeHomeController>()
        //                   .onFullViewClick(jobPostId: jobPost.id ?? "")
        //               : Get.find<AdminHomeController>()
        //                   .onViewDetailsClicked(jobPostId: jobPost.id ?? ""),
        //           margin: EdgeInsets.zero,
        //           fontSize: Get.width>600?9.sp:11,
        //           customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
        //           text: MyStrings.viewJobDetails.tr),
        //     ),
        //   ),
        // )
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
              style: ResponsiveHelper.isTab(context)?MyColors.dividerColor.medium9:MyColors.dividerColor.medium14,
            ),
            Visibility(visible: title.isNotEmpty, child: SizedBox(width: 3.w)),
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium17,
              ),
            ),
          ],
        ),
      );
}

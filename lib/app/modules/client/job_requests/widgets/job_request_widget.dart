import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/job_requests/controllers/job_requests_controller.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';

class JobRequestWidget extends StatelessWidget {
  final Job jobRequest;
  const JobRequestWidget({super.key, required this.jobRequest});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            margin: const EdgeInsets.only(bottom: 15.0),
            decoration: BoxDecoration(
              color: MyColors.lightCard(context),
              borderRadius: BorderRadius.circular(10.0).copyWith(
                bottomRight: const Radius.circular(11),
              ),
              border: Border.all(
                width: .5,
                color: MyColors.c_A6A6A6,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 15.h),
                Row(
                  children: [
                    SizedBox(width: 10.w),
                    SizedBox(
                      height: 20,
                      width: 20,
                      child: CustomNetworkImage(
                        url: (jobRequest.positionId?.logo ?? "").uniformImageUrl,
                        fit: BoxFit.fill,
                        radius: 5,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(jobRequest.positionId?.name ?? "", style: MyColors.l111111_dwhite(context).medium15),
                    SizedBox(width: 10.w),
                    Visibility(
                        visible: (jobRequest.users ?? []).isNotEmpty,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: MyColors.c_C6A34F,
                          child: Text("${(jobRequest.users ?? []).length}", style: MyColors.white.semiBold12),
                        ))
                  ],
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    SizedBox(width: 10.w),
                    _detailsItem(MyAssets.exp, MyStrings.exp.tr,
                        "${jobRequest.minExperience} - ${jobRequest.maxExperience} years", context),
                    _detailsItem(
                        MyAssets.rate,
                        'Rate:',
                        "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(jobRequest.minRatePerHour ?? 0.0).toStringAsFixed(2)} - ${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(jobRequest.maxRatePerHour ?? 0.0).toStringAsFixed(2)}",
                        context),
                    InkResponse(
                      onTap: () => Get.find<JobRequestsController>().onEditClick(jobRequest: jobRequest),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.edit, color: MyColors.white, size: 12),
                      ),
                    ),
                    SizedBox(width: 5.w),
                    InkResponse(
                      onTap: () => Get.find<JobRequestsController>().onDeleteClick(jobId: jobRequest.id ?? ""),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Icon(CupertinoIcons.delete_solid, color: MyColors.white, size: 12),
                      ),
                    ),
                    SizedBox(width: 5.w),
                  ],
                ),
                SizedBox(height: 15.h),
              ],
            )),
        Positioned(
            top: 0,
            right: 0,
            child: Visibility(
              visible: (jobRequest.users ?? []).isNotEmpty,
              child: CustomButtons.button(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                height: 28,
                text: ("View Job Details"),
                margin: EdgeInsets.zero,
                fontSize: 12,
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                onTap: () => Get.find<JobRequestsController>().onJobDetailsClick(jobDetails: jobRequest),
              ),
            ))
      ],
    );
  }

  Widget _detailsItem(String icon, String title, String value, BuildContext context) => Expanded(
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
              style: MyColors.l7B7B7B_dtext(Get.context!).medium11,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(Get.context!).medium11,
              ),
            ),
          ],
        ),
      );
}

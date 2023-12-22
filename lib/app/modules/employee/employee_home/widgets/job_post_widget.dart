import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class JobPostWidget extends StatelessWidget {
  final Job jobPost;
  const JobPostWidget({super.key, required this.jobPost});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(10.0),
        margin: EdgeInsets.only(right: 10.0.w),
        width: MediaQuery.sizeOf(context).width * 0.5,
        decoration: MyDecoration.cardBoxDecoration(context: context),
        child: Column(
          children: [
            SizedBox(
                height: 40,
                width: 40,
                child: CustomNetworkImage(url: (jobPost.positionId?.logo ?? "").uniformImageUrl)),
            SizedBox(height: 5.h),
            Text(jobPost.positionId?.name ?? "", style: MyColors.l111111_dwhite(context).semiBold15),
            SizedBox(height: 10.h),
            const Divider(color: MyColors.c_C6A34F, thickness: 0.5, height: 0.0),
            SizedBox(height: 10.h),
            _detailsItem(
                MyAssets.rate,
                "${MyStrings.rate.tr}:",
                "${Utils.getCurrencySymbol(Get.find<EmployeeHomeController>().appController.user.value.employee?.countryName ?? "")}${jobPost.minRatePerHour}/hour - ${Utils.getCurrencySymbol(Get.find<EmployeeHomeController>().appController.user.value.employee?.countryName ?? "")}${jobPost.maxRatePerHour}/hour",
                context),
            _detailsItem(
                MyAssets.exp, MyStrings.exp.tr, "${jobPost.minExperience} - ${jobPost.maxExperience} years", context),
            _detailsItem(MyAssets.nationality, "${MyStrings.nationality.tr}:",
                (jobPost.nationalities ?? []).isEmpty ? "TBA" : (jobPost.nationalities ?? []).first, context),
            _detailsItem(
                MyAssets.calendar,
                "",
                "${(jobPost.publishedDate ?? DateTime.now()).dMMMy} - ${(jobPost.endDate ?? DateTime.now()).dMMMy}",
                context),
            SizedBox(height: 10.h),
            CustomButtons.button(
                height: 35.h,
                onTap: () => Get.find<EmployeeHomeController>().onFullViewClick(jobPostDetails: jobPost),
                margin: EdgeInsets.zero,
                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                text: "Full View"),
            SizedBox(height: 5.h),
          ],
        ));
  }

  Widget _detailsItem(String icon, String title, String value, BuildContext context) => Expanded(
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 16.w,
              height: 16.w,
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: MyColors.l7B7B7B_dtext(context).medium12,
            ),
            Visibility(visible: title.isNotEmpty, child: SizedBox(width: 3.w)),
            Flexible(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(context).medium12,
              ),
            ),
          ],
        ),
      );
}

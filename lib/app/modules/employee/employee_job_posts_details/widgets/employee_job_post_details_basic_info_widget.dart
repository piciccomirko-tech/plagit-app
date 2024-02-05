import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/details_item_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostDetailsBasicInfoWidget extends GetWidget<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostDetailsBasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
        width: double.infinity,
        padding: const EdgeInsets.all(15.0),
        decoration: MyDecoration.cardBoxDecoration(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: CustomNetworkImage(url: (controller.jobPostDetails.positionId?.logo ?? "").uniformImageUrl),
              ),
            ),
            SizedBox(height: 5.h),
            Center(
                child: Text(controller.jobPostDetails.positionId?.name ?? "",
                    style: MyColors.l111111_dwhite(context).semiBold16)),
            SizedBox(height: 15.h),
            const Divider(
              height: 0.0,
              thickness: 0.5,
              color: MyColors.c_A6A6A6,
            ),
            SizedBox(height: 10.h),
            Text("${MyStrings.requirements.tr}:", style: MyColors.c_A6A6A6.medium13),
            SizedBox(height: 15.h),
            DetailsItemWidget(
                icon: MyAssets.rate,
                title: "${MyStrings.rate.tr}:",
                value: Flexible(
                  child: Text(
                    "${Utils.getCurrencySymbol(Get.find<EmployeeHomeController>().appController.user.value.employee?.countryName ?? "")}${controller.jobPostDetails.minRatePerHour}/hour - ${Utils.getCurrencySymbol(Get.find<EmployeeHomeController>().appController.user.value.employee?.countryName ?? "")}${controller.jobPostDetails.maxRatePerHour}/Hour",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: MyColors.l111111_dwhite(context).medium13,
                  ),
                )),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.exp,
                title: MyStrings.exp.tr,
                value: Text(
                    "${controller.jobPostDetails.minExperience} - ${controller.jobPostDetails.maxExperience} ${MyStrings.years.tr}",
                    style: MyColors.l111111_dwhite(context).medium13)),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.flag,
                title: "${MyStrings.preferred.tr} ${MyStrings.nationality.tr}:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            (controller.jobPostDetails.nationalities ?? []).length,
                            (index) => Text("${(controller.jobPostDetails.nationalities ?? [])[index]}, ",
                                // maxLines: 2,
                                //overflow: TextOverflow.ellipsis,
                                style: MyColors.l111111_dwhite(context).medium13))),
                  ),
                )
            ),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.language,
                title: "${MyStrings.preferred.tr} ${MyStrings.language.tr}:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            (controller.jobPostDetails.languages ?? []).length,
                            (index) => Text("${(controller.jobPostDetails.languages ?? [])[index]}, ",
                                // maxLines: 2,
                                //overflow: TextOverflow.ellipsis,
                                style: MyColors.l111111_dwhite(context).medium13))),
                  ),
                )),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.calendar,
                title: "${MyStrings.workSchedule.tr}:",
                value: Row(
                  children: [
                    Text(" ${MyStrings.total.tr} ${(controller.jobPostDetails.dates ?? []).calculateTotalDays()} ${MyStrings.days.tr}   ",
                        style: MyColors.l111111_dwhite(context).medium13),
                    CustomButtons.button(
                        customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                        height: 23,
                        fontSize: 12,
                        text: " ${MyStrings.details.tr} ",
                        margin: EdgeInsets.zero,
                        onTap: controller.onDetailsClick)
                  ],
                ))
          ],
        ));
  }
}

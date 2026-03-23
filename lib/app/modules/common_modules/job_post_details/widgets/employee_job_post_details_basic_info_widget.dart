import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/common/widgets/details_item_widget.dart';
import 'package:mh/app/modules/common_modules/job_post_details/controllers/job_post_details_controller.dart';

class EmployeeJobPostDetailsBasicInfoWidget
    extends GetWidget<JobPostDetailsController> {
  const EmployeeJobPostDetailsBasicInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // String currencySign= CurrencyUtils.getCurrencySymbolByCountry(controller.appController.user.value.userCountry) ?? '\$';
        String currencySymbol = controller.jobPostDetails.value.clientId==null || controller.jobPostDetails.value.clientId!.countryName!.isEmpty? '\$': Utils.getCurrencySymbolModified(controller.jobPostDetails.value.clientId!.countryName.toString());

    return Container(
        margin: EdgeInsets.only(bottom: 15.h),
        width: double.infinity,
        padding: const EdgeInsets.all(15.0),
        decoration: MyDecoration.cardBoxDecorationTransparent(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 80,
                width: 80,
                child: CustomNetworkImage(
                    url:
                        (controller.jobPostDetails.value.positionId?.logo ?? "")
                            .uniformImageUrl),
              ),
            ),
            SizedBox(height: 5.h),
            Center(
                child: Text(
                    controller.jobPostDetails.value.positionId?.name ?? "",
                    style: MyColors.l111111_dwhite(context).semiBold16)),
            SizedBox(height: 15.h),
            const Divider(
              height: 0.0,
              thickness: 0.5,
              color: MyColors.c_A6A6A6,
            ),
            SizedBox(height: 10.h),
            Text("${MyStrings.requirements.tr}:",
                style: MyColors.c_A6A6A6.medium13),
            SizedBox(height: 15.h),
            // DetailsItemWidget(
            //     icon: MyAssets.rate,
            //     title: "${MyStrings.rate.tr}:",
            //     value: Flexible(
            //       child: Text(
            //         "${Utils.getCurrencySymbol()}${controller.jobPostDetails.value.minRatePerHour}/hour - ${Utils.getCurrencySymbol()}${controller.jobPostDetails.value.maxRatePerHour}/Hour",
            //         maxLines: 2,
            //         overflow: TextOverflow.ellipsis,
            //         style: MyColors.l111111_dwhite(context).medium13,
            //       ),
            //     )),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.exp,
                title: MyStrings.exp.tr,
                value: Text(
                    "${(controller.jobPostDetails.value.experience==null || controller.jobPostDetails.value.experience!.isEmpty  )? '${controller.jobPostDetails.value.minExperience==null || controller.jobPostDetails.value.minExperience=='null'?'0':controller.jobPostDetails.value.minExperience} - ${controller.jobPostDetails.value.maxExperience==null || controller.jobPostDetails.value.maxExperience=='null'?'0':controller.jobPostDetails.value.maxExperience} Years' : '${controller.jobPostDetails.value.experience}' }",
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
                            (controller.jobPostDetails.value.nationalities ??
                                    [])
                                .length,
                            (index) => Text(
                                "${(controller.jobPostDetails.value.nationalities ?? [])[index]}${index == (controller.jobPostDetails.value.nationalities ?? []).length - 1 ? '.' : ', '}",
                                softWrap: false, // Prevents wrapping
                                maxLines: 8,
                                overflow: TextOverflow
                                    .ellipsis, // Adds ellipsis if the text overflows
                                style: MyColors.l111111_dwhite(context)
                                    .medium13))),
                  ),
                )),
            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.language,
                title: "${MyStrings.preferred.tr} ${MyStrings.language.tr}:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: List.generate(
                            (controller.jobPostDetails.value.languages ?? [])
                                .length,
                            (index) => Text(
                                "${(controller.jobPostDetails.value.languages ?? [])[index]}${index == (controller.jobPostDetails.value.languages ?? []).length - 1 ? '.' : ', '}",
                                // maxLines: 2,
                                //overflow: TextOverflow.ellipsis,
                                style: MyColors.l111111_dwhite(context)
                                    .medium13))),
                  ),
                )),
            SizedBox(height: 10.h), 
            // Text("currency: ${CurrencyUtils.getCurrencySymbolByCountry(controller.appController.user.value.userCountry)}"),
            DetailsItemWidget(
                icon: MyAssets.language,
                title: "Salary:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:Text(
                    " ${controller.jobPostDetails.value.salary!.isEmpty || controller.jobPostDetails.value.salary==null? '$currencySymbol ${controller.jobPostDetails.value.minRatePerHour=='null' || controller.jobPostDetails.value.minRatePerHour==null?'0':controller.jobPostDetails.value.minRatePerHour} - $currencySymbol ${controller.jobPostDetails.value.maxRatePerHour=='null' || controller.jobPostDetails.value.maxRatePerHour==null?'0':controller.jobPostDetails.value.maxRatePerHour}' : ' ${controller.jobPostDetails.value.salary}'}",
                    style: MyColors.l111111_dwhite(context).medium13)
                  ),
                )),
                          SizedBox(height: 10.h), 
            DetailsItemWidget(
                icon: MyAssets.manager,
                title: "Age:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:Text(
                    " ${controller.jobPostDetails.value.age!.isEmpty || controller.jobPostDetails.value.age==null? ' ${controller.jobPostDetails.value.minAge=='null' || controller.jobPostDetails.value.minAge==null?'':controller.jobPostDetails.value.minAge} - ${controller.jobPostDetails.value.maxAge=='null' || controller.jobPostDetails.value.maxAge==null?'':controller.jobPostDetails.value.maxAge} Years' : '${controller.jobPostDetails.value.age} Years'}",
                    style: MyColors.l111111_dwhite(context).medium13)
                  ),
                )),
                          SizedBox(height: 10.h), 
            DetailsItemWidget(
                icon: MyAssets.manager,
                title: "Vancancy:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:Text(
                    " ${ '${controller.jobPostDetails.value.vacancy} ' }",
                    style: MyColors.l111111_dwhite(context).medium13)
                  ),
                )),
                          SizedBox(height: 10.h), 
            DetailsItemWidget(
                icon: MyAssets.manager,
                title: "Total Applied:",
                value: Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child:Text(
                    " ${ '${(controller.jobPostDetails.value.users?? []) .length ?? 0} ' }",
                    style: MyColors.l111111_dwhite(context).medium13)
                  ),
                )),

            SizedBox(height: 10.h),
            DetailsItemWidget(
                icon: MyAssets.calendar,
                title: "${MyStrings.workSchedule.tr}:",
                value: Row(
                  children: [
                    // Text(" ${MyStrings.total.tr} ${(controller.jobPostDetails.value.dates ?? []).calculateTotalDays()} ${MyStrings.days.tr}   ",
                    //     style: MyColors.l111111_dwhite(context).medium13),
                    // Text(
                    //     " ${MyStrings.total.tr} ${(controller.jobPostDetails.value.dates ?? []).calculateTotalMonths()} ${(controller.jobPostDetails.value.dates ?? []).calculateTotalMonths() > 1 ? 'Months' : 'Month'}    ",
                    //     style: MyColors.l111111_dwhite(context).medium13),
                    Text(
                        " ${MyStrings.total.tr} ${(controller.jobPostDetails.value.dates ?? []).length} ${(controller.jobPostDetails.value.dates ?? []).length > 1 ? 'Slots' : 'Slot'}    ",
                        style: MyColors.l111111_dwhite(context).medium13),
                    Visibility(
                      // visible:(controller.jobPostDetails.value.dates ?? []).calculateTotalMonths()>0,
                      visible:(controller.jobPostDetails.value.dates ?? []).length>0,
                      child: CustomButtons.button(
                          customButtonStyle:
                              CustomButtonStyle.radiusTopBottomCorner,
                          height: Get.width > 600 ? 30.h : 23.h,
                          fontSize: 12.sp,
                          text: " ${MyStrings.details.tr} ",
                          margin: EdgeInsets.zero,
                          onTap: controller.onDetailsClick),
                    )
                  ],
                ))
          ],
        ));
  }
}

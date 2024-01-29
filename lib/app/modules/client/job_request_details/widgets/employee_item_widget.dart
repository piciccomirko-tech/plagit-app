import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_buttons.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/enums/custom_button_style.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/job_request_details/controllers/job_request_details_controller.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';

class EmployeeItemWidget extends StatelessWidget {
  final User user;
  const EmployeeItemWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w).copyWith(
        top: 15.h,
      ),
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
      child: Stack(
        children: [
          Positioned(
            right: 5,
            top: 3,
            child: Obx(
              () => Get.find<JobRequestDetailsController>().shortlistController.getIcon(
                  requestedDateList: <RequestDateModel>[],
                  employeeId: user.id!,
                  isFetching: Get.find<JobRequestDetailsController>().shortlistController.isFetching.value,
                  fromWhere: '',
                  uniformMandatory: false),
            ),
          ),
          Row(
            children: [
              _image((user.profilePicture ?? "").imageUrl),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16.h),
                              Row(
                                children: [
                                  Flexible(flex: user.rating! > 0.0 ? 3 : 4, child: _name(user.name ?? "-", context)),
                                  if (user.verified != null && user.verified == true)
                                    Image.asset(MyAssets.certified, height: 30, width: 30),
                                  Expanded(flex: 2, child: _rating(user.rating ?? 0.0, context)),
                                  const Expanded(flex: 2, child: Wrap()),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    const Divider(
                      thickness: .5,
                      height: 1,
                      color: MyColors.c_D9D9D9,
                      endIndent: 13,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        _detailsItem(MyAssets.exp, MyStrings.exp.tr, "${user.employeeExperience ?? 0} ${MyStrings.years.tr}", context),
                        Visibility(
                          visible: (user.nationality??"").isNotEmpty,
                            child: _detailsItem(MyAssets.flag, '', user.nationality ?? '', context)),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(children: [
                      _detailsItem(
                          MyAssets.rate,
                          '${MyStrings.rate.tr}:',
                          "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(user.hourlyRate ?? 0.0).toStringAsFixed(2)}",
                          context),
                      // _detailsItem(MyAssets.manager, MyStrings.age.tr, user.dateOfBirth?.calculateAge() ?? '', context),
                    ]),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CustomButtons.button(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          height: 23,
                          text: MyStrings.bookNow.tr,
                          margin: EdgeInsets.zero,
                          fontSize: 12,
                          customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                          onTap: () =>
                              Get.find<JobRequestDetailsController>().onBookNowClick(employeeId: user.id ?? ""),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _image(String profilePicture) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 13, 16),
        width: 70.w,
        height: 74.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.withOpacity(.1),
        ),
        child: CustomNetworkImage(
          url: profilePicture,
          fit: BoxFit.fill,
          radius: 5,
        ),
      );

  Widget _name(String name, context) => Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: MyColors.l111111_dwhite(context).medium14,
      );

  Widget _rating(double rating, context) => Visibility(
        visible: rating > 0.0,
        child: Row(
          children: [
            SizedBox(width: 10.w),
            Container(
              height: 2.h,
              width: 2.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.l111111_dwhite(context),
              ),
            ),
            SizedBox(width: 10.w),
            const Icon(
              Icons.star,
              color: MyColors.c_FFA800,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              rating.toString(),
              style: MyColors.l111111_dwhite(context).medium14,
            ),
          ],
        ),
      );

  Widget _detailsItem(String icon, String title, String value, context) => Expanded(
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
              style: MyColors.l7B7B7B_dtext(context).medium11,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(context).medium11,
              ),
            ),
          ],
        ),
      );
}

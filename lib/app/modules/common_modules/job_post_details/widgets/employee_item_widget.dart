import 'package:flutter/cupertino.dart';
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
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/common_modules/job_post_details/controllers/job_post_details_controller.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/routes/app_pages.dart';

class EmployeeItemWidget extends StatelessWidget {
  final User user;
  EmployeeItemWidget({super.key, required this.user});
  // final JobPostDetailsController jobDetailsController =
  //     Get.find<JobPostDetailsController>();
  final AppController appController = Get.find<AppController>();
  @override
  Widget build(BuildContext context) {
   bool isBookNowShow= !appController.user.value.isEmployee && appController.user.value.isClient && appController.user.value.userCountry==user.countryName && !appController.user.value.isAdmin;
    return GestureDetector(
      onTap: () =>
          Get.toNamed(Routes.employeeDetails, arguments: {'employeeId':user.id ?? ""}),
      child: Container(
        margin: EdgeInsets.only(bottom: 15.w),
        decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: BorderRadius.circular(10.0).copyWith(
            bottomRight: const Radius.circular(11),
          ),
          border: Border.all(
            width: .5,
            color: MyColors.noColor,
          ),
        ),
        child: Stack(
          children: [
            Visibility(
              visible: isBookNowShow,
              child: Positioned(
                right: 5,
                top: 3,
                child: Obx(
                  () => Get.find<JobPostDetailsController>()
                      .shortlistController
                      .getIcon(
                          requestedDateList: <RequestDateModel>[],
                          employeeId: user.id!,
                          isFetching: Get.find<JobPostDetailsController>()
                              .shortlistController
                              .isFetching
                              .value,
                          fromWhere: '',
                          uniformMandatory: false),
                ),
              ),
            ),
            Positioned(
              right: isBookNowShow? 40.w:4,
              top: 4.h,
              child: Obx(()=>_chat(
                unreadMessage: user.unreadChatCount??0,
                liveChatDataTransferModel: LiveChatDataTransferModel(
                    toName: user.name ?? '',
                    toId: user.id ?? '',
                    senderId: Get.find<AppController>().user.value.userId,
                    toProfilePicture: (user.profilePicture ?? "").imageUrl,
                    bookedId: ''),
              )),
            ),
            Row(
              children: [
                ((user.profilePicture ?? "").isEmpty) ||
                        user.profilePicture == "undefined"
                    ? Container(
                        margin: const EdgeInsets.fromLTRB(16, 16, 13, 16),
                        width: 70.w,
                        height: 74.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.withOpacity(.1),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.0),
                            child: Image.asset(MyAssets.employeeDefault,
                                fit: BoxFit.fill)),
                      )
                    : _image((user.profilePicture ?? "").imageUrl),
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
                                    Flexible(
                                        flex: user.rating! > 0.0 ? 3 : 4,
                                        child:
                                            _name(user.name ?? "-", context)),
                                    if (user.verified != null &&
                                        user.verified == true)
                                      Image.asset(MyAssets.certified,
                                          height: 30, width: 30),
                                    Expanded(
                                        flex: 2,
                                        child: _rating(
                                            user.rating ?? 0.0, context)),
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
                          _detailsItem(
                              MyAssets.exp,
                              MyStrings.exp.tr,
                              "${user.employeeExperience ?? 0} ${MyStrings.years.tr}",
                              context),
                          Visibility(
                              visible: (user.nationality ?? "").isNotEmpty,
                              child: _detailsItem(MyAssets.flag, '',
                                  user.nationality ?? '', context)),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(children: [
                        // Text("${user.countryName!.toString()}"),
                        _detailsItem(
                            MyAssets.rate,
                            '${MyStrings.rate.tr}:',
                            "${Utils.getCurrencySymbolModified(user.countryName!.toString())}${(user.hourlyRate ?? 0.0).toStringAsFixed(2)}",
                            context),
                        // _detailsItem(MyAssets.manager, MyStrings.age.tr, user.dateOfBirth?.calculateAge() ?? '', context),
                      ]),
                      SizedBox(height: 8.h),
                      // Text("${!appController.user.value.isEmployee}"),
                      // Text("${appController.user.value.isClient}"),
                      // Text("${appController.user.value.userCountry}"),
                      // Text("${user.countryName}"),
                      // Text("---------rr-"),
      //                 Text("${ 
      // Utils.getPositionName("${appController.user.value.employee!.positionId}").toLowerCase() 
      //    }"),


                      Visibility(
                        // visible: !appController.user.value.isEmployee && appController.user.value.isClient && appController.user.value.userCountry==user.countryName && !appController.user.value.isAdmin,
                        visible: isBookNowShow,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomButtons.button(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              height: Get.width > 600 ? 30.h : 48.h,
                              text: MyStrings.bookNow.tr,
                              margin: EdgeInsets.zero,
                              fontSize: 12,
                              customButtonStyle:
                                  CustomButtonStyle.radiusTopBottomCorner,
                              onTap: () => Get.find<JobPostDetailsController>()
                                  .onBookNowClick(employeeId: user.id ?? ""),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chat(
          {required LiveChatDataTransferModel liveChatDataTransferModel,
          required int unreadMessage}) =>
      Get.find<JobPostDetailsController>().isFetching.value && Get.find<JobPostDetailsController>().isFetchingId.value==liveChatDataTransferModel.toId?const SizedBox(
        width: 20,
        height: 20,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      ):GestureDetector(
        onTap: () => Get.find<JobPostDetailsController>().chatWithEmployee(
            liveChatDataTransferModel: liveChatDataTransferModel),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.message,
                color: MyColors.c_C6A34F,
              ),
              Visibility(
                  visible: unreadMessage > 0,
                  child: Positioned(
                    top: -10.h,
                    right: -5.w,
                    child: CircleAvatar(
                        backgroundColor: MyColors.white,
                        radius: 10,
                        child: Text(unreadMessage.toString(),
                            style: MyColors.c_C6A34F.semiBold12)),
                  ))
            ],
          ),
        ),
      );

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

  Widget _detailsItem(String icon, String title, String value, context) =>
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

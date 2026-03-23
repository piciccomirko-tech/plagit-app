import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/deep_link_service/deep_link_service.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/data/data.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/employee_details/models/certificate_model.dart';
import '../../../common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import '../../../employee/employee_edit_profile/widgets/PDFThumbnail.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileEmployeeProfileWidget
    extends GetWidget<UserProfileController> {
  const UserProfileEmployeeProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 15.w),
          _imageBookmark,
          SizedBox(height: 15.w),
          // _clientBasic,
          _candidateBasicInfo,
          SizedBox(height: 15.w),
          _skill,
          SizedBox(height: 15.w),
          _education,
          SizedBox(height: 15.w),
          _certificate,
          SizedBox(height: 15.w),
          language,
          SizedBox(height: 15.w),
          _country,
          SizedBox(height: 30.w),
          if ((controller.employee.value.presentAddress != null &&
              controller.employee.value.presentAddress!.isNotEmpty))
            _employeeLocation,
          if ((controller.employee.value.restaurantAddress != null &&
              controller.employee.value.restaurantAddress!.isNotEmpty))
            _clientLocation,
          SizedBox(height: 30.w),
        ],
      ),
    );
  }

  Widget _clientRow(String? title, String? dataValue) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$title :",
            textAlign: TextAlign.center,
            maxLines: null,
            overflow: TextOverflow.ellipsis,
            style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
          ),
          Text(
            "$dataValue",
            textAlign: TextAlign.center,
            maxLines: null,
            overflow: TextOverflow.ellipsis,
            style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
          ),
        ],
      );
  Widget get _clientBasic => Container(
      padding: EdgeInsets.fromLTRB(35.w, 13.h, 35.w, 13.h),
      decoration: BoxDecoration(
        color: MyColors.lightCard(controller.context!),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(children: [
        Text(
          "${controller.employee.value.restaurantName?.toUpperCase()}",
          style: MyColors.l111111_dwhite(controller.context!).medium16,
        ),
        Divider(
          color: MyColors.l111111_dwhite(Get.context!),
        ),
        _clientRow("Profile Completed",
            "${controller.employee.value.profileCompleted}%"),
        _clientRow("Number Of Employee",
            "${controller.employee.value.noOfEmployee ?? 0}"),
        _clientRow("Email Varified",
            "${controller.employee.value.emailVerified == true ? 'Yes' : 'No'}"),
        _clientRow("Rating", "${controller.employee.value.rating}"),
        _clientRow("Total Rating", "${controller.employee.value.totalRating}"),
        _clientRow("Verification",
            "${controller.employee.value.verified == true ? 'Yes' : 'No'}"),
        // _clientRow("Company Registration","${controller.employee.value==true? 'Yes':'No'}"),
        _clientRow("Has Uniform",
            "${controller.employee.value.hasUniform == true ? 'Yes' : 'No'}"),
        _clientRow("ID No.", "${controller.employee.value.userIdNumber}"),
      ]));

  Widget get _imageBookmark => Container(
        width: 250.w,
        height: 250.w,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: (controller.employee.value.profilePicture == null) ||
                (controller.employee.value.profilePicture == "undefined")
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(MyAssets.employeeDefault, fit: BoxFit.cover))
            : CustomNetworkImage(
                url: (controller.employee.value.profilePicture ?? "").imageUrl,
                radius: 10,
                fit: BoxFit.cover,
              ),
      );

  Widget _base(
          {required Widget child,
          required String title,
          String? position,
          String? age,
          double? rating,
          int? totalRating,
          int? totalFollowers,
          int? totalFollowing,
          String? nationality,
          bool? certified,
          String? phone,
          bool showShare = false,
          bool showNotification = false}) =>
      Container(
        padding: EdgeInsets.fromLTRB(35.w, 13.h, 35.w, 13.h),
        decoration: BoxDecoration(
          color: MyColors.lightCard(controller.context!),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  overflow: TextOverflow.ellipsis,
                  style: MyColors.l111111_dwhite(controller.context!).medium17,
                ),
                if (certified != null && certified == true)
                  Image.asset(MyAssets.certified, height: 35, width: 35),
                if (showNotification)
                  Obx(() => controller.loadingToggleNotification.value
                      ? CupertinoActivityIndicator()
                      : controller.appController
                                  .isFollowing(controller.userId) &&
                              !controller.appController.user.value.isAdmin
                          ? Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: InkWell(
                                onTap: () {
                                  controller
                                      .toggleNotification(controller.userId);
                                },
                                child: Icon(
                                  controller.appController
                                          .isNotification(controller.userId)
                                      ? Icons.notifications_on
                                      : Icons.notifications_off,
                                  size: 20,
                                  color: MyColors.primaryDark,
                                ),
                              ),
                            )
                          : Offstage()),
                SizedBox(width: 15.w),
                totalFollowers != null &&
                        !controller.appController.user.value.isAdmin
                    ? Obx(() => controller.loadingFollow.value &&
                            controller.selectedIndex.value == -1
                        ? CupertinoActivityIndicator()
                        : controller.appController
                                .isFollowing(controller.userId)
                            ? InkWell(
                                onTap: () {
                                  controller.followUnfollow(
                                      controller.userId, -1);
                                },
                                child: Text(MyStrings.following.tr,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: MyColors.primaryDark,
                                      fontFamily: MyAssets.fontKlavika,
                                      fontWeight: FontWeight.w500,
                                    )))
                            : InkWell(
                                onTap: () {
                                  controller.followUnfollow(
                                      controller.userId, -1);
                                },
                                child: Text('+ ${MyStrings.follow.tr}',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: MyColors.primaryDark,
                                      fontFamily: MyAssets.fontKlavika,
                                      fontWeight: FontWeight.w500,
                                    ))))
                    : SizedBox(),
                if (showShare) SizedBox(width: 15.w),
                if (showShare)
                  InkWell(
                      onTap: () {
                        Share.share(DeepLinkService.generateAppLink(
                            "profile/${controller.userId}"));
                      },
                      child: Icon(
                        Icons.share,
                        size: 20,
                        color: MyColors.primaryLight,
                      )),
              ],
            ),
            SizedBox(height: 10.h),
            if (phone != null &&
                phone.isNotEmpty &&
                controller.appController.user.value.isAdmin)
              InkResponse(
                onTap: () => launchUrl(Uri.parse("tel:$phone")),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.phone_solid,
                        color: MyColors.c_C6A34F, size: 20),
                    Text(
                      phone,
                      textAlign: TextAlign.center,
                      style:
                          MyColors.l111111_dwhite(controller.context!).medium15,
                    ),
                  ],
                ),
              ),
            if (phone != null &&
                phone.isNotEmpty &&
                controller.appController.user.value.isAdmin)
              SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (position != null && position.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 3.0),
                    decoration: const BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0))),
                    child: Row(
                      children: [
                        const Icon(Icons.work_outline,
                            size: 15, color: MyColors.white),
                        SizedBox(width: 5.w),
                        Text(
                          position,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              fontSize: 15,
                              color: MyColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                SizedBox(width: 10.w),
                if (nationality != null && nationality.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 3.0),
                    decoration: const BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0))),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.flag,
                            size: 15, color: MyColors.white),
                        SizedBox(width: 5.w),
                        Text(
                          nationality,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontFamily: MyAssets.fontKlavika,
                              fontSize: 15,
                              color: MyColors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (position != null && position.isNotEmpty) SizedBox(height: 10.h),
            Visibility(
              visible: age != null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        age ?? "",
                        textAlign: TextAlign.center,
                        style: MyColors.l7B7B7B_dtext(controller.context!)
                            .medium15,
                      ),
                      SizedBox(width: 10.w),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: MyColors.c_FFA800,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        "${rating ?? 0.0} (${totalRating ?? 0})",
                        style: MyColors.l111111_dwhite(controller.context!)
                            .medium15,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
            totalFollowers != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _showFollowersFollowingBottomSheet(
                              Get.context!,
                              MyStrings.followers.tr,
                              controller.employeeFollowers.value.followers);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt,
                              size: 16,
                              color: MyColors.c_FFA800,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '$totalFollowers ${MyStrings.followers.tr}',
                              textAlign: TextAlign.center,
                              style: MyColors.l7B7B7B_dtext(controller.context!)
                                  .medium15,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 15.w),
                      InkWell(
                        onTap: () {
                          _showFollowersFollowingBottomSheet(
                              Get.context!,
                              MyStrings.following.tr,
                              controller.employeeFollowers.value.following);
                        },
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people_alt,
                              size: 16,
                              color: MyColors.c_FFA800,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '$totalFollowing ${MyStrings.following.tr}',
                              textAlign: TextAlign.center,
                              style: MyColors.l7B7B7B_dtext(controller.context!)
                                  .medium15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            SizedBox(height: 10.h),
            Divider(
              height: 1,
              thickness: .5,
              color: MyColors.lD9D9D9_dstock(controller.context!),
            ),
            SizedBox(height: 12.h),
            child,
            SizedBox(height: 5.h),
          ],
        ),
      );

  Widget _data(String icon, String? text) => text == null
      ? Text(
          MyStrings.foundNothing.tr,
          style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
        )
      : Row(
          children: [
            Image.asset(
              icon,
              width: 14.w,
              height: 14.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                text,
                style: MyColors.l7B7B7B_dtext(controller.context!).regular12,
              ),
            ),
          ],
        );

  Widget _detailsItem(String icon, String title, String value) => Row(
        children: [
          Image.asset(
            icon,
            width: 14.w,
            height: 14.w,
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: MyColors.l7B7B7B_dtext(controller.context!).medium15,
          ),
          SizedBox(width: 3.w),
          Text(
            value,
            style: MyColors.l111111_dwhite(controller.context!).medium16,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );

  Widget get _candidateBasicInfo => _base(
        phone: controller.employee.value.phoneNumber ?? '',
        position: controller.employee.value.positionName ?? "-",
        title:
            "${controller.employee.value.firstName ?? "-"} ${controller.employee.value.lastName ?? ""}",
        age:
            '${MyStrings.age.tr}: ${controller.employee.value.dateOfBirth?.calculateAge() ?? 0.0}',
        rating: controller.employee.value.rating ?? 0.0,
        totalRating: controller.employee.value.totalRating ?? 0,
        totalFollowers: controller.employeeFollowers.value.followers?.length,
        totalFollowing: controller.employeeFollowers.value.following?.length,
        nationality: controller.employee.value.nationality ?? '',
        certified: controller.employee.value.certified,
        showShare: true,
        showNotification: true,
        child: Column(
          children: [
            SizedBox(height: 5.h),
            Row(
              children: [
                _detailsItem(MyAssets.rate, '${MyStrings.rate.tr}:',
                    "${Utils.getCurrencySymbol()}${(controller.employee.value.hourlyRate?.toStringAsFixed(2) ?? 0)}/hour"),
                const Spacer(),
                _detailsItem(MyAssets.exp, MyStrings.exp.tr,
                    "${(controller.employee.value.employeeExperience ?? 0)} years"),
              ],
            ),
            // SizedBox(height: 18.h),
            // Row(
            //   children: [
            //     _detailsItem(
            //         MyAssets.totalHour,
            //         '${MyStrings.totalHour.tr}:',
            //         controller.employee.value.totalWorkingHour!.contains(':')
            //             ? "${controller.employee.value.totalWorkingHour ?? '0.0'}h"
            //             : "${double.parse(controller.employee.value.totalWorkingHour ?? '0.0')}h"),
            //     const Spacer(),
            //     _detailsItem(MyAssets.review, MyStrings.review.tr, "1 time"),
            //   ],
            // ),
            SizedBox(height: 18.h),
            Row(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _detailsItem(MyAssets.license, 'Email:', 'Verified'),
                const Spacer(),
                _detailsItem(MyAssets.calender2, "${MyStrings.free.tr}:",
                    controller.employee.value.available ?? "-"),
              ],
            ),
            SizedBox(height: 18.h),

            Row(
              children: [
                _detailsItem(
                    MyAssets.height,
                    "${MyStrings.height.tr}:",
                    controller.employee.value.height == null ||
                            controller.employee.value.height == 'null'
                        ? "-"
                        : controller.employee.value.height.toString()),
                const Spacer(),
                _detailsItem(MyAssets.dressSize, "${MyStrings.dressSize.tr}:",
                    controller.employee.value.dressSize ?? "-"),
              ],
            ),
            SizedBox(height: 18.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _detailsItem(
                    MyAssets.organization,
                    "${MyStrings.currentOrganization.tr}:",
                    controller.employee.value.currentOrganisation ?? "-"),
              ],
            ),
            SizedBox(height: 5.h),
          ],
        ),
      );

  Widget get _employeeLocation => _base(
        title: MyStrings.location.tr,
        child: Text(
          controller.employee.value.presentAddress ?? "-",
          style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
        ),
      );
  Widget get _clientLocation => _base(
        title: MyStrings.location.tr,
        child: Text(
          controller.employee.value.restaurantAddress ?? "-",
          style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
        ),
      );
  Widget get _country => _base(
        title: "Country",
        child: Center(
          child: Text(
            controller.employee.value.countryName ?? "-",
            style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
          ),
        ),
      );

  Widget get _skill => _base(
        title: MyStrings.skills.tr,
        child: Column(
          children: [
            if ((controller.employee.value.skills ?? []).isEmpty)
              Text(
                MyStrings.foundNothing.tr,
                style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
              )
            else
              ...(controller.employee.value.skills ?? []).map((e) {
                return _data(
                  MyAssets.skill,
                  e.skillName ?? "",
                );
              }),
          ],
        ),
      );
  Widget get _education => _base(
        title: MyStrings.education.tr,
        child: _data(
          MyAssets.education,
          controller.employee.value.higherEducation,
        ),
      );

  Widget get _certificate => _base(
      title: MyStrings.certificate.tr,
      child: SizedBox(
        height: controller.employee.value.certificates != null &&
                controller.employee.value.certificates!.isNotEmpty
            ? ((controller.employee.value.certificates!.length + 2) ~/ 3) *
                180.0
            : 40,
        child: _buildDocumentSection(Get.context!),
        // child: CertificateListWidget(certificates: controller.employee.value.certificates?? [])),
        //  _data(
        //   MyAssets.education,
        //   controller.employee.value.certificates?,
        // ),
      ));
// Widget to build the Document upload section (multiple files)
  Widget _buildDocumentSection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Prevent unnecessary expansion
        children: [
          Obx(() {
            final List<Certificate> certificates =
                (controller.employee.value.certificates ?? [])
                    .map((certificateJson) => Certificate.fromJson(
                        certificateJson as Map<String, dynamic>))
                    .toList();
            return certificates.isNotEmpty
                ? Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: certificates.map((certificate) {
                      final pdfUrl = certificate.attachment != null
                          ? "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${certificate.attachment}"
                          : null;
                      final certificateName =
                          certificate.certificateName ?? 'Unknown';
                      final certificateId = certificate.certificateId;

                      if (pdfUrl != null) {
                        return PdfThumbnailWidget(
                          pdfUrl: pdfUrl,
                          certificateName: certificateName,
                          certificateId: certificateId ?? '',
                          isRemoveIcon: false,
                          onDelete: (id) async {
                            // await controller.removeCertificate(id);
                          },
                        );
                      } else {
                        return Text(
                          MyStrings.foundNothing.tr,
                          style: MyColors.l7B7B7B_dtext(controller.context!)
                              .regular15,
                        );
                      }
                    }).toList(),
                  )
                : Center(
                    child: Text(
                      MyStrings.foundNothing.tr,
                      style:
                          MyColors.l7B7B7B_dtext(controller.context!).regular15,
                    ),
                  );
          }),

          // Upload Button for Documents
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget get language => _base(
        title: MyStrings.language.tr,
        child: Column(
          children: [
            if ((controller.employee.value.languages ?? []).isEmpty)
              Text(
                MyStrings.foundNothing.tr,
                style: MyColors.l7B7B7B_dtext(controller.context!).regular15,
              )
            else
              ...(controller.employee.value.languages ?? []).map((e) {
                return _data(
                  MyAssets.language,
                  e.capitalize ?? "",
                );
              }),
          ],
        ),
      );

  void _showFollowersFollowingBottomSheet(
      BuildContext context, String title, userList) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: MyAssets.fontKlavika,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1),
                // List
                Expanded(
                  child: userList.isEmpty
                      ? Center(child: Text("No followers to show"))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: userList.length, // Example: 20 users
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Get.back();
                                if (userList[index].role?.toLowerCase() ==
                                    "client") {
                                  if (Get.isRegistered<
                                      IndividualSocialFeedsController>()) {
                                    Get.find<IndividualSocialFeedsController>()
                                        .onlyLoadData(userList[index]);
                                  } else {
                                    Get.toNamed(Routes.individualSocialFeeds,
                                        arguments: SocialUser(
                                          id: userList[index].id,
                                          name: userList[index].name ??
                                              userList[index].restaurantName,
                                          positionName:
                                              userList[index].positionName,
                                          email: userList[index].email,
                                          role: userList[index].role,
                                          profilePicture:
                                              userList[index].profilePicture,
                                          countryName:
                                              userList[index].countryName,
                                        ));
                                  }
                                } else {
                                  if (Get.isRegistered<
                                      UserProfileController>()) {
                                    Get.find<UserProfileController>()
                                        .onlyLoadData({
                                      'employeeId': userList[index].id ?? ""
                                    });
                                  } else {
                                    Get.toNamed(Routes.employeeDetails,
                                        arguments: {
                                          'employeeId': userList[index].id ?? ""
                                        });
                                  }
                                }
                              },
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: userList[index].profilePicture !=
                                              null &&
                                          userList[index].profilePicture !=
                                              "undefined"
                                      ? Image.network(
                                          "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${userList[index].profilePicture}",
                                          fit: BoxFit.cover,
                                          width:
                                              48, // Ensure the image fits within the circle
                                          height: 48,
                                        )
                                      : Image.asset(
                                          userList[index].role.toUpperCase() ==
                                                  "EMPLOYEE"
                                              ? MyAssets.employeeDefault
                                              : userList[index]
                                                          .role
                                                          .toUpperCase() ==
                                                      "CLIENT"
                                                  ? MyAssets.clientDefault
                                                  : MyAssets.adminDefault,
                                          fit: BoxFit.cover,
                                          width: 48,
                                          height: 48,
                                        ),
                                ),
                              ),
                              title: userList[index].restaurantName == null
                                  ? Text(
                                      '${userList[index].name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Text(
                                      '${userList[index].restaurantName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                              subtitle: Row(
                                children: [
                                  if (userList[index].role.toUpperCase() ==
                                      "EMPLOYEE") ...[
                                    Text(
                                      ("${userList[index].positionName} . "),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyColors.l111111_dwhite(context)
                                          .regular11,
                                    ),
                                    SizedBox(width: 15.w),
                                  ],
                                  SvgPicture.network(
                                    Data.getCountryFlagByName(
                                        userList[index].countryName.toString()),
                                    width: 10,
                                    height: 10,
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      ("${userList[index].countryName}")
                                          .toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyColors.l111111_dwhite(context)
                                          .regular11,
                                    ),
                                  ),
                                ],
                              ), // Replace with user status
                              trailing: !controller
                                      .appController.user.value.isAdmin
                                  ? Obx(
                                      () => controller.loadingFollow.value &&
                                              controller.selectedIndex.value ==
                                                  index
                                          ? CupertinoActivityIndicator()
                                          : controller.appController
                                                  .isFollowing(
                                                      userList[index].id)
                                              ? InkWell(
                                                  onTap: () {
                                                    controller.followUnfollow(
                                                        userList[index].id,
                                                        index);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  5),
                                                        ),
                                                        border: Border.all(
                                                            color: MyColors
                                                                .primaryLight,
                                                            width: 1.5)),
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        MyStrings.following.tr,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontFamily: MyAssets
                                                              .fontKlavika,
                                                        )),
                                                  ),
                                                )
                                              : InkWell(
                                                  onTap: () {
                                                    controller.followUnfollow(
                                                        userList[index].id,
                                                        index);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          MyColors.primaryLight,
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(5),
                                                        bottomRight:
                                                            Radius.circular(5),
                                                      ),
                                                    ),
                                                    padding: EdgeInsets.all(8),
                                                    child: Text(
                                                        MyStrings.follow.tr,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontFamily: MyAssets
                                                                .fontKlavika)),
                                                  ),
                                                ),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

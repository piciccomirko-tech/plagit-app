import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/data/data.dart';
import '../../../../common/deep_link_service/deep_link_service.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/employee_details/controllers/employee_details_controller.dart';

class SocialUserInfoWidget extends GetWidget<IndividualSocialFeedsController> {
  const SocialUserInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Image.asset(
                  fit: BoxFit.cover,
                  MyAssets.coverImage,
                  colorBlendMode: BlendMode.darken,
                  color: MyColors.black.withOpacity(0.7),
                  height: Get.width * 0.3,
                  width: Get.width),
            ),
            Obx(() => Positioned(
                bottom: 0,
                left: 10,
                child: CircleAvatar(
                  backgroundColor: MyColors.primaryLight,
                  radius: 52,
                  child: controller.loadingUserDetails.value
                      ? CupertinoActivityIndicator()
                      : ((controller.socialUser.profilePicture ?? "").isEmpty ||
                              (controller.socialUser.profilePicture ==
                                  "undefined"))
                          ? DefaultImageWidget(
                              radius: 120,
                              defaultImagePath:
                                  (controller.socialUser.role ?? "")
                                              .toUpperCase() ==
                                          "EMPLOYEE"
                                      ? MyAssets.employeeDefault
                                      : MyAssets.clientDefault)
                          : CircleAvatar(
                              radius: 50,
                              backgroundImage: CachedNetworkImageProvider(
                                  ((controller.socialUser.profilePicture ?? "")
                                      .imageUrl)),
                            ),
                ))),
            Positioned(
              bottom: 0,
              right: 10,
              child: Row(
                children: [
                  Text(
                      controller.socialUser.role?.toUpperCase() == "EMPLOYEE"
                          ? "CANDIDATE"
                          : "BUSINESS",
                      style: MyColors.l111111_dwhite(context).medium13),
                  if ((controller.socialUser.positionName ?? "")
                      .isNotEmpty) ...[
                    SizedBox(width: 10.w),
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: MyColors.lightGrey,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                        (controller.socialUser.positionName ?? "")
                            .toUpperCase(),
                        style: MyColors.primaryLight.medium13)
                  ]
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Get.find<AppController>().user.value.userId ==
                          controller.socialUser.id
                      ? Expanded(
                          child: Text(controller.socialUser.name ?? "",
                              style:
                                  MyColors.l111111_dwhite(context).semiBold16),
                        )
                      : Text(controller.socialUser.name ?? "",
                          style: MyColors.l111111_dwhite(context).semiBold16),
                  Obx(() => controller.loadingToggleNotification.value
                      ? CupertinoActivityIndicator()
                      : (controller.appController
                                  .isFollowing(controller.socialUser.id!) &&
                              !controller.appController.user.value.isAdmin)
                          ? Padding(
                              padding: EdgeInsets.only(left: 15.w),
                              child: InkWell(
                                onTap: () {
                                  controller.toggleNotification(
                                      controller.socialUser.id!);
                                },
                                child: Icon(
                                  controller.appController.isNotification(
                                          controller.socialUser.id!)
                                      ? Icons.notifications_on
                                      : Icons.notifications_off,
                                  size: 20,
                                  color: MyColors.primaryDark,
                                ),
                              ),
                            )
                          : Offstage()),
                  if (Get.find<AppController>().user.value.userId !=
                      controller.socialUser.id)
                    SizedBox(width: 15.w),
                  if (Get.find<AppController>().user.value.userId !=
                          controller.socialUser.id &&
                      !controller.appController.user.value.isAdmin)
                    Obx(() => controller.loadingFollow.value &&
                            controller.selectedIndex.value == -1
                        ? CupertinoActivityIndicator()
                        : controller.appController
                                .isFollowing(controller.socialUser.id!)
                            ? Expanded(
                                child: InkWell(
                                    onTap: () {
                                      controller.followUnfollow(
                                          "${controller.socialUser.id}", -1);
                                    },
                                    child: Text(MyStrings.following.tr,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: MyColors.primaryDark,
                                          fontFamily: MyAssets.fontKlavika,
                                          fontWeight: FontWeight.w500,
                                        ))),
                              )
                            : Expanded(
                                child: InkWell(
                                    onTap: () {
                                      controller.followUnfollow(
                                          "${controller.socialUser.id}", -1);
                                    },
                                    child: Text('+ ${MyStrings.follow.tr}',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: MyColors.primaryDark,
                                          fontFamily: MyAssets.fontKlavika,
                                          fontWeight: FontWeight.w500,
                                        ))),
                              )),
                  SizedBox(width: 15.w),
                  InkWell(
                      onTap: () {
                        Share.share(DeepLinkService.generateAppLink(
                            "profile/${controller.socialUser.id ?? ''}"));
                      },
                      child: Icon(
                        Icons.share,
                        size: 20,
                        color: MyColors.primaryLight,
                      )),
                  SizedBox(width: 14.w),
                ],
              ),
              Row(
                children: [
                  Text((controller.socialUser.countryName ?? "").toUpperCase(),
                      style: MyColors.l111111_dwhite(context).regular13),
                  SizedBox(width: 5.w),
                  Text(
                      Utils.getCountryFlag(
                          countryName: controller.socialUser.countryName ??
                              "United Kingdom"),
                      style: TextStyle(fontSize: 20)),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_alt,
                    size: 16,
                    color: MyColors.c_FFA800,
                  ),
                  SizedBox(width: 3.w),
                  InkWell(
                    onTap: () {
                      _showFollowersFollowingBottomSheet(
                          Get.context!,
                          MyStrings.followers.tr,
                          controller.employeeFollowers.value.followers);
                    },
                    child: Text(
                        '${controller.employeeFollowers.value.followers!.length} ${MyStrings.followers.tr}',
                        style: MyColors.l111111_dwhite(context).regular13),
                  ),
                  SizedBox(width: 15.w),
                  const Icon(
                    Icons.people_alt,
                    size: 16,
                    color: MyColors.c_FFA800,
                  ),
                  SizedBox(width: 3.w),
                  InkWell(
                    onTap: () {
                      _showFollowersFollowingBottomSheet(
                          Get.context!,
                          MyStrings.following.tr,
                          controller.employeeFollowers.value.following);
                    },
                    child: Text(
                        '${controller.employeeFollowers.value.following!.length} ${MyStrings.following.tr}',
                        style: MyColors.l111111_dwhite(context).regular13),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

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
                userList.length > 0
                    ? Expanded(
                        child: ListView.builder(
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
                                        .onlyLoadData(SocialUser(
                                      id: userList[index].id,
                                      name: userList[index].name ??
                                          userList[index].restaurantName,
                                      positionName:
                                          userList[index].positionName,
                                      email: userList[index].email,
                                      role: userList[index].role,
                                      profilePicture:
                                          userList[index].profilePicture,
                                      countryName: userList[index].countryName,
                                    ));
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
                                      EmployeeDetailsController>()) {
                                    Get.find<EmployeeDetailsController>()
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
                                  child:
                                      userList[index].profilePicture != null &&
                                              userList[index].profilePicture !=
                                                  "undefined"
                                          ? Image.network(
                                              "https://mh-user-bucket.s3.amazonaws.com/public/users/profile/${userList[index].profilePicture}",
                                              fit: BoxFit.cover,
                                              width: 48,
                                              height: 48,
                                            )
                                          : Image.asset(
                                              MyAssets.employeeDefault,
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
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                  SizedBox(width: 5.w),
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
                                                            color:
                                                                Colors.black)),
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
                                                            color:
                                                                Colors.white)),
                                                  ),
                                                ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Center(child: Text("No followers to show"))),
              ],
            );
          },
        );
      },
    );
  }
}

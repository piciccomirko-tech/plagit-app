import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mh/app/common/data/data.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/default_image_widget.dart';
import 'package:mh/app/common/widgets/profile_picture_widget.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_profile/controllers/client_profile_controller.dart';
import 'package:mh/app/modules/client/employee_details/controllers/employee_details_controller.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

class ClientPremiumHeaderWidget extends GetWidget<ClientProfileController> {
  const ClientPremiumHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 50.0.w),
          padding: EdgeInsets.all(20.0.w),
          decoration: BoxDecoration(
            // gradient: Utils.primaryGradient,
            color: MyColors.lightCard(context),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: MyColors.black,
              width: 0.3,
            ),
          ),
          child: IntrinsicHeight(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(Routes.mySocialFeeds),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(height: 5.w),
                              Image.asset('assets/icons/ic_my_social_post.png',
                                width: 20, height: 20, ),
                              SizedBox(height: 3.w),
                              Text(
                                MyStrings.mySocialPost.tr,
                                style: MyColors.c_9A9A9A.medium16,
                              ),
                              SizedBox(height: 2.w),
                              Obx(
                                    () => controller
                                    .totalSocialPostDataLoaded.value ==
                                    false
                                    ? CupertinoActivityIndicator()
                                    : Text(
                                  "${controller.totalSocialPost.value}",
                                  style: MyColors.l111111_dwhite(context).semiBold20,
                                ),
                              )
                            ]),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      color: MyColors.c_A6A6A6,
                      width: 1,
                      height: 25,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: controller.onJobPostTap,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(height: 5.w),
                              Image.asset('assets/icons/ic_my_job_post.png',
                                width: 20, height: 20, ),
                              SizedBox(height: 3.w),
                              Text(
                                MyStrings.myJobPosts.tr,
                                style: MyColors.c_9A9A9A.medium16,
                              ),
                              SizedBox(height: 2.w),
                              Text(
                                "${(Get.find<ClientHomePremiumController>().grossTotalMyJobPosts)}",
                                style: MyColors.l111111_dwhite(context).semiBold20,
                              )
                            ]),
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  color: MyColors.c_A6A6A6,
                  height: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          controller.followersLoading.value == true?null:_showFollowersFollowingBottomSheet(
                            context,
                            MyStrings.followers.tr,
                            controller.employeeFollowers.value.followers,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/icons/ic_followers.png',
                                width: 20, height: 20,color: Get.isDarkMode?MyColors.white:Colors.black),
                            SizedBox(height: 3.w),
                            Text(MyStrings.followers.tr, style: MyColors.c_9A9A9A.medium16),
                            SizedBox(height: 2.w),
                            Obx(
                              () => controller.followersLoading.value == true
                                  ? CupertinoActivityIndicator()
                                  : Text(
                                      controller.employeeFollowers.value
                                              .followers?.length
                                              .toString() ??
                                          '',
                                      style: MyColors.l111111_dwhite(context).semiBold20,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      color: MyColors.c_A6A6A6,
                      width: 1,
                      height: 25,
                    ),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          controller.followersLoading.value == true?null:_showFollowersFollowingBottomSheet(
                            context,
                            MyStrings.following.tr,
                            controller.employeeFollowers.value.following,
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.asset('assets/icons/ic_following.png',
                                width: 20, height: 20,color: Get.isDarkMode?MyColors.white:Colors.black,),
                            SizedBox(height: 3.w),
                            Text(MyStrings.following.tr, style: MyColors.c_9A9A9A.medium16),
                            SizedBox(height: 2.w),
                            Obx(
                              () => controller.followersLoading.value == true
                                  ? CupertinoActivityIndicator()
                                  : Text(
                                      controller.employeeFollowers.value
                                              .following?.length
                                              .toString() ??
                                          '',
                                      style: MyColors.l111111_dwhite(context).semiBold20,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Obx(()=>(Get.find<ClientHomePremiumController>()
                .client
                .value
                .details
                ?.profilePicture ??
                "")
                .isEmpty
                ? const DefaultImageWidget(
              defaultImagePath: MyAssets.clientDefault,
              radius: 70,
            )
                : ProfilePictureWidget(
              height: 80,
              viewOnly: true,
              profilePictureUrl: (Get.find<ClientHomePremiumController>()
                  .client
                  .value
                  .details
                  ?.profilePicture ??
                  "")
                  .imageUrl,
            )),
          ),
        ),
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
                // List
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: userList.length, // Example: 20 users
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Get.back();
                          if (userList[index].role?.toLowerCase() == "client") {
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
                                    positionName: userList[index].positionName,
                                    email: userList[index].email,
                                    role: userList[index].role,
                                    profilePicture:
                                        userList[index].profilePicture,
                                    countryName: userList[index].countryName,
                                  ));
                            }
                          } else {
                            if (Get.isRegistered<EmployeeDetailsController>()) {
                              Get.find<EmployeeDetailsController>()
                                  .onlyLoadData(
                                      {'employeeId': userList[index].id ?? ""});
                            } else {
                              Get.toNamed(Routes.employeeDetails, arguments: {
                                'employeeId': userList[index].id ?? ""
                              });
                            }
                          }
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.transparent,
                          child: ClipOval(
                            child: userList[index].profilePicture != null &&
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
                                        : userList[index].role.toUpperCase() ==
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
                                style:
                                    MyColors.l111111_dwhite(context).regular11,
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
                                style:
                                    MyColors.l111111_dwhite(context).regular11,
                              ),
                            ),
                          ],
                        ), // Replace with user status
                        trailing: Obx(
                          () => controller.loadingFollow.value &&
                                  controller.selectedIndex.value == index
                              ? CupertinoActivityIndicator()
                              : controller.appController
                                      .isFollowing(userList[index].id)
                                  ? InkWell(
                                      onTap: () {
                                        controller.followUnfollow(
                                            userList[index].id, index);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                            border: Border.all(
                                                color: MyColors.primaryLight,
                                                width: 1.5)),
                                        padding: EdgeInsets.all(8),
                                        child: Text(MyStrings.following.tr,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black)),
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () {
                                        controller.followUnfollow(
                                            userList[index].id, index);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: MyColors.primaryLight,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5),
                                            bottomRight: Radius.circular(5),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Text(MyStrings.follow.tr,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white)),
                                      ),
                                    ),
                        ),
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

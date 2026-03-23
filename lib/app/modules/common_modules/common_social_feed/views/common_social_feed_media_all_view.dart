import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_appbar_back_button.dart';
import '../../../../common/widgets/custom_image_widget.dart';
import '../../../../common/widgets/custom_video_widget.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../models/user.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/common_social_feed_controller.dart';
import 'common_social_feed_post_details_view_by_post_id.dart';

class CommonSocialFeedPostMediaAllView
    extends GetView<CommonSocialFeedController> {
  const CommonSocialFeedPostMediaAllView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Change this to your desired color
        statusBarIconBrightness:
            Brightness.light, // Change icons to light or dark
      ));
    });

    final CarouselSliderController carouselSliderController =
        CarouselSliderController();
    final isRepost = controller.socialPostInfo.value.repost != null &&
            controller.socialPostInfo.value.repost?.active != false
        ? true
        : false;

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onTap: controller.toggleCaptionVisibility,
              onVerticalDragStart: controller.onVerticalDragStart,
              onVerticalDragUpdate: controller.onVerticalDragUpdate,
              onVerticalDragEnd: controller.onVerticalDragEnd,
              child: SizedBox(
                height: Get.height,
                width: Get.width,
                child: Center(
                  child: CarouselSlider.builder(
                    carouselController: carouselSliderController,
                    itemCount: isRepost
                        ? controller.socialPostInfo.value.repost!.media!.length
                        : controller.socialPostInfo.value.media!.length,
                    itemBuilder: (context, index, realIndex) {
                      Media media = isRepost
                          ? controller
                              .socialPostInfo.value.repost!.media![index]
                          : controller.socialPostInfo.value.media![index];
                      Widget mediaWidget;
                      if (media.type == "image") {
                        mediaWidget = PinchZoom(
                          maxScale: 2.5,
                          child: CustomImageWidget(
                            imgUrl: (media.url ?? "").socialMediaUrl,
                            fit: BoxFit.fitWidth,
                            height: media.scaledHeight,
                            width: Get.width,
                          ),
                        );
                      } else if (media.type == "video") {
                        mediaWidget = CustomVideoWidget(
                          media: media,
                          radius: 0,
                        );
                      } else {
                        mediaWidget = Container();
                      }

                      return Container(
                        width: Get.width,
                        alignment: Alignment.center,
                        child: mediaWidget,
                      );
                    },
                    options: CarouselOptions(
                      initialPage: controller.currentSliderIndex.value,
                      height: Get.height,
                      //     160, // Account for AppBar and indicator
                      enableInfiniteScroll: isRepost
                          ? controller
                                  .socialPostInfo.value.repost!.media!.length >
                              1
                          : controller.socialPostInfo.value.media!.length > 1,
                      autoPlay: false,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      onPageChanged:
                          (int index, CarouselPageChangedReason reason) {
                        controller.currentSliderIndex.value = index;
                      },
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: controller.isCaptionVisible.value ? 1.0 : 0.0,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 16.w + Get.mediaQuery.padding.top,
                ),
                child: isRepost
                    ? _buildRePostPublishersDetails(context,
                        controller.socialPostInfo.value.repost!, controller)
                    : _buildPostPublishersDetails(
                        context, controller.socialPostInfo.value, controller),
              ),
            ),
            Positioned(
              bottom: 60.h,
              left: 16.w,
              right: 16.w,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: controller.isCaptionVisible.value ? 1.0 : 0.0,
                child: Container(
                  height: Get.height * .35,
                  alignment: Alignment.bottomCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (!isRepost &&
                            (controller.socialPostInfo.value.content ?? "")
                                .isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SocialCaptionWidget(
                              text:
                                  controller.socialPostInfo.value.content ?? "",
                              textColor: MyColors.c_FFFFFF,
                            ),
                          ),
                        if (isRepost &&
                            (controller.socialPostInfo.value.repost?.content ??
                                    "")
                                .isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SocialCaptionWidget(
                              text: controller
                                      .socialPostInfo.value.repost?.content ??
                                  "",
                              textColor: MyColors.c_FFFFFF,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            ///
            Positioned(
              bottom: 20.h,
              left: 16.w,
              right: 16.w,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: controller.isCaptionVisible.value ? 1.0 : 0.0,
                child: _buildInteraction(
                    context,
                    controller.socialPostInfo.value,
                    controller.appController.user.value,
                    () => controller.reactPost(
                          postId: controller.socialPostInfo.value.id.toString(),
                          index: controller.selectedIndex.value,
                        ),
                    () => controller.savePost(
                        controller.socialPostInfo.value.id.toString()),
                    () => controller.deleteSavePost(savedPostList
                            .firstWhere(
                                (post) =>
                                    post.post?.id ==
                                    controller.socialPostInfo.value.id
                                        .toString(),
                                orElse: () => SavedPostModel())
                            .id ??
                        ""),
                    controller,
                    controller.isPostSaved(
                        controller.socialPostInfo.value.id.toString()),
                    controller.selectedIndex.value),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildPostPublishersDetails(BuildContext context,
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CustomAppbarBackButton(onPressed: () => Get.back()),
      Row(
        children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: MyColors.noColor,
              backgroundImage: ((socialPost.user?.profilePicture ?? "")
                          .isEmpty ||
                      socialPost.user?.profilePicture == "undefined")
                  ? AssetImage(socialPost.user?.role?.toUpperCase() == "ADMIN"
                      ? MyAssets.adminDefault
                      : socialPost.user?.role?.toUpperCase() == "CLIENT"
                          ? MyAssets.clientDefault
                          : MyAssets.employeeDefault)
                  : CachedNetworkImageProvider((socialPost
                                      .user?.profilePicture ??
                                  "")
                              .toString() ==
                          ""
                      ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                      : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${socialPost.user?.profilePicture}")),
          SizedBox(width: 10.w),
          Text(
            socialPost.user?.name != null && socialPost.user!.name!.length > 17
                ? Utils.truncateCharacters(socialPost.user!.name ?? '', 17)
                : socialPost.user?.name ?? '',
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.c_FFFFFF),
          ),
        ],
      ),
      InkWell(
          onTap: () => controller.showDownloadBottomSheet(
              context, socialPost.media ?? []),
          child: Icon(Icons.more_vert, size: 24.r, color: MyColors.c_FFFFFF)),
    ],
  );
}

Widget _buildRePostPublishersDetails(BuildContext context, Repost socialPost,
    CommonSocialFeedController controller) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      CustomAppbarBackButton(onPressed: () => Get.back()),
      Row(
        children: [
          CircleAvatar(
              radius: 14,
              backgroundColor: MyColors.noColor,
              backgroundImage: ((socialPost.user?.profilePicture ?? "")
                          .isEmpty ||
                      socialPost.user?.profilePicture == "undefined")
                  ? AssetImage(socialPost.user?.role?.toUpperCase() == "ADMIN"
                      ? MyAssets.adminDefault
                      : socialPost.user?.role?.toUpperCase() == "CLIENT"
                          ? MyAssets.clientDefault
                          : MyAssets.employeeDefault)
                  : CachedNetworkImageProvider((socialPost
                                      .user?.profilePicture ??
                                  "")
                              .toString() ==
                          ""
                      ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                      : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${socialPost.user?.profilePicture}")),
          SizedBox(width: 10.w),
          Text(
            socialPost.user?.name != null && socialPost.user!.name!.length > 17
                ? Utils.truncateCharacters(socialPost.user!.name ?? '', 17)
                : socialPost.user?.name ?? '',
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MyColors.c_FFFFFF),
          ),
        ],
      ),
      // _buildPostMenuButtons(context, socialPost.media ?? [], controller),
      InkWell(
          onTap: () => controller.showDownloadBottomSheet(
              context, socialPost.media ?? []),
          child: Icon(Icons.more_vert, size: 24.r, color: MyColors.c_FFFFFF)),
    ],
  );
}

PopupMenuButton<int> _buildPostMenuButtons(BuildContext context,
    List<Media> mediaList, CommonSocialFeedController controller) {
  return PopupMenuButton<int>(
    color: MyColors.lightCard(context),
    icon: Icon(Icons.more_vert, size: 24.r, color: MyColors.c_FFFFFF),
    onSelected: (int result) async {
      if (result == 0) {
        controller.downloadCurrentMedia(mediaList);
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
      PopupMenuItem<int>(
        value: 0,
        child: Text(
          "Download",
          style: TextStyle(
              fontFamily: MyAssets.fontMontserrat,
              fontSize: 13,
              color: MyColors.l111111_dwhite(context)),
        ),
      ),
    ],
  );
}

Widget _buildInteraction(
    BuildContext context,
    SocialPostModel socialPost,
    User appUser,
    Function() react,
    Function() savePost,
    Function() deleteSavePost,
    CommonSocialFeedController controller,
    bool isSave,
    index) {
  return Obx(() => Row(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  appUser.isAdmin ? null : react();
                },
                onLongPress: () {
                  controller.getSocialPostInfoByPostId(context, socialPost.id);
                },
                child: controller.selectedIndex.value == index &&
                        controller.isReacting.value
                    ? CupertinoActivityIndicator()
                    : Icon(
                        (socialPost.likes ?? [])
                                .any((SocialUser a) => a.id == appUser.userId)
                            ? CupertinoIcons.hand_thumbsup_fill
                            : CupertinoIcons.hand_thumbsup_fill,
                        size: 25.w,
                        color: (socialPost.likes ?? [])
                                .any((SocialUser a) => a.id == appUser.userId)
                            ? MyColors.primaryLight
                            : MyColors.c_FFFFFF),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {
                  controller.getSocialPostInfoByPostId(context, socialPost.id);
                },
                child: Text(
                  "${socialPost.likes?.length}",
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 14,
                    color: MyColors.c_FFFFFF,
                  ),
                ),
              )
            ],
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {
              controller.showCommentBottomSheet(
                  context, "Comments", controller);
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.chat_bubble,
                    size: 24.w, color: MyColors.c_FFFFFF),
                SizedBox(width: 10.w),
                controller.selectedIndex.value == index &&
                        controller.isCommentLoading.value
                    ? Text(
                        socialPost.comments!.isEmpty
                            ? "0"
                            : "${getTotalCommentCount(comments: socialPost.comments!)}",
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 14,
                          color: MyColors.c_FFFFFF,
                        ),
                      )
                    : Text(
                        socialPost.comments!.isEmpty
                            ? "0"
                            : "${getTotalCommentCount(comments: socialPost.comments!)}",
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 14,
                          color: MyColors.c_FFFFFF,
                        ),
                      )
              ],
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (appUser.isAdmin) return;
              if (isSave) {
                deleteSavePost();
              } else {
                savePost();
              }
            },
            child: Row(
              children: [
                Icon(
                    isSave
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    size: 24.w,
                    color: isSave ? MyColors.primaryLight : MyColors.c_FFFFFF),
                // Text(
                //   "  ${MyStrings.save.tr}",
                //   style: TextStyle(
                //     fontFamily: MyAssets.fontMontserrat,
                //     fontSize: 12,
                //     color: MyColors.dividerColor,
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          if (socialPost.repost == null)
            // if (repost != null && socialPost.repost == null)
            GestureDetector(
              onTap: () {
                appUser.isAdmin
                    ? null
                    : _showRepost(
                        postId: socialPost.id ?? '',
                        context: context,
                        controller: controller);
              },
              child: Row(
                children: [
                  Icon(CupertinoIcons.repeat,
                      size: 24.w, color: MyColors.c_FFFFFF),
                  // Text(
                  //   "  ${MyStrings.repost.tr}",
                  //   style: TextStyle(
                  //     fontFamily: MyAssets.fontMontserrat,
                  //     fontSize: 12,
                  //     color: MyColors.dividerColor,
                  //   ),
                  // ),
                ],
              ),
            ),
        ],
      ));
}

void _showRepost(
    {required BuildContext context,
    required CommonSocialFeedController controller,
    required String postId}) {
  Get.bottomSheet(Container(
    height: Get.width * 0.7,
    padding: const EdgeInsets.all(15.0),
    decoration: BoxDecoration(
        color: MyColors.lightCard(context),
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: Get.back,
                child: Icon(
                  Icons.close,
                  color: MyColors.l111111_dwhite(context),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  controller.repostToMySocialFeed(
                    postId: postId,
                    context: context,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(33.0),
                      gradient: Utils.primaryGradient),
                  child: Text(
                    MyStrings.post.tr,
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 13,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 30.w),
          TextField(
            minLines: 5,
            maxLines: null,
            controller: controller.repostEditTextController,
            style: MyColors.l111111_dwhite(context).medium13,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(15.0.w),
                filled: true,
                hintText: MyStrings.writeYourThoughts.tr,
                hintStyle: MyColors.lightGrey.medium13,
                fillColor: MyColors.noColor,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: MyColors.lightGrey))),
          ),
        ],
      ),
    ),
  ));
}

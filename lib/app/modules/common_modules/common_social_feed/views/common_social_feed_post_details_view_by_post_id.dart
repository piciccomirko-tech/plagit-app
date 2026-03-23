import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';

import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_image_widget.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../common/widgets/custom_video_widget.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/common_social_feed_controller.dart';

class CommonSocialFeedPostDetailsViewByPostId
    extends GetView<CommonSocialFeedController> {
  const CommonSocialFeedPostDetailsViewByPostId({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
          radius: 0.0, title: MyStrings.socialPostDetails.tr, context: context),
      body: Obx(
        () => controller.socialPostInfoDataLoading.value == true
            ? Center(child: CustomLoader.loading())
            : controller.noDataFound.value == true
                ? Center(child: NoItemFound())
                : Container(
                    margin: EdgeInsets.only(top: 5.w),
                    padding: EdgeInsets.only(top: 15.0.w, bottom: 15.0.w),
                    decoration: BoxDecoration(
                      color: MyColors.lightCard(context),
                      border: Border.all(color: MyColors.noColor, width: 0.5),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                          child: Row(
                            children: [
                              _buildPostPublishersDetails(
                                  context, controller.socialPostInfo.value),
                              Spacer(),
                              _buildPostMenuButtons(
                                  context,
                                  controller.socialPostInfo.value,
                                  controller.appController.user.value.userId),
                            ],
                          ),
                        ),
                        if ((controller.socialPostInfo.value.content ?? "")
                            .isNotEmpty) ...[
                          SizedBox(height: 8.w),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                            child: SocialCaptionWidget(
                                text: controller.socialPostInfo.value.content ??
                                    ""),
                          ),
                        ],
                        SizedBox(
                            height:
                                controller.socialPostInfo.value.repost != null
                                    ? 5.w
                                    : 20.w),
                        if (controller.socialPostInfo.value.repost != null)
                          Padding(
                            padding:
                                EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                            child: _repostWidget(
                                context,
                                controller.socialPostInfo.value.repost!,
                                controller.socialPostInfo.value,
                                controller),
                          ),
                        if ((controller.socialPostInfo.value.media ?? [])
                                .length ==
                            1)
                          (controller.socialPostInfo.value.media ?? [])
                                      .first
                                      .type ==
                                  'image'
                              ? _buildSingleImage(
                                  controller.socialPostInfo.value, controller)
                              : _buildSingleVideo(
                                  controller.socialPostInfo.value)
                        else if ((controller.socialPostInfo.value.media ?? [])
                            .isEmpty)
                          const Wrap()
                        else
                          SizedBox(
                            height:
                                (controller.socialPostInfo.value.media ?? [])
                                            .length >=
                                        3
                                    ? Get.width * 0.95
                                    : 200.w,
                            child: (controller.socialPostInfo.value.media ?? [])
                                        .length ==
                                    3
                                ? _buildOnlyThreeItems(
                                    (controller.socialPostInfo.value.media ??
                                            [])
                                        .take(4)
                                        .toList(),
                                    controller.socialPostInfo.value,
                                    controller)
                                : _buildMoreThanThreeView(
                                    (controller.socialPostInfo.value.media ??
                                            [])
                                        .take(4)
                                        .toList(),
                                    (controller.socialPostInfo.value.media ??
                                            [])
                                        .length,
                                    controller.socialPostInfo.value,
                                    controller),
                          ),
                        _buildInteractionCount(
                            context,
                            controller.socialPostInfo.value,
                            controller.appController.user.value.userId,
                            controller),
                        _buildInteraction(
                            context,
                            controller.socialPostInfo.value,
                            controller.appController.user.value.userId,
                            () => controller.reactPost(
                                postId: controller.socialPostInfo.value.id
                                    .toString(),
                                index: controller.selectedIndex.value),
                            () => controller
                                .commentToggle(controller.selectedIndex.value),
                            controller,
                            controller.selectedIndex.value),
                        Obx(
                          () => controller.selectedIndex.value ==
                                      controller.selectedIndex.value &&
                                  controller.showComment.value
                              ? _buildShowComment(context)
                              : SizedBox(),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

Widget _buildPostPublishersDetails(
    BuildContext context, SocialPostModel socialPost) {
  return GestureDetector(
    onTap: () => socialPost.user?.role?.toLowerCase() == "client"
        ? Get.toNamed(Routes.individualSocialFeeds, arguments: socialPost.user)
        : Get.toNamed(Routes.employeeDetails,
            arguments: {'employeeId': socialPost.user?.id ?? ""}),
    child: Row(
      children: [
        CircleAvatar(
            radius: 18,
            backgroundColor: MyColors.noColor,
            backgroundImage: ((socialPost.user?.profilePicture ?? "").isEmpty ||
                    socialPost.user?.profilePicture == "undefined")
                ? AssetImage(socialPost.user?.role?.toUpperCase() == "ADMIN"
                    ? MyAssets.adminDefault
                    : socialPost.user?.role?.toUpperCase() == "CLIENT"
                        ? MyAssets.clientDefault
                        : MyAssets.employeeDefault)
                : CachedNetworkImageProvider((socialPost.user?.profilePicture ??
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
              fontFamily: 'Klavika',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: MyColors.l111111_dwhite(context)),
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 1.5,
          backgroundColor: MyColors.l111111_dwhite(context),
        ),
        SizedBox(width: 10.w),
        socialPost.active != null && socialPost.active!
            ? Text(
                Utils.formatDateTime(
                  socialFeed: true,
                  socialPost.createdAt ?? DateTime.now(),
                ),
                style: TextStyle(
                    fontFamily: 'Klavika',
                    fontSize: 11,
                    color: MyColors.lightGrey),
              )
            : Text(
                "HOLD",
                style: TextStyle(
                    fontFamily: 'Klavika',
                    fontSize: 11,
                    color: MyColors.lightGrey),
              ),
      ],
    ),
  );
}

PopupMenuButton<int> _buildPostMenuButtons(
    BuildContext context, SocialPostModel socialPost, String appUserId) {
  return PopupMenuButton<int>(
    color: MyColors.lightCard(context),
    icon: Image.asset(MyAssets.socialMenu, height: 4, color: MyColors.c_9A9A9A),
    onSelected: (int result) async {
      // Handle the selected menu item
      if (result == 0) {
        Get.toNamed(Routes.createPost, arguments: [socialPost, 'edit']);
      } else if (result == 1) {
        // isActive = !isActive;
        // await widget.inActivePost!(
        //     postId: widget.socialPost.id ?? "", active: isActive);
      } else if (result == 2) {
        // await widget.deletePost!(postId: widget.socialPost.id ?? "");
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
      if (socialPost.user?.id == appUserId)
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            MyStrings.edit.tr,
            style: TextStyle(
                fontFamily: 'Klavika',
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id == appUserId)
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            socialPost.active != null && socialPost.active!
                ? MyStrings.inactive.tr
                : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: 'Klavika',
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id == appUserId)
        PopupMenuItem<int>(
          value: 2,
          child: Text(
            MyStrings.delete.tr,
            style: TextStyle(
                fontFamily: 'Klavika',
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id != appUserId)
        PopupMenuItem<int>(
          value: 3,
          child: Text(
            MyStrings.follow.tr,
            style: TextStyle(
                fontFamily: 'Klavika',
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id != appUserId)
        PopupMenuItem<int>(
          value: 4,
          child: Text(
            'Block',
            // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: 'Klavika',
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
    ],
  );
}

Widget _repostWidget(BuildContext context, Repost repost,
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  int mediaCount = (repost.media ?? []).length;
  List<Media> visibleMedia = (repost.media ?? []).take(4).toList();

  return repost.active == false
      ? Center(child: Text('Post not available'))
      : GestureDetector(
          onTap: () =>
              Get.toNamed(Routes.socialPostDetails, arguments: repost.id),
          child: Container(
            margin: EdgeInsets.only(top: 15.0.h),
            padding: const EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
              color: MyColors.lightCard(context),
              border: Border.all(color: MyColors.lightGrey, width: 0.3),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      _buildRepostUser(repost),
                      SizedBox(width: 10.w),
                      Text(
                        repost.user?.name != null &&
                                repost.user!.name!.length > 17
                            ? '${Utils.truncateCharacters(repost.user!.name ?? '', 17)}'
                            : repost.user?.name ?? '',
                        maxLines: null,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 13,
                          color: MyColors.l111111_dwhite(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((repost.content ?? "").isNotEmpty) ...[
                  SizedBox(height: 15.w),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: SocialCaptionWidget(text: repost.content ?? ""),
                  ),
                  // Text("Content  found"),
                ],
                // if ((repost.content ?? "").isEmpty && (repost.media ?? []).length == 0) ...[
                //   SizedBox(height: 15.w),
                //   // SocialCaptionWidget(text: repost.content ?? ""),
                //   Text("The Content you are looking for is not found"),
                // ],
                SizedBox(height: 15.w),
                if ((repost.media ?? []).length == 1)
                  (repost.media ?? []).first.type == 'image'
                      ? GestureDetector(
                        onTap: () =>
                            controller.seeMediaDetails(socialPost, 0),
                        // onTap: () => Get.to(() => MediaViewAllWidget(
                        //     index: 0, mediaList: repost.media ?? [])),
                        child: CustomImageWidget(
                          imgUrl: ((repost.media ?? []).first.url ?? "")
                              .socialMediaUrl,
                          radius: 10.0,
                          width: Get.width,
                          height: (repost.media ?? []).first.scaledHeight,
                          fit: BoxFit.cover,
                        ),
                      )
                      : CustomVideoWidget(
                        media: (repost.media ?? []).first,
                        radius: 10,
                      )
                else if ((repost.media ?? []).isEmpty)
                  const Wrap()
                else
                  SizedBox(
                    height: mediaCount >= 3 ? Get.width * 0.95 : 200.w,
                    child: mediaCount == 3
                        ? _buildRepostItemsThree(
                            repost, visibleMedia, socialPost, controller)
                        : _buildRepostItemsMoreThanThree(visibleMedia,
                            mediaCount, repost, socialPost, controller),
                  ),
              ],
            ),
          ),
        );
}

GestureDetector _buildRepostUser(Repost repost) {
  return GestureDetector(
    onTap: () => repost.user?.role?.toLowerCase() == "client"
        ? Get.toNamed(Routes.individualSocialFeeds, arguments: repost.user)
        : Get.toNamed(Routes.employeeDetails,
            arguments: {'employeeId': repost.user?.id ?? ""}),
    child: CircleAvatar(
        radius: 15,
        backgroundColor: MyColors.noColor,
        backgroundImage: ((repost.user?.profilePicture ?? "").isEmpty ||
                repost.user?.profilePicture == "undefined")
            ? AssetImage(repost.user?.role?.toUpperCase() == "CLIENT"
                ? MyAssets.clientDefault
                : MyAssets.employeeDefault)
            : NetworkImage((repost.user?.profilePicture ?? "").socialMediaUrl)),
  );
}

Widget _buildRepostItemsThree(Repost repost, List<Media> visibleMedia,
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  return SingleChildScrollView(
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 0),
          // onTap: () => Get.to(
          //   () => MediaViewAllWidget(
          //     index: 0,
          //     mediaList: (repost.media ?? []),
          //   ),
          // ),
          child: _buildMediaWidget(
            post: visibleMedia[0],
            height: Get.width * 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 1),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 1,
                //     mediaList: (repost.media ?? []),
                //   ),
                // ),
                child: _buildMediaWidget(
                  post: visibleMedia[1],
                  height: Get.width * 0.35,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 2),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 2,
                //     mediaList: (repost.media ?? []),
                //   ),
                // ),
                child: _buildMediaWidget(
                  post: visibleMedia[2],
                  height: Get.width * 0.35,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildRepostItemsMoreThanThree(
    List<Media> visibleMedia,
    int mediaCount,
    Repost repost,
    SocialPostModel socialPost,
    CommonSocialFeedController controller) {
  return GridView.count(
    crossAxisCount: 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    children: visibleMedia.asMap().entries.map((entry) {
      int index = entry.key;
      Media post = entry.value;

      // Handle the last item if there are more than 4 media items
      if (index == 3 && mediaCount > 4) {
        return Stack(
          children: [
            _buildMediaWidget(
              post: post,
              height: Get.width * 0.5,
            ),
            // Overlay the count of additional items on the 4th media
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 0),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 0,
                //     mediaList: (repost.media ?? []),
                //   ),
                // ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Text(
                      '+${mediaCount - 4}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Regular media items (image or video)
      return GestureDetector(
        onTap: () => controller.seeMediaDetails(socialPost, index),
        // onTap: () => Get.to(
        //   () => MediaViewAllWidget(
        //     index: 0,
        //     mediaList: (repost.media ?? []),
        //   ),
        // ),
        child: _buildMediaWidget(
          post: post,
          height: Get.width * 0.5,
        ),
      );
    }).toList(),
  );
}

//Helper function to build media widget (image or video)
Widget _buildMediaWidget({
  required Media post,
  double? height,
}) {
  if (post.type == 'image') {
    return CustomImageWidget(
      imgUrl: (post.url ?? "").socialMediaUrl,
      height: height, // Adjusted height for flexibility
      radius: 1.0,
      width: Get.width,
      fit: BoxFit.cover,
    );
  } else if (post.type == 'video') {
    return CustomVideoWidget(
      media: post,
      height: height,
      radius: 1,
    );
  }
  return Container(); // Fallback in case of unknown media type
}

Widget _buildSingleVideo(SocialPostModel socialPost) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15.w),
    child: CustomVideoWidget(
      radius: 1,
      media: (socialPost.media ?? []).first,
    ),
  );
}

Widget _buildSingleImage(
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15.w),
    child: GestureDetector(
      onTap: () => controller.seeMediaDetails(socialPost, 0),
      // onTap: () => Get.to(() =>
      //     MediaViewAllWidget(index: 0, mediaList: socialPost.media ?? [])),
      child: CustomImageWidget(
          imgUrl: ((socialPost.media ?? []).first.url ?? "").socialMediaUrl,
          radius: 1.0,
          width: Get.width,
          height: (socialPost.media ?? []).first.scaledHeight,
          fit: BoxFit.cover),
    ),
  );
}

Widget _buildMoreThanThreeView(List<Media> visibleMedia, int mediaCount,
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  return GridView.count(
    crossAxisCount: 2,
    mainAxisSpacing: 2,
    crossAxisSpacing: 2,
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    children: visibleMedia.asMap().entries.map((entry) {
      int index = entry.key;
      Media post = entry.value;

      // Handle the last item if there are more than 4 media items
      if (index == 3 && mediaCount > 4) {
        return Stack(
          children: [
            _buildMediaWidget(
              post: post,
              height: Get.height,
            ),
            // Overlay the count of additional items on the 4th media
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 3),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 0,
                //     mediaList: (socialPost.media ?? []),
                //   ),
                // ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(1.0)),
                  child: Center(
                    child: Text(
                      '+${mediaCount - 4}',
                      style: TextStyle(
                        fontFamily: MyAssets.fontMontserrat,
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // Regular media items (image or video)
      return GestureDetector(
        onTap: () => controller.seeMediaDetails(socialPost, index),
        // onTap: () => Get.to(() =>
        //     MediaViewAllWidget(index: 0, mediaList: (socialPost.media ?? []))),
        child: _buildMediaWidget(post: post, height: Get.height),
      );
    }).toList(),
  );
}

Widget _buildOnlyThreeItems(List<Media> visibleMedia,
    SocialPostModel socialPost, CommonSocialFeedController controller) {
  return SingleChildScrollView(
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 0),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 0, mediaList: (socialPost.media ?? []))),
          child:
              _buildMediaWidget(post: visibleMedia[0], height: Get.width * 0.5),
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 1),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 1,
                //     mediaList: (socialPost.media ?? []),
                //   ),
                // ),
                child: _buildMediaWidget(
                    post: visibleMedia[1], height: Get.width * 0.35),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 2),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 2,
                //     mediaList: (socialPost.media ?? []),
                //   ),
                // ),
                child: _buildMediaWidget(
                  post: visibleMedia[2],
                  height: Get.width * 0.35,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildInteractionCount(BuildContext context, SocialPostModel socialPost,
    String appUserId, CommonSocialFeedController controller) {
  return Padding(
    padding: EdgeInsets.all(15.0.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        socialPost.likes!.isEmpty
            ? SizedBox.shrink()
            : socialPost.likes!.length == 1
                ? InkWell(
                    onTap: () {
                      controller.getSocialPostInfoByPostId(
                          context, socialPost.id);
                    },
                    child: Text(
                      (socialPost.likes ?? [])
                              .any((SocialUser a) => a.id == appUserId)
                          ? "You liked this"
                          : "${Utils.truncateCharacters(socialPost.likes![0].name ?? '', 20)} liked this",
                      style: TextStyle(
                        fontFamily: MyAssets.fontMontserrat,
                        fontSize: 12,
                        color: MyColors.dividerColor,
                      ),
                    ),
                  )
                : InkWell(
                    onTap: () {
                      controller.getSocialPostInfoByPostId(
                          context, socialPost.id);
                      // Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(SocialPostDetailsControllerTemporaryToReloadReactions()).context=context;
                      // Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(SocialPostDetailsControllerTemporaryToReloadReactions())
                      //     .getSocialPostInfoByPostId(widget.socialPost.id);
                    },
                    child: Text(
                      (socialPost.likes ?? [])
                              .any((SocialUser a) => a.id == appUserId)
                          ? "You +${socialPost.likes!.length - 1} likes"
                          : "${Utils.truncateCharacters(socialPost.likes![0].name ?? '', 20)} +${socialPost.likes!.length - 1} likes",
                      style: TextStyle(
                        fontFamily: MyAssets.fontMontserrat,
                        fontSize: 12,
                        color: MyColors.dividerColor,
                      ),
                    ),
                  ),
        getTotalCommentCount(comments: socialPost.comments ?? []) == 0
            ? SizedBox.shrink()
            : Text(
                "${getTotalCommentCount(comments: socialPost.comments ?? [])} comments",
                style: TextStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontSize: 12,
                  color: MyColors.dividerColor,
                ),
              ),
        Text(
          "${socialPost.views ?? 0} views",
          style: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 12,
            color: MyColors.dividerColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInteraction(
    BuildContext context,
    SocialPostModel socialPost,
    String appUserId,
    Function() react,
    Function() commentToggle,
    CommonSocialFeedController controller,
    index) {
  return Obx(() => Padding(
        padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
        child: Row(
          mainAxisAlignment: (socialPost.repost != null)
              ? MainAxisAlignment.spaceAround
              : MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                react();
              },
              child: Row(
                children: [
                  controller.selectedIndex.value == index &&
                          controller.isReacting.value
                      ? CupertinoActivityIndicator()
                      : Icon(
                          (socialPost.likes ?? [])
                                  .any((SocialUser a) => a.id == appUserId)
                              ? CupertinoIcons.hand_thumbsup_fill
                              : CupertinoIcons.hand_thumbsup_fill,
                          size: 25.w,
                          color: (socialPost.likes ?? [])
                                  .any((SocialUser a) => a.id == appUserId)
                              ? MyColors.primaryLight
                              : MyColors.dividerColor),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                commentToggle();
              },
              child: Row(
                children: [
                  Icon(CupertinoIcons.chat_bubble,
                      size: 24.w, color: MyColors.dividerColor),
                  SizedBox(width: 10.w),
                  Text(
                    "${getTotalCommentCount(comments: socialPost.comments!)}",
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 14,
                      color: MyColors.dividerColor,
                    ),
                  )
                ],
              ),
            ),
            if (socialPost.repost == null)
              // if (repost != null && socialPost.repost == null)
              GestureDetector(
                onTap: () {
                  // _showRepost(context: context);
                },
                child: Row(
                  children: [
                    Icon(CupertinoIcons.repeat,
                        size: 24.w, color: MyColors.dividerColor),
                    Text(
                      "  ${MyStrings.repost.tr}",
                      style: TextStyle(
                        fontFamily: MyAssets.fontMontserrat,
                        fontSize: 12,
                        color: MyColors.dividerColor,
                      ),
                    ),
                  ],
                ),
              ),
            GestureDetector(
              onTap: () {
                // _showReport(context: context)
              },
              child: Row(
                children: [
                  Icon(Icons.report_gmailerrorred,
                      size: 24.w, color: MyColors.dividerColor),
                  Text(
                    "  ${MyStrings.report.tr}",
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 12,
                      color: MyColors.dividerColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
}

Widget thumbImageWidget({required String url, double? height}) {
  return Container(
    height: height,
    width: Get.width,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      // borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
      image: DecorationImage(
        image: CachedNetworkImageProvider(url),
        fit: BoxFit.cover,
      ),
    ),
    child: Center(
      child: Icon(
        CupertinoIcons.play_circle_fill,
        size: 64,
        color: Colors.white70,
      ),
    ),
  );
}

int getTotalCommentCount({required List<Comment> comments}) {
  int totalCount = 0;

  if (comments.isNotEmpty) {
    for (Comment comment in comments) {
      totalCount++; // Count the main comment
      totalCount += getTotalCommentCount(
          comments:
              comment.children ?? []); // Count the child comments recursively
    }
  }

  return totalCount;
}

Widget _buildShowComment(BuildContext context) {
  return Padding(
    padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
    child: Column(
      children: [
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('comment show korbe 2')
            // Expanded(
            //   flex: 10,
            //   child: SizedBox(
            //     height: 40,
            //     child: _buildCommentTextField(context),
            //   ),
            // ),
            // SizedBox(width: 10.w),
            // _buildCommentButton(context)
          ],
        ),
        Text('comment show korbe')
        // _buildComments()
      ],
    ),
  );
}

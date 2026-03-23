import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_image_widget.dart';
import 'package:mh/app/common/widgets/custom_video_widget.dart';
import 'package:mh/app/common/widgets/social_caption_widget.dart';
import 'package:mh/app/models/comment_response_model.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/repost_request_model.dart';
import 'package:mh/app/models/social_comment_request_model.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/models/social_post_report_request_model.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import 'package:mh/app/modules/common_modules/social_post_details/controllers/social_post_details_controller.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/app/common/data/data.dart';
import 'package:share_plus/share_plus.dart';
import '../../modules/client/employee_details/controllers/employee_details_controller.dart';
import '../../modules/common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../modules/common_modules/common_social_feed/views/common_social_feed_view.dart';
import '../../modules/common_modules/live_chat/widgets/copy_able_text_widget.dart';
import '../../modules/common_modules/social_post_details/controllers/social_post_details_controller_temporary_to_reload_reactions.dart';
import '../../modules/employee/employee_home/models/common_response_model.dart';
import '../deep_link_service/deep_link_service.dart';
import 'social_post_media_widget.dart';

class SocialPostWidget extends StatefulWidget {
  final bool? isDetails;
  final bool? fullView;

  final SocialPostModel socialPost;
  final void Function() react;
  final bool isSave;
  final void Function() save;
  final void Function() deleteSavePost;
  final void Function() blockUserAndRefreshSocialFeed;
  final void Function()? followUnfollow;
  final Future<void> Function({required RepostRequestModel repostRequestModel})?
      repost;
  final void Function(
          {required SocialPostReportRequestModel socialPostReportRequestModel})
      addReport;

  final Future<void> Function({required String postId})? deletePost;
  final Future<void> Function({required String postId, required bool active})?
      inActivePost;

  final CommonSocialFeedController commonSocialFeedController;

  const SocialPostWidget(
      {super.key,
      this.isDetails,
      this.fullView,
      required this.socialPost,
      required this.react,
      required this.save,
      required this.blockUserAndRefreshSocialFeed,
      this.followUnfollow,
      required this.addReport,
      this.inActivePost,
      this.deletePost,
      this.repost,
      required this.isSave,
      required this.deleteSavePost,
      required this.commonSocialFeedController});

  @override
  State<SocialPostWidget> createState() => _SocialPostWidgetState();
}

class _SocialPostWidgetState extends State<SocialPostWidget> {
  final TextEditingController tecComment = TextEditingController();
  final TextEditingController tecReply = TextEditingController();
  final TextEditingController tecReport = TextEditingController();
  final TextEditingController tecThoughts = TextEditingController();
  bool showComment = false;
  String? editingCommentId;
  final TextEditingController tecCommentEdit = TextEditingController();
  String? editingReplyId;
  String? activeReplyId;
  bool isCommentEdit = false;
  bool isReplyEdit = false;
  bool _isReplyLoading = false;
  bool _isEditReplyLoading = false; // Reply Edit loading state
  bool _isCommentLoading = false; // Comment loading state
  bool _isEditCommentLoading = false; // Comment Edit loading state
  final TextEditingController tecReplyEdit = TextEditingController();

  String?
      activeReplyCommentId; // This will store the id of the comment being replied to.
  bool _isLiked = false;
  int _totalLike = 0;
  SocialUser? firstLiker;

  List<Comment> commentList = <Comment>[];
  bool isActive = true;

  @override
  void initState() {
    if (widget.isDetails == true && widget.fullView == false) {
      showComment = true;
    }
    if (widget.socialPost.likes!.isNotEmpty) {
      _totalLike = widget.socialPost.likes!.length;
      firstLiker = widget.socialPost.likes![0];
    }
    _isLiked = (widget.socialPost.likes ?? []).any(
        (SocialUser a) => a.id == Get.find<AppController>().user.value.userId);

    commentList = widget.socialPost.comments ?? [];
    if (commentList.isNotEmpty) {
      commentList = commentList.reversed.toList();
    }
    isActive = (widget.socialPost.active ?? true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int mediaCount = (widget.socialPost.media ?? []).length;
    List<Media> visibleMedia = (widget.socialPost.media ?? []).take(4).toList();

    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.socialPostDetails, arguments: widget.socialPost.id);
        Get.put<SocialPostDetailsController>(SocialPostDetailsController())
            .getSocialPostInfoByPostId(widget.socialPost.id);
      },
      child: Container(
        margin: EdgeInsets.only(top: (widget.isDetails ?? false) ? 0.0 : 5.w),
        padding: EdgeInsets.only(top: 15.0.w, bottom: 15.0.w),
        decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          border: Border.all(color: MyColors.noColor, width: 0.5),
          borderRadius:
              BorderRadius.circular((widget.isDetails ?? false) ? 0.0 : 10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
              child: Row(
                children: [
                  _buildPostPublishersDetails(context),
                  // Spacer(),
                  if (widget.inActivePost != null)
                    _buildInActivePostPopUpButtons(context),
                  widget.socialPost.user?.id !=
                              Get.find<AppController>().user.value.userId &&
                          !Get.find<AppController>().user.value.isAdmin
                      ? _buildBlockFollowPopUpButtons(context)
                      : SizedBox.shrink(),
                ],
              ),
            ),
            if ((widget.socialPost.content ?? "").isNotEmpty) ...[
              SizedBox(height: 8.w),
              Padding(
                padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                child:
                    SocialCaptionWidget(text: widget.socialPost.content ?? ""),
              ),
            ],
            SizedBox(height: widget.socialPost.repost != null ? 5.w : 20.w),
            if (widget.socialPost.repost != null)
              Padding(
                padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                child: _repostWidget(repost: widget.socialPost.repost!),
              ),
            // widget.socialPost.repost != null
            //     ? Padding(
            //         padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
            //         child: _repostWidget(repost: widget.socialPost.repost!),
            //       )
            //     : Container(
            //         width: double.infinity,
            //         margin: EdgeInsets.only(
            //             top: 15.0.h, left: 15.0.w, right: 15.0.w),
            //         padding: EdgeInsets.all(15.0.w),
            //         decoration: BoxDecoration(
            //           color: MyColors.lightCard(context),
            //           border: Border.all(color: MyColors.lightGrey, width: 0.3),
            //           borderRadius: BorderRadius.circular(15.0),
            //         ),
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Icon(
            //               CupertinoIcons.lock_fill,
            //               size: 16,
            //               color: MyColors.l111111_dwhite(context),
            //             ),
            //             SizedBox(width: 8.w),
            //             Expanded(
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     "This content isn't available at the moment",
            //                     style: TextStyle(
            //                       fontFamily: MyAssets.fontMontserrat,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.bold,
            //                       color: MyColors.l111111_dwhite(context),
            //                     ),
            //                   ),
            //                   SizedBox(height: 8.h),
            //                   Text(
            //                     "When this happens, it's usually because the owner only shared it with a small group of people, changed who can see it, or it's been deleted.",
            //                     style: TextStyle(
            //                       fontFamily: MyAssets.fontMontserrat,
            //                       fontSize: 12,
            //                       fontWeight: FontWeight.w400,
            //                       color: MyColors.l111111_dwhite(context),
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            if ((widget.socialPost.media ?? []).length == 1)
              (widget.socialPost.media ?? []).first.type == 'image'
                  ? _buildSingleImage()
                  : _buildSingleVideo()
            else if ((widget.socialPost.media ?? []).isEmpty)
              const Wrap()
            else
              SizedBox(
                height: mediaCount >= 3 ? Get.width * 0.95 : 200.w,
                child: mediaCount == 3
                    ? _buildOnlyThreeItems(visibleMedia)
                    : _buildMoreThanThreeView(visibleMedia, mediaCount),
              ),
            // Divider(color: MyColors.dividerColor, height: 0.h, thickness: 0.25),
            SizedBox(height: 15.h),
            // _buildInteractionCount(context),
            _buildInteraction(context),
            if (showComment) _buildShowComment(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreThanThreeView(List<Media> visibleMedia, int mediaCount) {
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
              (widget.socialPost.media ?? [])[3].type == 'video'
                  ? thumbImageWidget(
                      url: (widget.socialPost.media ?? [])[3]
                              .thumbnail
                              ?.socialMediaUrl ??
                          '',
                      height: Get.height,
                    )
                  : _buildMediaWidget(
                      post: post,
                      height: Get.height,
                    ),
              // Overlay the count of additional items on the 4th media
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 3,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 3),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 3,
                  //     mediaList: (widget.socialPost.media ?? []),
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
        if (index == 0 && (widget.socialPost.media ?? [])[0].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 0,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 0),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 0, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (widget.socialPost.media ?? [])[0]
                      .thumbnail
                      ?.socialMediaUrl ??
                  '',
              height: Get.height,
            ),
          );
        }
        if (index == 1 && (widget.socialPost.media ?? [])[1].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 1,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 1),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 1, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (widget.socialPost.media ?? [])[1]
                      .thumbnail
                      ?.socialMediaUrl ??
                  '',
              height: Get.height,
            ),
          );
        }
        if (index == 2 && (widget.socialPost.media ?? [])[2].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 2,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 2),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 2, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (widget.socialPost.media ?? [])[2]
                      .thumbnail
                      ?.socialMediaUrl ??
                  '',
              height: Get.height,
            ),
          );
        }
        if (index == 3 && (widget.socialPost.media ?? [])[3].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 3,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 3),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 3, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (widget.socialPost.media ?? [])[3]
                      .thumbnail
                      ?.socialMediaUrl ??
                  '',
              height: Get.height,
            ),
          );
        }

        // Regular media items (image or video)
        return GestureDetector(
          onTap: () => Get.to(() => SocialPostMediaWidget(
                socialPost: widget.socialPost,
                react: () {
                  print(
                      '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                  widget.react();
                },
                save: widget.save,
                repost: widget.repost,
                isSave: widget.isSave,
                deleteSavePost: widget.deleteSavePost,
                commonSocialFeedController: widget.commonSocialFeedController,
                sliderCurrentIndex: index,
              )),
          // onTap: () => widget.commonSocialFeedController
          //     .seeMediaDetails(widget.socialPost, index),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 0, mediaList: (widget.socialPost.media ?? []))),
          child: _buildMediaWidget(post: post, height: Get.height),
        );
      }).toList(),
    );
  }

  Widget _buildOnlyThreeItems(List<Media> visibleMedia) {
    return SingleChildScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: Get.width * 0.5,
            child: GestureDetector(
              onTap: () => Get.to(() => SocialPostMediaWidget(
                    socialPost: widget.socialPost,
                    react: () {
                      print(
                          '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                      widget.react();
                    },
                    save: widget.save,
                    repost: widget.repost,
                    isSave: widget.isSave,
                    deleteSavePost: widget.deleteSavePost,
                    commonSocialFeedController:
                        widget.commonSocialFeedController,
                    sliderCurrentIndex: 0,
                  )),
              // onTap: () => widget.commonSocialFeedController
              //     .seeMediaDetails(widget.socialPost, 0),
              // onTap: () => Get.to(() => MediaViewAllWidget(
              //     index: 0, mediaList: (widget.socialPost.media ?? []))),
              child: (widget.socialPost.media ?? [])[0].type == 'video'
                  ? thumbImageWidget(
                      url: (widget.socialPost.media ?? [])[0]
                              .thumbnail
                              ?.socialMediaUrl ??
                          '',
                      height: Get.width * 0.5,
                    )
                  : _buildMediaWidget(
                      post: visibleMedia[0],
                      height: Get.width * 0.5,
                      hasAspect: false,
                    ),
            ),
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 1,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 1),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 1,
                  //     mediaList: (widget.socialPost.media ?? []),
                  //   ),
                  // ),
                  child: (widget.socialPost.media ?? [])[1].type == 'video'
                      ? thumbImageWidget(
                          url: (widget.socialPost.media ?? [])[1]
                                  .thumbnail
                                  ?.socialMediaUrl ??
                              '',
                          height: Get.width * 0.5,
                        )
                      : _buildMediaWidget(
                          post: visibleMedia[1], height: Get.width * 0.35),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 2,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 2),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 2,
                  //     mediaList: (widget.socialPost.media ?? []),
                  //   ),
                  // ),
                  child: (widget.socialPost.media ?? [])[2].type == 'video'
                      ? thumbImageWidget(
                          url: (widget.socialPost.media ?? [])[2]
                                  .thumbnail
                                  ?.socialMediaUrl ??
                              '',
                          height: Get.width * 0.5,
                        )
                      : _buildMediaWidget(
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

  Widget _buildSingleVideo() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.w),
      child: CustomVideoWidget(
        radius: 1,
        media: (widget.socialPost.media ?? []).first,
        hasAspect: false,
      ),
    );
  }

  Widget _buildSingleImage() {
    return Padding(
      padding: EdgeInsets.only(bottom: 15.w),
      child: GestureDetector(
        onTap: () => Get.to(() => SocialPostMediaWidget(
              socialPost: widget.socialPost,
              react: () {
                print(
                    '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                widget.react();
              },
              save: widget.save,
              repost: widget.repost,
              isSave: widget.isSave,
              deleteSavePost: widget.deleteSavePost,
              commonSocialFeedController: widget.commonSocialFeedController,
              sliderCurrentIndex: 0,
            )),
        // onTap: () => widget.commonSocialFeedController
        //     .seeMediaDetails(widget.socialPost, 0),
        // onTap: () => Get.to(() => MediaViewAllWidget(
        //     index: 0, mediaList: widget.socialPost.media ?? [])),
        child: CustomImageWidget(
            imgUrl: ((widget.socialPost.media ?? []).first.url ?? "")
                .socialMediaUrl,
            radius: 1.0,
            width: Get.width,
            height: (widget.socialPost.media ?? []).first.scaledHeight,
            fit: BoxFit.cover),
      ),
    );
  }

  PopupMenuButton<int> _buildInActivePostPopUpButtons(BuildContext context) {
    return PopupMenuButton<int>(
      color: MyColors.lightCard(context),
      icon:
          Image.asset(MyAssets.socialMenu, height: 4, color: MyColors.c_9A9A9A),
      onSelected: (int result) async {
        // Handle the selected menu item
        if (result == 0) {
          Get.toNamed(Routes.updatePost, arguments: [widget.socialPost]);
        } else if (result == 1) {
          isActive = !isActive;
          await widget.inActivePost!(
              postId: widget.socialPost.id ?? "", active: isActive);
        } else if (result == 2) {
          await widget.deletePost!(postId: widget.socialPost.id ?? "");
        } else if (result == 3) {
          if (!Get.find<AppController>().user.value.isAdmin) {
            _showReport(context: context);
          }
        } else if (result == 4) {
          Share.share(DeepLinkService.generateAppLink(
              'social-post_details', {'id': widget.socialPost.id ?? ''}));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        if (!Get.find<AppController>().user.value.isAdmin)
          PopupMenuItem<int>(
            value: 0,
            child: Text(
              MyStrings.edit.tr,
              style: TextStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontSize: 13,
                  color: MyColors.l111111_dwhite(context)),
            ),
          ),
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text(
            MyStrings.delete.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
        PopupMenuItem(
            value: 3,
            child: Text(
              'Report',
              // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
              style: TextStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontSize: 13,
                  color: MyColors.l111111_dwhite(context)),
            )),
        PopupMenuItem(
            value: 4,
            child: Text(
              'Share',
              style: TextStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontSize: 13,
                  color: MyColors.l111111_dwhite(context)),
            ))
      ],
    );
  }

  PopupMenuButton<int> _buildBlockFollowPopUpButtons(BuildContext context) {
    return PopupMenuButton<int>(
      color: MyColors.lightCard(context),
      icon:
          Image.asset(MyAssets.socialMenu, height: 4, color: MyColors.c_9A9A9A),
      onSelected: (int result) async {
        // Handle the selected menu item
        if (result == 0) {
          //Do follow Unfollow
          Get.defaultDialog(
            contentPadding: EdgeInsets.all(20),
            middleText: 'Do you want to follow this user?',
            content: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    Icons.add_reaction,
                    color: MyColors.primaryDark,
                  ),
                ),
                // Image.asset(MyAssets.blocking,height: 30,width: 30,),
                Get.find<AppController>()
                        .isFollowing(widget.socialPost.user?.id ?? '')
                    ? Text('Do you want to unfollow this user?')
                    : Text('Do you want to follow this user?'),
              ],
            ),
            title: 'Are you sure?',
            confirm: CustomButtons.button(
              backgroundColor: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "Yes",
              onTap: () {
                Get.back();
                if (widget.followUnfollow != null) {
                  widget.followUnfollow!();
                }
              },
            ),
            cancel: CustomButtons.button(
              backgroundColor: Colors.transparent,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "No",
              onTap: () {
                Get.back();
              },
            ),
          );
        } else if (result == 1) {
          //Do Block Unblock
          Get.defaultDialog(
            contentPadding: EdgeInsets.all(20),
            title: 'Are you sure?',
            content: Column(
              children: [
                Image.asset(
                  MyAssets.blocking,
                  height: 30,
                  width: 30,
                ),
                Text('Do you want to block this user?')
              ],
            ),
            confirm: CustomButtons.button(
              backgroundColor: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "Yes",
              onTap: () {
                Get.back();
                widget.blockUserAndRefreshSocialFeed();
              },
            ),
            cancel: CustomButtons.button(
              backgroundColor: Colors.transparent,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "Cancel",
              onTap: () {
                Get.back();
              },
            ),
          );
        } else if (result == 2) {
          Share.share(DeepLinkService.generateAppLink(
              'social-post_details', {'id': widget.socialPost.id ?? ''}));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            Get.find<AppController>()
                    .isFollowing(widget.socialPost.user?.id ?? '')
                ? MyStrings.following.tr
                : MyStrings.follow.tr,
            // MyStrings.follow.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            'Block',
            // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text(
            'Share',
            // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildBlockUnblockUserButton(BuildContext context) {
    return InkWell(
        onTap: () {
          debugPrint(widget.socialPost.user?.id ?? "");
          Get.defaultDialog(
            contentPadding: EdgeInsets.all(20),
            middleText: 'Do you want to block this user?',
            title: 'Are you sure?',
            confirm: CustomButtons.button(
              backgroundColor: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "Yes",
              onTap: () {
                Get.back();
                widget.blockUserAndRefreshSocialFeed();
              },
            ),
            cancel: CustomButtons.button(
              backgroundColor: Colors.transparent,
              margin: EdgeInsets.symmetric(horizontal: 5.w),
              height: 28,
              context: Get.context!,
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
              text: "Cancel",
              onTap: () {
                Get.back();
              },
            ),
          );
        },
        child: Icon(Icons.close));
  }

  Widget _buildInteractionCount(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _totalLike == 0
              ? SizedBox.shrink()
              : _totalLike == 1
                  ? InkWell(
                      onTap: () {
                        Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                                SocialPostDetailsControllerTemporaryToReloadReactions())
                            .context = context;
                        Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                                SocialPostDetailsControllerTemporaryToReloadReactions())
                            .getSocialPostInfoByPostId(widget.socialPost.id);
                      },
                      child: Text(
                        "${Utils.truncateCharacters(firstLiker?.name ?? '', 20)} likes this",
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 12,
                          color: MyColors.dividerColor,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                                SocialPostDetailsControllerTemporaryToReloadReactions())
                            .context = context;
                        Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                                SocialPostDetailsControllerTemporaryToReloadReactions())
                            .getSocialPostInfoByPostId(widget.socialPost.id);
                      },
                      child: Text(
                        "${Utils.truncateCharacters(firstLiker?.name ?? '', 20)} +${_totalLike - 1} likes",
                        style: TextStyle(
                          fontFamily: MyAssets.fontMontserrat,
                          fontSize: 12,
                          color: MyColors.dividerColor,
                        ),
                      ),
                    ),
          getTotalCommentCount(comments: commentList) == 0
              ? SizedBox.shrink()
              : Text(
                  "${getTotalCommentCount(comments: commentList)} comments",
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 12,
                    color: MyColors.dividerColor,
                  ),
                ),
          Text(
            "${widget.socialPost.views ?? 0} views",
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

  Widget _buildInteraction(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
      child: Row(
        // mainAxisAlignment: (widget.socialPost.repost != null)
        //     ? MainAxisAlignment.spaceAround
        //     : MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  if (!Get.find<AppController>().user.value.isAdmin) {
                    setState(() {
                      _isLiked = !_isLiked;
                      if (_isLiked == false) {
                        _totalLike = _totalLike - 1;
                      } else {
                        _totalLike = _totalLike + 1;
                        firstLiker ??= SocialUser(
                            name:
                                Get.find<AppController>().user.value.userName);
                      }
                    });
                    widget.react();
                  }
                },
                onLongPress: () {
                  Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                          SocialPostDetailsControllerTemporaryToReloadReactions())
                      .context = context;
                  Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                          SocialPostDetailsControllerTemporaryToReloadReactions())
                      .getSocialPostInfoByPostId(widget.socialPost.id);
                },
                child: Icon(
                    _isLiked
                        ? CupertinoIcons.hand_thumbsup_fill
                        : CupertinoIcons.hand_thumbsup,
                    size: 25.w,
                    color: _isLiked
                        ? MyColors.primaryLight
                        : MyColors.dividerColor),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {
                  Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                          SocialPostDetailsControllerTemporaryToReloadReactions())
                      .context = context;
                  Get.put<SocialPostDetailsControllerTemporaryToReloadReactions>(
                          SocialPostDetailsControllerTemporaryToReloadReactions())
                      .getSocialPostInfoByPostId(widget.socialPost.id);
                },
                child: Text(
                  "$_totalLike",
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 14,
                    color: MyColors.dividerColor,
                  ),
                ),
              )
            ],
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routes.socialPostDetails,
                  arguments: widget.socialPost.id);
              Get.put<SocialPostDetailsController>(
                      SocialPostDetailsController())
                  .getSocialPostInfoByPostId(widget.socialPost.id);
              // if (!Get.find<AppController>().user.value.isAdmin) {
              //   setState(() {
              //     showComment = !showComment;
              //   });
              // }
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.chat_bubble,
                    size: 24.w, color: MyColors.dividerColor),
                SizedBox(width: 10.w),
                Text(
                  "${getTotalCommentCount(comments: commentList)}",
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 14,
                    color: MyColors.dividerColor,
                  ),
                )
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            children: [
              Icon(Icons.remove_red_eye_outlined,
                  size: 24.w, color: MyColors.dividerColor),
              SizedBox(width: 10.w),
              Text(
                "${widget.socialPost.views}",
                style: TextStyle(
                  fontFamily: MyAssets.fontMontserrat,
                  fontSize: 14,
                  color: MyColors.dividerColor,
                ),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (!Get.find<AppController>().user.value.isAdmin) {
                if (widget.isSave) {
                  widget.deleteSavePost();
                } else {
                  widget.save();
                }
              }
            },
            child: Row(
              children: [
                Icon(
                    widget.isSave
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    size: 24.w,
                    color: widget.isSave
                        ? MyColors.primaryLight
                        : MyColors.dividerColor),
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
          if (widget.repost != null && widget.socialPost.repost == null)
            GestureDetector(
              onTap: () {
                if (!Get.find<AppController>().user.value.isAdmin) {
                  _showRepost(context: context);
                }
              },
              child: Row(
                children: [
                  Icon(CupertinoIcons.repeat,
                      size: 24.w, color: MyColors.dividerColor),
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
      ),
    );
  }

  Widget _buildShowComment(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
      child: Column(
        children: [
          SizedBox(height: 15.h),
          if (!Get.find<AppController>().user.value.isAdmin)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 10,
                  child: SizedBox(
                    height: 40,
                    child: _buildCommentTextField(context),
                  ),
                ),
                SizedBox(width: 10.w),
                _buildCommentButton(context)
              ],
            ),
          _buildComments()
        ],
      ),
    );
  }

  Widget _buildComments() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      reverse: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: commentList.length,
      itemBuilder: (BuildContext context, int index) {
        Comment c = commentList[index];
        Comment comment = c;

        return Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: _buildComentsListTitle(c, context),
              leading: editingCommentId == comment.id && editingReplyId == null
                  ? GestureDetector(
                      onTap: _cancelEdit,
                      child: Icon(
                        Icons.close,
                        color: Colors.red,
                      ))
                  : _buildEditingComment(c),
              subtitle: editingCommentId == comment.id && editingReplyId == null
                  ? _buildEditCommentField(
                      comment) // Display editable field if in edit mode
                  : _editingCommentSubTitle(c, context),
              trailing: comment.user?.id ==
                      Get.find<AppController>().user.value.userId
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _startEditingComment(comment);
                        } else if (value == 'delete') {
                          _deleteComment(comment.id!);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: MyColors.primaryLight),
                              SizedBox(width: 8),
                              Text(
                                "Edit",
                                style: TextStyle(
                                    fontFamily: MyAssets.fontMontserrat),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Delete",
                                style: TextStyle(
                                    fontFamily: MyAssets.fontMontserrat),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            if (activeReplyCommentId == c.id)
              _buildActiveReplyComment(context, c, index),
            if ((c.children ?? []).isNotEmpty) _buildChildComment(c)
          ],
        );
      },
    );
  }

  Widget _editingCommentSubTitle(Comment c, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CopyableTextWidget(
          text: c.text ?? "",
          textStyle: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            color: MyColors.l111111_dwhite(context),
          ),
          textColor: MyColors.l111111_dwhite(context),
          linkColor: Colors.blue,
        ),
        // Text(
        //   c.text ?? "",
        //   style: TextStyle(
        //     fontFamily: MyAssets.fontMontserrat,
        //     fontSize: 12,
        //     color: MyColors.l111111_dwhite(context),
        //   ),
        // ),
        SizedBox(height: 5.w),
        if (!Get.find<AppController>().user.value.isAdmin)
          GestureDetector(
            onTap: () {
              setState(() {
                activeReplyCommentId = (activeReplyCommentId == c.id)
                    ? null
                    : c.id ?? ""; // Toggle reply field
              });
            },
            child: Text(
              MyStrings.reply.tr,
              style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 12,
                color: MyColors.lightGrey,
              ),
            ),
          ),
      ],
    );
  }

  GestureDetector _buildEditingComment(Comment c) {
    return GestureDetector(
      onTap: () => c.user?.role?.toLowerCase() == "client"
          ? Get.toNamed(Routes.individualSocialFeeds, arguments: c.user)
          : Get.toNamed(Routes.employeeDetails,
              arguments: {'employeeId': c.user?.id ?? ""}),
      child: CircleAvatar(
        backgroundImage: ((c.user?.profilePicture ?? "").isEmpty ||
                c.user?.profilePicture == "undefined")
            ? AssetImage(c.user?.role?.toUpperCase() == "ADMIN"
                ? MyAssets.adminDefault
                : c.user?.role?.toUpperCase() == "CLIENT"
                    ? MyAssets.clientDefault
                    : MyAssets.employeeDefault)
            : NetworkImage((c.user?.profilePicture ?? "").socialMediaUrl),
      ),
    );
  }

  Widget _buildChildComment(Comment c) {
    return Padding(
      padding: EdgeInsets.only(left: 30.0.w),
      child: ListView.builder(
        itemCount: (c.children ?? []).length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          Comment reply = (c.children ?? [])[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
            title: _buildChildCommentTitle(reply, context),
            leading: editingReplyId == reply.id
                ? GestureDetector(
                    onTap: _cancelEdit,
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                    ))
                : _buildEditingComment(reply),
            subtitle: editingReplyId == reply.id
                ? _buildEditReplyField(
                    reply) // Show editable field if in edit mode
                : CopyableTextWidget(
                    text: reply.text ?? "",
                    textStyle: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 12,
                      color: MyColors.lightGrey,
                    ),
                    textColor: MyColors.lightGrey,
                    linkColor: Colors.blue,
                  ),
            // Text(
            //         reply.text ?? "",
            //         style: TextStyle(
            //           fontFamily: MyAssets.fontMontserrat,
            //           fontSize: 12,
            //           color: MyColors.lightGrey,
            //         ),
            //       ),
            trailing:
                reply.user?.id == Get.find<AppController>().user.value.userId
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _startEditingReply(c.id!, reply);
                            log("reply id selected for edit: ${reply.id}");
                          } else if (value == 'delete') {
                            _deleteReply(reply.id!);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: MyColors.primaryLight),
                                SizedBox(width: 8),
                                Text(
                                  "Edit",
                                  style: TextStyle(
                                      fontFamily: MyAssets.fontMontserrat),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  "Delete",
                                  style: TextStyle(
                                      fontFamily: MyAssets.fontMontserrat),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : null,
          );
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Row _buildChildCommentTitle(Comment reply, BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => reply.user?.role?.toLowerCase() == "client"
              ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user)
              : Get.toNamed(Routes.employeeDetails,
                  arguments: {'employeeId': reply.user?.id ?? ""}),
          child: Text(
            reply.user?.name != null && reply.user!.name!.length > 12
                ? '${Utils.truncateCharacters(reply.user!.name ?? '', 12)}'
                : reply.user?.name ?? '',
            style: TextStyle(
              fontFamily: MyAssets.fontMontserrat,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MyColors.l111111_dwhite(context),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 1.5,
          backgroundColor: MyColors.l111111_dwhite(context),
        ),
        SizedBox(width: 10.w),
        Text(
          Utils.formatDateTime(reply.createdAt ?? DateTime.now(),
              socialFeed: true),
          style: TextStyle(
              fontFamily: MyAssets.fontMontserrat,
              fontSize: 12,
              color: MyColors.lightGrey),
        ),
      ],
    );
  }

  Widget _buildActiveReplyComment(BuildContext context, Comment c, int index) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () {
              setState(() {
                activeReplyCommentId = null; // Close reply field
              });
            },
            child: Icon(Icons.clear, color: Colors.red, size: 15),
          ),
        ),
        Expanded(
            flex: 5,
            child: SizedBox(
              height: 40,
              child: TextField(
                maxLines: null,
                minLines: 1,
                controller: tecReply,
                style: MyColors.l111111_dwhite(context).medium13,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0.w),
                    filled: true,
                    hintText: MyStrings.writeAReply.tr,
                    hintStyle: MyColors.lightGrey.medium13,
                    fillColor: MyColors.noColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(
                            width: 0.05, color: MyColors.lightGrey))),
              ),
            )),
        const SizedBox(width: 10),
        Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: _isReplyLoading ? null : () => _addReply(c, index),
              child: _isReplyLoading
                  ? CupertinoActivityIndicator(
                      radius: 10, // Adjust the radius for size
                    ) // Show loading if true
                  : const Icon(Icons.send, color: MyColors.primaryLight),
            )),
      ],
    );
  }

  Row _buildComentsListTitle(Comment c, BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => c.user?.role?.toLowerCase() == "client"
              ? Get.toNamed(Routes.individualSocialFeeds, arguments: c.user)
              : Get.toNamed(Routes.employeeDetails,
                  arguments: {'employeeId': c.user?.id ?? ""}),
          child: Text(
            c.user?.name != null && c.user!.name!.length > 15
                ? '${Utils.truncateCharacters(c.user!.name ?? '', 15)}'
                : c.user?.name ?? '',
            style: TextStyle(
              fontFamily: MyAssets.fontMontserrat,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MyColors.l111111_dwhite(context),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 1.5,
          backgroundColor: MyColors.l111111_dwhite(context),
        ),
        SizedBox(width: 10.w),
        Text(
          Utils.formatDateTime(c.createdAt ?? DateTime.now(), socialFeed: true),
          style: TextStyle(
            fontFamily: MyAssets.fontMontserrat,
            fontSize: 12,
            color: MyColors.lightGrey,
          ),
        )
      ],
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: _isCommentLoading
            ? null
            : () async {
                Utils.unFocus();
                if (tecComment.text.isNotEmpty) {
                  String inputText = tecComment.text.trim();
                  tecComment.clear();
                  setState(() {
                    _isCommentLoading = true; // Start loading
                  });
                  Get.find<ApiHelper>()
                      .addComment(
                          socialCommentRequestModel: SocialCommentRequestModel(
                              text: inputText,
                              postId: widget.socialPost.id ?? "",
                              parentId: ""))
                      .then(
                    (dartz.Either<CustomError, CommentResponseModel> response) {
                      setState(() {
                        _isCommentLoading = false; // Stop loading
                      });
                      response.fold(
                        (CustomError customError) {
                          Utils.errorDialog(context, customError);
                        },
                        (CommentResponseModel response) async {
                          Comment comment = Comment(
                            id: response.comment?.id ?? "",
                            text: inputText,
                            children: <Comment>[],
                            createdAt: DateTime.now(),
                            user: SocialUser(
                                id: Get.find<AppController>().user.value.userId,
                                name: Get.find<AppController>()
                                    .user
                                    .value
                                    .userName,
                                positionId: '',
                                positionName: '',
                                email: Get.find<AppController>()
                                    .user
                                    .value
                                    .userEmail,
                                role: Get.find<AppController>()
                                    .user
                                    .value
                                    .userRole,
                                profilePicture: Utils.getProfilePicture,
                                countryName: Get.find<AppController>()
                                    .user
                                    .value
                                    .userCountry),
                          );
                          commentList.insert(0, comment);
                          setState(() {});
                        },
                      );
                    },
                  );
                }
              },
        child: _isCommentLoading
            ? CupertinoActivityIndicator(
                radius: 10, // Adjust the radius for size
              )
            : const Icon(
                Icons.send_outlined,
                color: MyColors.primaryLight,
              ),
      ),
    );
  }

  Widget _buildCommentTextField(BuildContext context) {
    return TextField(
      controller: tecComment,
      maxLines: null,
      minLines: 1,
      style: MyColors.l111111_dwhite(context).medium13,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10.0.w),
        filled: true,
        hintText: MyStrings.writeAComment.tr,
        hintStyle: MyColors.lightGrey.medium13,
        fillColor: MyColors.noColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            width: 0.05,
            color: MyColors.lightGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildPostPublishersDetails(BuildContext context) {
// <<<<<<< HEAD
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.socialPost.user?.role?.toLowerCase() == "client"
            ? Get.toNamed(Routes.individualSocialFeeds,
                arguments: widget.socialPost.user)
            : Get.toNamed(Routes.employeeDetails,
                arguments: {'employeeId': widget.socialPost.user?.id ?? ""}),
        child: Row(
          children: [
            CircleAvatar(
                radius: 18,
                backgroundColor: MyColors.noColor,
                backgroundImage: ((widget.socialPost.user?.profilePicture ?? "")
                            .isEmpty ||
                        widget.socialPost.user?.profilePicture == "undefined")
                    ? AssetImage(
                        widget.socialPost.user?.role?.toUpperCase() == "ADMIN"
                            ? MyAssets.adminDefault
                            : widget.socialPost.user?.role?.toUpperCase() ==
                                    "CLIENT"
                                ? MyAssets.clientDefault
                                : MyAssets.employeeDefault)
                    : CachedNetworkImageProvider(
                        (widget.socialPost.user?.profilePicture ?? "")
                            .socialMediaUrl)),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.socialPost.user?.name != null &&
                            widget.socialPost.user!.name!.length > 17
                        ? Utils.truncateCharacters(
                            widget.socialPost.user!.name ?? '', 17)
                        : widget.socialPost.user?.name ?? '',
                    style: TextStyle(
                        fontFamily: MyAssets.fontMontserrat,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: MyColors.l111111_dwhite(context)),
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SvgPicture.network(
                        Data.getCountryFlagByName(
                            widget.socialPost.user!.countryName.toString()),
                        width: 10,
                        height: 10,
                      ),
                      if (widget.socialPost.user?.role?.toUpperCase() !=
                              "CLIENT" &&
                          widget.socialPost.user?.role?.toUpperCase() !=
                              "ADMIN")
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          child: CircleAvatar(
                            radius: 1.5,
                            backgroundColor: MyColors.l111111_dwhite(context),
                          ),
                        ),
                      if (widget.socialPost.user?.role?.toUpperCase() !=
                              "CLIENT" &&
                          widget.socialPost.user?.role?.toUpperCase() !=
                              "ADMIN")
                        Text(
                          widget.socialPost.user?.positionName ?? "",
                          style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: 11,
                              color: MyColors.lightGrey),
                        ),
                      SizedBox(width: 10.w),
                      CircleAvatar(
                        radius: 1.5,
                        backgroundColor: MyColors.l111111_dwhite(context),
                      ),
                      SizedBox(width: 10.w),
                      isActive
                          ? Text(
                              Utils.formatDateTime(
                                  socialFeed: true,
                                  widget.socialPost.createdAt ??
                                      DateTime.now()),
                              style: TextStyle(
                                  fontFamily: MyAssets.fontMontserrat,
                                  fontSize: 11,
                                  color: MyColors.lightGrey))
                          : Text(
                              "HOLD",
                              style: TextStyle(
                                  fontFamily: MyAssets.fontMontserrat,
                                  fontSize: 11,
                                  color: MyColors.lightGrey),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReport({required BuildContext context}) {
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(30.0),
      width: double.infinity,
      decoration: BoxDecoration(
          color: MyColors.lightCard(context),
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15.0), topLeft: Radius.circular(15.0))),
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              minLines: 5,
              maxLines: null,
              controller: tecReport,
              style: MyColors.l111111_dwhite(context).medium13,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(15.0.w),
                  filled: true,
                  hintText: MyStrings.writeAReason.tr,
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
            SizedBox(height: 30.w),
            CustomButtons.button(
                margin: EdgeInsets.zero,
                text: MyStrings.submit.tr,
                onTap: () {
                  if (tecReport.text.isNotEmpty) {
                    widget.addReport(
                        socialPostReportRequestModel:
                            SocialPostReportRequestModel(
                                postId: widget.socialPost.id ?? "",
                                reason: tecReport.text));
                    Get.back();
                    tecReport.clear();
                  } else {
                    Utils.showSnackBar(
                        message: MyStrings.reasonIsRequired.tr, isTrue: false);
                  }
                })
          ],
        ),
      ),
    ));
  }

  void _showRepost({required BuildContext context}) {
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
                    await widget.repost!(
                        repostRequestModel: RepostRequestModel(
                            content: tecThoughts.text.trim(),
                            postId: widget.socialPost.id ?? ""));
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
              controller: tecThoughts,
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

  //Helper function to build media widget (image or video)
  Widget _buildMediaWidget(
      {required Media post, double? height, bool hasAspect = true}) {
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
        // height: height,
        radius: 1,
        hasAspect: hasAspect,
      );
    }
    return Container(); // Fallback in case of unknown media type
  }

  Widget _repostWidget({required Repost repost}) {
    int mediaCount = (repost.media ?? []).length;
    List<Media> visibleMedia = (repost.media ?? []).take(4).toList();

    return repost.active == false
        ? Center(child: Text('Post not available'))
        : GestureDetector(
            onTap: () =>
                Get.toNamed(Routes.socialPostDetails, arguments: repost.id),
            child: Container(
              margin: EdgeInsets.only(top: 15.0.h),
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
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
                            onTap: () => Get.to(() => SocialPostMediaWidget(
                                  socialPost: widget.socialPost,
                                  react: () {
                                    print(
                                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                                    widget.react();
                                  },
                                  save: widget.save,
                                  repost: widget.repost,
                                  isSave: widget.isSave,
                                  deleteSavePost: widget.deleteSavePost,
                                  commonSocialFeedController:
                                      widget.commonSocialFeedController,
                                  sliderCurrentIndex: 0,
                                )),
                            // onTap: () => widget.commonSocialFeedController
                            //     .seeMediaDetails(widget.socialPost, 0),
                            // onTap: () => Get.to(() => MediaViewAllWidget(
                            //     index: 0, mediaList: repost.media ?? [])),
                            child: CustomImageWidget(
                                imgUrl: ((repost.media ?? []).first.url ?? "")
                                    .socialMediaUrl,
                                radius: 10.0,
                                width: Get.width,
                                height: (repost.media ?? []).first.scaledHeight,
                                fit: BoxFit.cover),
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
                              repost,
                              visibleMedia,
                            )
                          : _buildRepostItemsMoreThanThree(
                              visibleMedia,
                              mediaCount,
                              repost,
                            ),
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
              : NetworkImage(
                  (repost.user?.profilePicture ?? "").socialMediaUrl)),
    );
  }

  Widget _buildRepostItemsMoreThanThree(
      List<Media> visibleMedia, int mediaCount, Repost repost) {
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
              (repost.media ?? [])[3].type == 'video'
                  ? thumbImageWidget(
                      url: (repost.media ?? [])[3].thumbnail?.socialMediaUrl ??
                          '',
                      height: Get.height,
                    )
                  : _buildMediaWidget(
                      post: post,
                      height: Get.height,
                    ),
              // Overlay the count of additional items on the 4th media
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 3,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 3),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 3,
                  //     mediaList: (widget.socialPost.media ?? []),
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
        if (index == 0 && (repost.media ?? [])[0].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 0,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 0),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 0, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (repost.media ?? [])[0].thumbnail?.socialMediaUrl ?? '',
              height: Get.height,
            ),
          );
        }
        if (index == 1 && (repost.media ?? [])[1].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 1,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 1),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 1, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (repost.media ?? [])[1].thumbnail?.socialMediaUrl ?? '',
              height: Get.height,
            ),
          );
        }
        if (index == 2 && (repost.media ?? [])[2].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 2,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 2),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 2, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (repost.media ?? [])[2].thumbnail?.socialMediaUrl ?? '',
              height: Get.height,
            ),
          );
        }
        if (index == 3 && (repost.media ?? [])[3].type == 'video') {
          return GestureDetector(
            onTap: () => Get.to(() => SocialPostMediaWidget(
                  socialPost: widget.socialPost,
                  react: () {
                    print(
                        '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                    widget.react();
                  },
                  save: widget.save,
                  repost: widget.repost,
                  isSave: widget.isSave,
                  deleteSavePost: widget.deleteSavePost,
                  commonSocialFeedController: widget.commonSocialFeedController,
                  sliderCurrentIndex: 3,
                )),
            // onTap: () => widget.commonSocialFeedController
            //     .seeMediaDetails(widget.socialPost, 3),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 3, mediaList: (widget.socialPost.media ?? []))),
            child: thumbImageWidget(
              url: (repost.media ?? [])[3].thumbnail?.socialMediaUrl ?? '',
              height: Get.height,
            ),
          );
        }

        // Regular media items (image or video)
        return GestureDetector(
          onTap: () => Get.to(() => SocialPostMediaWidget(
                socialPost: widget.socialPost,
                react: () {
                  print(
                      '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                  widget.react();
                },
                save: widget.save,
                repost: widget.repost,
                isSave: widget.isSave,
                deleteSavePost: widget.deleteSavePost,
                commonSocialFeedController: widget.commonSocialFeedController,
                sliderCurrentIndex: index,
              )),
          // onTap: () => widget.commonSocialFeedController
          //     .seeMediaDetails(widget.socialPost, index),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 0, mediaList: (widget.socialPost.media ?? []))),
          child: _buildMediaWidget(post: post, height: Get.height),
        );
      }).toList(),
    );
  }

  Widget _buildRepostItemsThree(Repost repost, List<Media> visibleMedia) {
    return SingleChildScrollView(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: Get.width * 0.5,
            child: GestureDetector(
              onTap: () => Get.to(() => SocialPostMediaWidget(
                    socialPost: widget.socialPost,
                    react: () {
                      print(
                          '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                      widget.react();
                    },
                    save: widget.save,
                    repost: widget.repost,
                    isSave: widget.isSave,
                    deleteSavePost: widget.deleteSavePost,
                    commonSocialFeedController:
                        widget.commonSocialFeedController,
                    sliderCurrentIndex: 0,
                  )),
              // onTap: () => widget.commonSocialFeedController
              //     .seeMediaDetails(widget.socialPost, 0),
              // onTap: () => Get.to(() => MediaViewAllWidget(
              //     index: 0, mediaList: (widget.socialPost.media ?? []))),
              child: (repost.media ?? [])[0].type == 'video'
                  ? thumbImageWidget(
                      url: (repost.media ?? [])[0].thumbnail?.socialMediaUrl ??
                          '',
                      height: Get.width * 0.5,
                    )
                  : _buildMediaWidget(
                      post: visibleMedia[0],
                      height: Get.width * 0.5,
                      hasAspect: false,
                    ),
            ),
          ),
          SizedBox(height: 3.w),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 1,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 1),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 1,
                  //     mediaList: (widget.socialPost.media ?? []),
                  //   ),
                  // ),
                  child: (repost.media ?? [])[1].type == 'video'
                      ? thumbImageWidget(
                          url: (repost.media ?? [])[1]
                                  .thumbnail
                                  ?.socialMediaUrl ??
                              '',
                          height: Get.width * 0.5,
                        )
                      : _buildMediaWidget(
                          post: visibleMedia[1], height: Get.width * 0.35),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.to(() => SocialPostMediaWidget(
                        socialPost: widget.socialPost,
                        react: () {
                          print(
                              '_SocialPostWidgetState._buildSingleImage: call react of post widget');
                          widget.react();
                        },
                        save: widget.save,
                        repost: widget.repost,
                        isSave: widget.isSave,
                        deleteSavePost: widget.deleteSavePost,
                        commonSocialFeedController:
                            widget.commonSocialFeedController,
                        sliderCurrentIndex: 2,
                      )),
                  // onTap: () => widget.commonSocialFeedController
                  //     .seeMediaDetails(widget.socialPost, 2),
                  // onTap: () => Get.to(
                  //   () => MediaViewAllWidget(
                  //     index: 2,
                  //     mediaList: (widget.socialPost.media ?? []),
                  //   ),
                  // ),
                  child: (repost.media ?? [])[2].type == 'video'
                      ? thumbImageWidget(
                          url: (repost.media ?? [])[2]
                                  .thumbnail
                                  ?.socialMediaUrl ??
                              '',
                          height: Get.width * 0.5,
                        )
                      : _buildMediaWidget(
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

  // Method to start editing a comment
  void _startEditingComment(Comment comment) {
    setState(() {
      editingReplyId = null;
      editingCommentId = comment.id; // Set the comment in edit mode
      tecCommentEdit.text = comment.text ?? ""; // Populate the edit text field
    });
  }

  // Widget to build the edit comment text field
  Widget _buildEditCommentField(Comment comment) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: tecCommentEdit,
            maxLines: null,
            minLines: 1,
            style: MyColors.l111111_dwhite(context).medium13,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0.w),
              // hintText: MyStrings.editCommentHint.tr,
              fillColor: MyColors.noColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: MyColors.lightGrey, width: 0.5),
              ),
            ),
          ),
        ),
        IconButton(
          icon: _isEditCommentLoading
              ? CupertinoActivityIndicator(
                  radius: 10, // Adjust the radius for size
                )
              : Icon(Icons.send, color: MyColors.primaryLight),
          onPressed: _isEditCommentLoading
              ? null
              : () async {
                  String updatedText = tecCommentEdit.text.trim();
                  if (updatedText.isNotEmpty) {
                    setState(() {
                      _isEditCommentLoading = true; // Start loading
                    });
                    await _updateComment(comment.id!, updatedText);
                    setState(() {
                      _isEditCommentLoading = false; // Stop loading
                    });
                  }
                },
        ),
      ],
    );
  }

  // Function to update the comment using API helper
  Future<void> _updateComment(String commentId, String updatedText) async {
    final result = await Get.find<ApiHelper>().updateComment(
      postId: widget.socialPost.id!,
      commentId: commentId,
      newText: updatedText,
    );

    result.fold(
      (CustomError error) {
        Utils.errorDialog(context, error); // Show error dialog if update fails
      },
      (CommonResponseModel response) {
        setState(() {
          // Update the comment text in the list
          final comment = commentList.firstWhere((c) => c.id == commentId);
          comment.text = updatedText;
          editingCommentId = null; // Exit edit mode
          editingReplyId = null;
        });
      },
    );
  }

  void _startEditingReply(String parentId, Comment reply) {
    setState(() {
      // editingCommentId = parentId;
      editingCommentId = null;
      editingReplyId = reply.id; // Set the reply in edit mode
      tecReplyEdit.text = reply.text ?? ""; // Populate the edit text field
      print(
          "Editing reply with ID: ${reply.id} under parent ID: $parentId"); // Debugging
    });
  }

  Widget _buildEditReplyField(Comment reply) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: tecReplyEdit,
            maxLines: null,
            minLines: 1,
            style: MyColors.l111111_dwhite(context).medium13,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0.w),
              fillColor: MyColors.noColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: MyColors.lightGrey, width: 0.5),
              ),
            ),
          ),
        ),
        IconButton(
          icon: _isEditReplyLoading
              ? CupertinoActivityIndicator(
                  radius: 10, // Adjust the radius for size
                )
              : Icon(Icons.send, color: MyColors.primaryLight),
          onPressed: _isEditReplyLoading
              ? null
              : () async {
                  String updatedText = tecReplyEdit.text.trim();
                  if (updatedText.isNotEmpty) {
                    setState(() {
                      _isEditReplyLoading = true; // Start loading
                    });
                    await _updateReply(reply.id!, updatedText);
                    setState(() {
                      _isEditReplyLoading =
                          false; // Stop loading after API call
                    });
                  }
                },
        ),
      ],
    );
  }

  Future<void> _updateReply(String replyId, String updatedText) async {
    if (replyId == null) {
      Utils.showSnackBar(
          message: "Reply ID is missing, cannot update.", isTrue: false);
      return;
    }
    final result = await Get.find<ApiHelper>().updateComment(
      postId: widget.socialPost.id!,
      commentId: replyId,
      newText: updatedText,
    );

    result.fold(
      (CustomError error) {
        Utils.errorDialog(context, error);
      },
      (CommonResponseModel response) {
        setState(() {
          final reply = commentList
              .expand((c) => c.children ?? [])
              .firstWhere((r) => r.id == replyId);
          reply.text = updatedText;
          editingReplyId = null; // Clear editing reply ID
          //activeReplyCommentId = null;
          editingCommentId = null; // Clear editing comment ID
        });
      },
    );
  }

  Future<void> _deleteReply(String replyId) async {
    final result = await Get.find<ApiHelper>().deleteComment(
      postId: widget.socialPost.id!,
      commentId: replyId,
    );

    result.fold(
      (CustomError error) {
        Utils.errorDialog(context, error);
      },
      (CommonResponseModel response) {
        setState(() {
          for (var comment in commentList) {
            comment.children?.removeWhere((r) => r.id == replyId);
          }
        });
      },
    );
  }

  Future<void> _deleteComment(String commentId) async {
    //log("Deleting comment with ID: $commentId on post ID: ${widget.socialPost.id}");

    try {
      final result = await Get.find<ApiHelper>().deleteComment(
        postId: widget.socialPost.id!,
        commentId: commentId,
      );

      result.fold(
        (CustomError error) {
          print("Delete comment failed with error: ${error.msg}");
          Utils.errorDialog(context, error);
        },
        (CommonResponseModel response) {
          print("Delete comment succeeded");
          setState(() {
            commentList.removeWhere((c) => c.id == commentId);
          });
        },
      );
    } catch (e) {
      print("Exception in _deleteComment: $e");
    }
  }

  void _cancelEdit() {
    setState(() {
      editingReplyId = null;

      editingCommentId = null;
    });
  }

  // Method to handle adding a reply
  Future<void> _addReply(Comment parentComment, int parentIndex) async {
    if (tecReply.text.isNotEmpty) {
      String replyText = tecReply.text.trim();
      tecReply.clear();

      // Start loading
      setState(() {
        _isReplyLoading = true;
      });

      // API call to add the reply
      final response = await Get.find<ApiHelper>().addComment(
        socialCommentRequestModel: SocialCommentRequestModel(
          text: replyText,
          postId: widget.socialPost.id ?? "",
          parentId: parentComment.id ?? "",
        ),
      );

      // Stop loading and handle response
      setState(() {
        _isReplyLoading = false;
      });

      response.fold(
        (CustomError error) {
          Utils.errorDialog(context, error);
        },
        (CommentResponseModel response) {
          final currentUser = Get.find<AppController>().user.value;
          Comment replyComment = Comment(
            id: response.comment?.id ?? "",
            text: replyText,
            createdAt: DateTime.now(),
            user: SocialUser(
              id: currentUser.userId,
              name: currentUser.userName,
              profilePicture: Utils.getProfilePicture,
              role: currentUser.userRole,
            ),
          );

          // Add the reply to the comment's children
          setState(() {
            commentList[parentIndex].children?.add(replyComment);
            activeReplyCommentId = null; // Close reply input field
          });
        },
      );
    }
  }

  void _showFollowersFollowingBottomSheet(
      BuildContext context, String title, List<SocialUser> userList) {
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
                            if (userList[index].role?.toLowerCase() ==
                                "client") {
                              if (Get.isRegistered<
                                  IndividualSocialFeedsController>()) {
                                Get.find<IndividualSocialFeedsController>()
                                    .onlyLoadData(userList[index]);
                              } else {
                                Get.toNamed(Routes.individualSocialFeeds,
                                    arguments: userList[index]);
                              }
                            } else {
                              if (Get.isRegistered<
                                  EmployeeDetailsController>()) {
                                Get.find<EmployeeDetailsController>()
                                    .onlyLoadData({
                                  'employeeId': userList[index].id ?? ""
                                });
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
                                      width: 48,
                                      height: 48,
                                    )
                                  : userList[index].role?.toLowerCase() ==
                                          "client"
                                      ? Image.asset(
                                          MyAssets.clientDefault,
                                          fit: BoxFit.cover,
                                          width: 48,
                                          height: 48,
                                        )
                                      : userList[index].role?.toLowerCase() ==
                                              "employee"
                                          ? Image.asset(
                                              MyAssets.employeeDefault,
                                              fit: BoxFit.cover,
                                              width: 48,
                                              height: 48,
                                            )
                                          : Image.asset(
                                              MyAssets.adminDefault,
                                              fit: BoxFit.cover,
                                              width: 48,
                                              height: 48,
                                            ),
                            ),
                          ),
                          title: Text(
                            '${userList[index].name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              if (userList[index].role?.toUpperCase() ==
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
                          ));
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

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:mh/app/common/data/data.dart';
import 'package:pinch_zoom/pinch_zoom.dart';
import '../../modules/client/employee_details/controllers/employee_details_controller.dart';
import '../../modules/common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../modules/common_modules/common_social_feed/views/common_social_feed_view.dart';
import '../../modules/common_modules/live_chat/widgets/copy_able_text_widget.dart';
import '../../modules/common_modules/social_post_details/controllers/social_post_details_controller_temporary_to_reload_reactions.dart';
import '../../modules/employee/employee_home/models/common_response_model.dart';
import 'custom_appbar_back_button.dart';

class SocialPostMediaWidget extends StatefulWidget {
  final SocialPostModel socialPost;
  final void Function() react;
  final bool isSave;
  final void Function() save;
  final void Function() deleteSavePost;
  final Future<void> Function({required RepostRequestModel repostRequestModel})?
      repost;

  final CommonSocialFeedController commonSocialFeedController;

  final int sliderCurrentIndex;

  const SocialPostMediaWidget(
      {super.key,
      required this.socialPost,
      required this.react,
      required this.save,
      this.repost,
      required this.isSave,
      required this.deleteSavePost,
      required this.commonSocialFeedController,
      this.sliderCurrentIndex = 0});

  @override
  State<SocialPostMediaWidget> createState() => _SocialPostWidgetState();
}

class _SocialPostWidgetState extends State<SocialPostMediaWidget> {
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

  int sliderIndex = 0;

  bool _isSave = false;

  @override
  void initState() {
    sliderIndex = widget.sliderCurrentIndex;
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

    _isSave = widget.commonSocialFeedController
        .isPostSaved(widget.socialPost.id.toString());

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

    final CarouselSliderController carouselSliderController =
        CarouselSliderController();
    final isRepost = widget.socialPost.repost != null &&
            widget.socialPost.repost?.active != false
        ? true
        : false;

    return Obx(() => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              GestureDetector(
                onTap:
                    widget.commonSocialFeedController.toggleCaptionVisibility,
                onVerticalDragStart:
                    widget.commonSocialFeedController.onVerticalDragStart,
                onVerticalDragUpdate:
                    widget.commonSocialFeedController.onVerticalDragUpdate,
                onVerticalDragEnd:
                    widget.commonSocialFeedController.onVerticalDragEnd,
                child: SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: Center(
                    child: CarouselSlider.builder(
                      carouselController: carouselSliderController,
                      itemCount: isRepost
                          ? widget.socialPost.repost!.media!.length
                          : widget.socialPost.media!.length,
                      itemBuilder: (context, index, realIndex) {
                        Media media = isRepost
                            ? widget.socialPost.repost!.media![index]
                            : widget.socialPost.media![index];
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
                        initialPage: sliderIndex,
                        height: Get.height,
                        //     160, // Account for AppBar and indicator
                        enableInfiniteScroll: isRepost
                            ? widget.socialPost.repost!.media!.length > 1
                            : widget.socialPost.media!.length > 1,
                        autoPlay: false,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        onPageChanged:
                            (int index, CarouselPageChangedReason reason) {
                          sliderIndex = index;
                        },
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity:
                    widget.commonSocialFeedController.isCaptionVisible.value
                        ? 1.0
                        : 0.0,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 16.w + Get.mediaQuery.padding.top,
                  ),
                  child: isRepost
                      ? _buildRePostPublishersDetails(
                          context,
                          widget.socialPost.repost!,
                          widget.commonSocialFeedController)
                      : _buildPostPublishersDetails(context, widget.socialPost,
                          widget.commonSocialFeedController),
                ),
              ),
              Positioned(
                bottom: 60.h,
                left: 16.w,
                right: 16.w,
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity:
                      widget.commonSocialFeedController.isCaptionVisible.value
                          ? 1.0
                          : 0.0,
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
                              (widget.socialPost.content ?? "").isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SocialCaptionWidget(
                                text: widget.socialPost.content ?? "",
                                textColor: MyColors.c_FFFFFF,
                              ),
                            ),
                          if (isRepost &&
                              (widget.socialPost.repost?.content ?? "")
                                  .isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SocialCaptionWidget(
                                text: widget.socialPost.repost?.content ?? "",
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
                  opacity:
                      widget.commonSocialFeedController.isCaptionVisible.value
                          ? 1.0
                          : 0.0,
                  child: _buildInteraction(context),
                ),
              )
            ],
          ),
        ));
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
              socialPost.user?.name != null &&
                      socialPost.user!.name!.length > 17
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
              socialPost.user?.name != null &&
                      socialPost.user!.name!.length > 17
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

  Widget _buildInteraction(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
      child: Row(
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
                    color:
                        _isLiked ? MyColors.primaryLight : MyColors.c_FFFFFF),
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
              showCommentBottomSheet2(
                  context, "Comments", widget.commonSocialFeedController);
              // if (!Get.find<AppController>().user.value.isAdmin) {
              //   setState(() {
              //     showComment = !showComment;
              //   });
              // }
            },
            child: Row(
              children: [
                Icon(CupertinoIcons.chat_bubble,
                    size: 24.w, color: MyColors.c_FFFFFF),
                SizedBox(width: 10.w),
                Text(
                  "${getTotalCommentCount(comments: commentList)}",
                  style: TextStyle(
                    fontFamily: MyAssets.fontMontserrat,
                    fontSize: 14,
                    color: MyColors.c_FFFFFF,
                  ),
                )
              ],
            ),
          ),
          // SizedBox(width: 12.w),
          // Row(
          //   children: [
          //     Icon(Icons.remove_red_eye_outlined,
          //         size: 24.w, color: MyColors.dividerColor),
          //     SizedBox(width: 10.w),
          //     Text(
          //       "${widget.socialPost.views}",
          //       style: TextStyle(
          //         fontFamily: MyAssets.fontMontserrat,
          //         fontSize: 14,
          //         color: MyColors.dividerColor,
          //       ),
          //     )
          //   ],
          // ),
          Spacer(),
          GestureDetector(
            onTap: () {
              if (!Get.find<AppController>().user.value.isAdmin) {
                setState(() {
                  _isSave = !_isSave;
                });
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
                    _isSave
                        ? CupertinoIcons.bookmark_fill
                        : CupertinoIcons.bookmark,
                    size: 24.w,
                    color: _isSave ? MyColors.primaryLight : MyColors.c_FFFFFF),
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
                      size: 24.w, color: MyColors.c_FFFFFF),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void showCommentBottomSheet2(
      context, String title, CommonSocialFeedController feedController1) {
    showModalBottomSheet(
      context: context!,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 10.h),
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
                  _buildShowComment(context),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShowComment(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
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
                            onTap: () => widget.commonSocialFeedController
                                .seeMediaDetails(widget.socialPost, 0),
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
                  onTap: () => widget.commonSocialFeedController
                      .seeMediaDetails(widget.socialPost, 3),
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
            onTap: () => widget.commonSocialFeedController
                .seeMediaDetails(widget.socialPost, 0),
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
            onTap: () => widget.commonSocialFeedController
                .seeMediaDetails(widget.socialPost, 1),
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
            onTap: () => widget.commonSocialFeedController
                .seeMediaDetails(widget.socialPost, 2),
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
            onTap: () => widget.commonSocialFeedController
                .seeMediaDetails(widget.socialPost, 3),
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
          onTap: () => widget.commonSocialFeedController
              .seeMediaDetails(widget.socialPost, index),
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
              onTap: () => widget.commonSocialFeedController
                  .seeMediaDetails(widget.socialPost, 0),
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
                  onTap: () => widget.commonSocialFeedController
                      .seeMediaDetails(widget.socialPost, 1),
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
                  onTap: () => widget.commonSocialFeedController
                      .seeMediaDetails(widget.socialPost, 2),
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

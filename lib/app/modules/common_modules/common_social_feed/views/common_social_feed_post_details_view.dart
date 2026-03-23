import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../common/data/data.dart';
import '../../../../common/deep_link_service/deep_link_service.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_buttons.dart';
import '../../../../common/widgets/custom_image_widget.dart';
import '../../../../common/widgets/custom_video_widget.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../models/user.dart';
import '../../../../routes/app_pages.dart';
import '../../live_chat/widgets/copy_able_text_widget.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/common_social_feed_controller.dart';
import 'common_social_feed_post_details_view_by_post_id.dart';

class CommonSocialFeedPostDetailsView
    extends GetView<CommonSocialFeedController> {
  const CommonSocialFeedPostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppbar.appbar(
            radius: 0.0,
            title: MyStrings.socialPostDetails.tr,
            context: context,
            onBackButtonPressed: () {
              Get.back();
              controller.showComment(false);
            }),
        body: SingleChildScrollView(
          child: Container(
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
                      // Spacer(),
                      _buildPostMenuButtons(
                          context,
                          controller.socialPostInfo.value,
                          controller.appController.user.value,
                          controller),
                    ],
                  ),
                ),
                if ((controller.socialPostInfo.value.content ?? "")
                    .isNotEmpty) ...[
                  SizedBox(height: 8.w),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                    child: SocialCaptionWidget(
                        text: controller.socialPostInfo.value.content ?? ""),
                  ),
                ],
                SizedBox(
                    height: controller.socialPostInfo.value.repost != null
                        ? 5.w
                        : 20.w),
                if (controller.socialPostInfo.value.repost != null)
                  Padding(
                    padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                    child: _repostWidget(
                        context,
                        controller.socialPostInfo.value.repost!,
                        controller.socialPostInfo.value,
                        controller),
                  ),
                if ((controller.socialPostInfo.value.media ?? []).length == 1)
                  (controller.socialPostInfo.value.media ?? []).first.type ==
                          'image'
                      ? _buildSingleImage(
                          controller.socialPostInfo.value, controller)
                      : _buildSingleVideo(controller.socialPostInfo.value)
                else if ((controller.socialPostInfo.value.media ?? []).isEmpty)
                  const Wrap()
                else
                  SizedBox(
                    height:
                        (controller.socialPostInfo.value.media ?? []).length >=
                                3
                            ? Get.width * 0.95
                            : 200.w,
                    child:
                        (controller.socialPostInfo.value.media ?? []).length ==
                                3
                            ? _buildOnlyThreeItems(
                                (controller.socialPostInfo.value.media ?? [])
                                    .take(4)
                                    .toList(),
                                controller.socialPostInfo.value,
                                controller)
                            : _buildMoreThanThreeView(
                                (controller.socialPostInfo.value.media ?? [])
                                    .take(4)
                                    .toList(),
                                (controller.socialPostInfo.value.media ?? [])
                                    .length,
                                controller.socialPostInfo.value,
                                controller),
                  ),
                // _buildInteractionCount(
                //     context,
                //     controller.socialPostInfo.value,
                //     controller.appController.user.value.userId,
                //     controller,
                //     controller.selectedIndex.value),
                SizedBox(height: 10.h),
                _buildInteraction(
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
                Obx(
                  () => controller.selectedIndex.value ==
                              controller.selectedIndex.value &&
                          controller.showComment.value
                      ? controller.isCommentLoading.value
                          ? Padding(
                              padding:
                                  EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                              child: Column(
                                children: [
                                  SizedBox(height: 15.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: SizedBox(
                                          height: 40,
                                          child: _buildCommentTextField(
                                              context, controller),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      _buildCommentButton(context, controller)
                                    ],
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    // reverse: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: (controller.socialPostInfo.value
                                                .comments ??
                                            [])
                                        .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Comment c = (controller
                                              .socialPostInfo.value.comments ??
                                          [])[index];
                                      Comment comment = c;

                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: _buildComentsListTitle(
                                                c, context),
                                            leading: controller.editingCommentId
                                                            .value ==
                                                        comment.id &&
                                                    controller.editingReplyId
                                                            .value ==
                                                        ''
                                                ? GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .onTapCancelCommentEditing();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () => c.user?.role
                                                                ?.toLowerCase() ==
                                                            "client"
                                                        ? Get.toNamed(
                                                            Routes
                                                                .individualSocialFeeds,
                                                            arguments: c.user)
                                                        : Get.toNamed(
                                                            Routes
                                                                .employeeDetails,
                                                            arguments: {
                                                                'employeeId': c
                                                                        .user
                                                                        ?.id ??
                                                                    ""
                                                              }),
                                                    child: CircleAvatar(
                                                      backgroundImage: ((c.user
                                                                          ?.profilePicture ??
                                                                      "")
                                                                  .isEmpty ||
                                                              c.user?.profilePicture ==
                                                                  "undefined")
                                                          ? AssetImage(c.user
                                                                      ?.role
                                                                      ?.toUpperCase() ==
                                                                  "ADMIN"
                                                              ? MyAssets
                                                                  .adminDefault
                                                              : c.user?.role
                                                                          ?.toUpperCase() ==
                                                                      "CLIENT"
                                                                  ? MyAssets
                                                                      .clientDefault
                                                                  : MyAssets
                                                                      .employeeDefault)
                                                          : NetworkImage((c.user
                                                                      ?.profilePicture ??
                                                                  "")
                                                              .socialMediaUrl),
                                                    ),
                                                  ),
                                            subtitle: controller
                                                            .editingCommentId
                                                            .value ==
                                                        comment.id &&
                                                    controller.editingReplyId
                                                            .value ==
                                                        ''
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller: controller
                                                              .commentEditTextController,
                                                          maxLines: null,
                                                          minLines: 1,
                                                          style: MyColors
                                                                  .l111111_dwhite(
                                                                      context)
                                                              .medium13,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10.0.w),
                                                            // hintText: MyStrings.editCommentHint.tr,
                                                            fillColor: MyColors
                                                                .noColor,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide: BorderSide(
                                                                  color: MyColors
                                                                      .lightGrey,
                                                                  width: 0.5),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: controller
                                                                .isEditCommentLoading
                                                                .value
                                                            ? CupertinoActivityIndicator(
                                                                radius:
                                                                    10, // Adjust the radius for size
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .send_outlined,
                                                                color: MyColors
                                                                    .primaryLight),
                                                        onPressed: controller
                                                                .isEditCommentLoading
                                                                .value
                                                            ? null
                                                            : () async {
                                                                controller.updateExistingComment(
                                                                    controller
                                                                        .socialPostInfo
                                                                        .value
                                                                        .id!,
                                                                    controller
                                                                        .editingCommentId
                                                                        .value);
                                                              },
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CopyableTextWidget(
                                                        text: c.text ?? "",
                                                        textStyle: TextStyle(
                                                          fontFamily: MyAssets
                                                              .fontMontserrat,
                                                          color: MyColors
                                                              .l111111_dwhite(
                                                                  context),
                                                        ),
                                                        textColor: MyColors
                                                            .l111111_dwhite(
                                                                context),
                                                        linkColor: Colors.blue,
                                                      ),
                                                      // Text(
                                                      //   c.text ?? "",
                                                      //   style: TextStyle(
                                                      //     fontFamily: MyAssets
                                                      //         .fontMontserrat,
                                                      //     color: MyColors
                                                      //         .l111111_dwhite(
                                                      //             context),
                                                      //   ),
                                                      // ),
                                                      SizedBox(height: 5.w),
                                                      GestureDetector(
                                                        onTap: () {
                                                          controller
                                                              .showCommentReplyInputField(
                                                                  c);
                                                        },
                                                        child: Text(
                                                          MyStrings.reply.tr,
                                                          style: TextStyle(
                                                            fontFamily: MyAssets
                                                                .fontMontserrat,
                                                            color: MyColors
                                                                .lightGrey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            trailing: comment.user?.id ==
                                                    controller.appController
                                                        .user.value.userId
                                                ? PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        controller
                                                            .isCommentLoading
                                                            .value = true;
                                                        controller
                                                            .editingReplyId
                                                            .value = '';
                                                        controller
                                                                .editingCommentId
                                                                .value =
                                                            comment.id
                                                                .toString();
                                                        controller
                                                            .commentEditTextController
                                                            .text = comment
                                                                .text ??
                                                            "";
                                                        controller
                                                            .isCommentLoading
                                                            .value = false;
                                                      } else if (value ==
                                                          'delete') {
                                                        controller.deleteComment(
                                                            controller
                                                                .socialPostInfo
                                                                .value
                                                                .id!,
                                                            comment.id!);
                                                      }
                                                    },
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit,
                                                                color: MyColors
                                                                    .primaryLight),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Edit",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      MyAssets
                                                                          .fontMontserrat),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete,
                                                                color:
                                                                    Colors.red),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      MyAssets
                                                                          .fontMontserrat),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                          ),
                                          if ((c.children ?? []).isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 30.0.w),
                                              child: ListView.builder(
                                                itemCount:
                                                    (c.children ?? []).length,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  Comment reply =
                                                      (c.children ?? [])[index];
                                                  return ListTile(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0.0),
                                                    title: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () => reply
                                                                      .user
                                                                      ?.role
                                                                      ?.toLowerCase() ==
                                                                  "client"
                                                              ? Get.toNamed(
                                                                  Routes
                                                                      .individualSocialFeeds,
                                                                  arguments:
                                                                      reply
                                                                          .user)
                                                              : Get.toNamed(
                                                                  Routes
                                                                      .employeeDetails,
                                                                  arguments: {
                                                                      'employeeId':
                                                                          reply.user?.id ??
                                                                              ""
                                                                    }),
                                                          child: Text(
                                                            reply.user?.name !=
                                                                        null &&
                                                                    reply
                                                                            .user!
                                                                            .name!
                                                                            .length >
                                                                        12
                                                                ? Utils.truncateCharacters(
                                                                    reply.user!
                                                                            .name ??
                                                                        '',
                                                                    12)
                                                                : reply.user
                                                                        ?.name ??
                                                                    '',
                                                            style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 13,
                                                              color: MyColors
                                                                  .l111111_dwhite(
                                                                      context),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        CircleAvatar(
                                                          radius: 1.5,
                                                          backgroundColor:
                                                              MyColors
                                                                  .l111111_dwhite(
                                                                      context),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Text(
                                                          Utils.formatDateTime(
                                                              reply.createdAt ??
                                                                  DateTime
                                                                      .now(),
                                                              socialFeed: true),
                                                          style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .lightGrey),
                                                        ),
                                                      ],
                                                    ),
                                                    leading: controller
                                                                .editingReplyId
                                                                .value ==
                                                            reply.id
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              controller
                                                                  .onTapCancelCommentEditing();
                                                            },
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ))
                                                        : GestureDetector(
                                                            onTap: () => reply
                                                                        .user
                                                                        ?.role
                                                                        ?.toLowerCase() ==
                                                                    "client"
                                                                ? Get.toNamed(
                                                                    Routes
                                                                        .individualSocialFeeds,
                                                                    arguments:
                                                                        reply
                                                                            .user)
                                                                : Get.toNamed(
                                                                    Routes
                                                                        .employeeDetails,
                                                                    arguments: {
                                                                        'employeeId':
                                                                            reply.user?.id ??
                                                                                ""
                                                                      }),
                                                            child: CircleAvatar(
                                                              backgroundImage: ((reply.user?.profilePicture ??
                                                                              "")
                                                                          .isEmpty ||
                                                                      reply.user
                                                                              ?.profilePicture ==
                                                                          "undefined")
                                                                  ? AssetImage(reply
                                                                              .user?.role
                                                                              ?.toUpperCase() ==
                                                                          "ADMIN"
                                                                      ? MyAssets
                                                                          .adminDefault
                                                                      : reply.user?.role?.toUpperCase() ==
                                                                              "CLIENT"
                                                                          ? MyAssets
                                                                              .clientDefault
                                                                          : MyAssets
                                                                              .employeeDefault)
                                                                  : NetworkImage(
                                                                      (reply.user?.profilePicture ??
                                                                              "")
                                                                          .socialMediaUrl),
                                                            ),
                                                          ),
                                                    subtitle: controller
                                                                .editingReplyId
                                                                .value ==
                                                            reply.id
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      controller
                                                                          .commentReplyEditTextController,
                                                                  maxLines:
                                                                      null,
                                                                  minLines: 1,
                                                                  style: MyColors
                                                                          .l111111_dwhite(
                                                                              context)
                                                                      .medium13,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                            10.0.w),
                                                                    fillColor:
                                                                        MyColors
                                                                            .noColor,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      borderSide: BorderSide(
                                                                          color: MyColors
                                                                              .lightGrey,
                                                                          width:
                                                                              0.5),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: controller
                                                                        .isReplyLoading
                                                                        .value
                                                                    ? CupertinoActivityIndicator(
                                                                        radius:
                                                                            10, // Adjust the radius for size
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .send,
                                                                        color: MyColors
                                                                            .primaryLight),
                                                                onPressed: controller
                                                                        .isReplyLoading
                                                                        .value
                                                                    ? null
                                                                    : () async {
                                                                        controller.updateCommentReply(
                                                                            controller.socialPostInfo.value.id,
                                                                            c.id,
                                                                            reply.id);
                                                                      },
                                                              ),
                                                            ],
                                                          ) // Show editable field if in edit mode
                                                        : CopyableTextWidget(
                                                            text: reply.text ??
                                                                "",
                                                            textStyle:
                                                                TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .lightGrey,
                                                            ),
                                                            textColor: MyColors
                                                                .lightGrey,
                                                            linkColor:
                                                                Colors.blue,
                                                          ),
                                                    // Text(
                                                    //         reply.text ?? "",
                                                    //         style: TextStyle(
                                                    //           fontFamily: MyAssets
                                                    //               .fontMontserrat,
                                                    //           color: MyColors
                                                    //               .lightGrey,
                                                    //         ),
                                                    //       ),
                                                    trailing: reply.user?.id ==
                                                            controller
                                                                .appController
                                                                .user
                                                                .value
                                                                .userId
                                                        ? PopupMenuButton<
                                                            String>(
                                                            onSelected:
                                                                (value) {
                                                              if (value ==
                                                                  'edit') {
                                                              } else if (value ==
                                                                  'delete') {
                                                                controller.deleteCommentReply(
                                                                    controller
                                                                        .socialPostInfo
                                                                        .value
                                                                        .id!,
                                                                    c.id!,
                                                                    reply.id!);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context) =>
                                                                    [
                                                              PopupMenuItem(
                                                                value: 'edit',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: MyColors
                                                                            .primaryLight),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                        "Edit"),
                                                                  ],
                                                                ),
                                                              ),
                                                              PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                        "Delete"),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : null,
                                                  );
                                                },
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                              ),
                                            )
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding:
                                  EdgeInsets.only(left: 15.0.w, right: 15.0.w),
                              child: Column(
                                children: [
                                  SizedBox(height: 15.h),
                                  if (!controller
                                      .appController.user.value.isAdmin)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 10,
                                          child: SizedBox(
                                            height: 40,
                                            child: _buildCommentTextField(
                                                context, controller),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        _buildCommentButton(context, controller)
                                      ],
                                    ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: EdgeInsets.zero,
                                    // reverse: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: (controller.socialPostInfo.value
                                                .comments ??
                                            [])
                                        .length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      Comment c = (controller
                                              .socialPostInfo.value.comments ??
                                          [])[index];
                                      Comment comment = c;

                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: _buildComentsListTitle(
                                                c, context),
                                            leading: controller.editingCommentId
                                                            .value ==
                                                        comment.id &&
                                                    controller.editingReplyId
                                                            .value ==
                                                        ''
                                                ? GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .onTapCancelCommentEditing();
                                                    },
                                                    child: Icon(
                                                      Icons.close,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () => c.user?.role
                                                                ?.toLowerCase() ==
                                                            "client"
                                                        ? Get.toNamed(
                                                            Routes
                                                                .individualSocialFeeds,
                                                            arguments: c.user)
                                                        : Get.toNamed(
                                                            Routes
                                                                .employeeDetails,
                                                            arguments: {
                                                                'employeeId': c
                                                                        .user
                                                                        ?.id ??
                                                                    ""
                                                              }),
                                                    child: CircleAvatar(
                                                      backgroundImage: ((c.user
                                                                          ?.profilePicture ??
                                                                      "")
                                                                  .isEmpty ||
                                                              c.user?.profilePicture ==
                                                                  "undefined")
                                                          ? AssetImage(c.user
                                                                      ?.role
                                                                      ?.toUpperCase() ==
                                                                  "ADMIN"
                                                              ? MyAssets
                                                                  .adminDefault
                                                              : c.user?.role
                                                                          ?.toUpperCase() ==
                                                                      "CLIENT"
                                                                  ? MyAssets
                                                                      .clientDefault
                                                                  : MyAssets
                                                                      .employeeDefault)
                                                          : NetworkImage((c.user
                                                                      ?.profilePicture ??
                                                                  "")
                                                              .socialMediaUrl),
                                                    ),
                                                  ),
                                            subtitle: controller
                                                            .editingCommentId
                                                            .value ==
                                                        comment.id &&
                                                    controller.editingReplyId
                                                            .value ==
                                                        ''
                                                ? Row(
                                                    children: [
                                                      Expanded(
                                                        child: TextField(
                                                          controller: controller
                                                              .commentEditTextController,
                                                          maxLines: null,
                                                          minLines: 1,
                                                          style: MyColors
                                                                  .l111111_dwhite(
                                                                      context)
                                                              .medium13,
                                                          decoration:
                                                              InputDecoration(
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10.0.w),
                                                            // hintText: MyStrings.editCommentHint.tr,
                                                            fillColor: MyColors
                                                                .noColor,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10.0),
                                                              borderSide: BorderSide(
                                                                  color: MyColors
                                                                      .lightGrey,
                                                                  width: 0.5),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: controller
                                                                .isEditCommentLoading
                                                                .value
                                                            ? CupertinoActivityIndicator(
                                                                radius:
                                                                    10, // Adjust the radius for size
                                                              )
                                                            : Icon(
                                                                Icons
                                                                    .send_outlined,
                                                                color: MyColors
                                                                    .primaryLight),
                                                        onPressed: controller
                                                                .isEditCommentLoading
                                                                .value
                                                            ? null
                                                            : () async {
                                                                controller.updateExistingComment(
                                                                    controller
                                                                        .socialPostInfo
                                                                        .value
                                                                        .id!,
                                                                    controller
                                                                        .editingCommentId
                                                                        .value);
                                                              },
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      CopyableTextWidget(
                                                        text: c.text ?? "",
                                                        textStyle: TextStyle(
                                                          fontFamily: MyAssets
                                                              .fontMontserrat,
                                                          color: MyColors
                                                              .l111111_dwhite(
                                                                  context),
                                                        ),
                                                        textColor: MyColors
                                                            .l111111_dwhite(
                                                                context),
                                                        linkColor: Colors.blue,
                                                      ),
                                                      // Text(
                                                      //   c.text ?? "",
                                                      //   style: TextStyle(
                                                      //     fontFamily: MyAssets
                                                      //         .fontMontserrat,
                                                      //     color: MyColors
                                                      //         .l111111_dwhite(
                                                      //             context),
                                                      //   ),
                                                      // ),
                                                      SizedBox(height: 5.w),
                                                      if (!controller
                                                          .appController
                                                          .user
                                                          .value
                                                          .isAdmin)
                                                        GestureDetector(
                                                          onTap: () {
                                                            controller
                                                                .showCommentReplyInputField(
                                                                    c);
                                                          },
                                                          child: Text(
                                                            MyStrings.reply.tr,
                                                            style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              color: MyColors
                                                                  .lightGrey,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                            trailing: comment.user?.id ==
                                                    controller.appController
                                                        .user.value.userId
                                                ? PopupMenuButton<String>(
                                                    onSelected: (value) {
                                                      if (value == 'edit') {
                                                        controller
                                                            .isCommentLoading
                                                            .value = true;
                                                        controller
                                                            .editingReplyId
                                                            .value = '';
                                                        controller
                                                                .editingCommentId
                                                                .value =
                                                            comment.id
                                                                .toString();
                                                        controller
                                                            .commentEditTextController
                                                            .text = comment
                                                                .text ??
                                                            "";
                                                        controller
                                                            .isCommentLoading
                                                            .value = false;
                                                      } else if (value ==
                                                          'delete') {
                                                        controller.deleteComment(
                                                            controller
                                                                .socialPostInfo
                                                                .value
                                                                .id!,
                                                            comment.id!);
                                                      }
                                                    },
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        [
                                                      PopupMenuItem(
                                                        value: 'edit',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.edit,
                                                                color: MyColors
                                                                    .primaryLight),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Edit",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      MyAssets
                                                                          .fontMontserrat),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete,
                                                                color:
                                                                    Colors.red),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      MyAssets
                                                                          .fontMontserrat),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : null,
                                          ),
                                          if (controller
                                                  .activeReplyCommentId.value ==
                                              c.id)
                                            Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      controller
                                                          .isCommentLoading
                                                          .value = true;
                                                      controller
                                                          .activeReplyCommentId
                                                          .value = '';
                                                      controller
                                                          .isCommentLoading
                                                          .value = false;
                                                    },
                                                    child: Icon(Icons.clear,
                                                        color: Colors.red,
                                                        size: 15),
                                                  ),
                                                ),
                                                Expanded(
                                                    flex: 5,
                                                    child: SizedBox(
                                                      height: 40,
                                                      child: TextField(
                                                        maxLines: null,
                                                        minLines: 1,
                                                        controller: controller
                                                            .commentReplyEditTextController,
                                                        style: MyColors
                                                                .l111111_dwhite(
                                                                    context)
                                                            .medium13,
                                                        decoration: InputDecoration(
                                                            contentPadding: EdgeInsets.all(
                                                                10.0.w),
                                                            filled: true,
                                                            hintText: MyStrings
                                                                .writeAReply.tr,
                                                            hintStyle: MyColors
                                                                .lightGrey
                                                                .medium13,
                                                            fillColor: MyColors
                                                                .noColor,
                                                            border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(
                                                                    10.0),
                                                                borderSide: const BorderSide(
                                                                    width: 0.05,
                                                                    color: MyColors
                                                                        .lightGrey)),
                                                            focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(10.0),
                                                                borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)),
                                                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey))),
                                                      ),
                                                    )),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  flex: 1,
                                                  child: GestureDetector(
                                                    onTap: controller
                                                            .isReplyLoading
                                                            .value
                                                        ? null
                                                        : () {
                                                            controller.addReply(
                                                                c, index);
                                                          },
                                                    child: controller
                                                            .isReplyLoading
                                                            .value
                                                        ? CupertinoActivityIndicator(
                                                            radius:
                                                                10, // Adjust the radius for size
                                                          ) // Show loading if true
                                                        : const Icon(
                                                            Icons.send_outlined,
                                                            color: MyColors
                                                                .primaryLight),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if ((c.children ?? []).isNotEmpty)
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 30.0.w),
                                              child: ListView.builder(
                                                itemCount:
                                                    (c.children ?? []).length,
                                                padding: EdgeInsets.zero,
                                                itemBuilder: (context, index) {
                                                  Comment reply =
                                                      (c.children ?? [])[index];
                                                  return ListTile(
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0.0),
                                                    title: Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () => reply
                                                                      .user
                                                                      ?.role
                                                                      ?.toLowerCase() ==
                                                                  "client"
                                                              ? Get.toNamed(
                                                                  Routes
                                                                      .individualSocialFeeds,
                                                                  arguments:
                                                                      reply
                                                                          .user)
                                                              : Get.toNamed(
                                                                  Routes
                                                                      .employeeDetails,
                                                                  arguments: {
                                                                      'employeeId':
                                                                          reply.user?.id ??
                                                                              ""
                                                                    }),
                                                          child: Text(
                                                            reply.user?.name !=
                                                                        null &&
                                                                    reply
                                                                            .user!
                                                                            .name!
                                                                            .length >
                                                                        12
                                                                ? Utils.truncateCharacters(
                                                                    reply.user!
                                                                            .name ??
                                                                        '',
                                                                    12)
                                                                : reply.user
                                                                        ?.name ??
                                                                    '',
                                                            style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: MyColors
                                                                  .l111111_dwhite(
                                                                      context),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        CircleAvatar(
                                                          radius: 1.5,
                                                          backgroundColor:
                                                              MyColors
                                                                  .l111111_dwhite(
                                                                      context),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Text(
                                                          Utils.formatDateTime(
                                                              reply.createdAt ??
                                                                  DateTime
                                                                      .now(),
                                                              socialFeed: true),
                                                          style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .lightGrey),
                                                        ),
                                                      ],
                                                    ),
                                                    leading: controller
                                                                .editingReplyId
                                                                .value ==
                                                            reply.id
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              controller
                                                                  .onTapCancelCommentEditing();
                                                            },
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.red,
                                                            ))
                                                        : GestureDetector(
                                                            onTap: () => reply
                                                                        .user
                                                                        ?.role
                                                                        ?.toLowerCase() ==
                                                                    "client"
                                                                ? Get.toNamed(
                                                                    Routes
                                                                        .individualSocialFeeds,
                                                                    arguments:
                                                                        reply
                                                                            .user)
                                                                : Get.toNamed(
                                                                    Routes
                                                                        .employeeDetails,
                                                                    arguments: {
                                                                        'employeeId':
                                                                            reply.user?.id ??
                                                                                ""
                                                                      }),
                                                            child: CircleAvatar(
                                                              backgroundImage: ((reply.user?.profilePicture ??
                                                                              "")
                                                                          .isEmpty ||
                                                                      reply.user
                                                                              ?.profilePicture ==
                                                                          "undefined")
                                                                  ? AssetImage(reply
                                                                              .user?.role
                                                                              ?.toUpperCase() ==
                                                                          "ADMIN"
                                                                      ? MyAssets
                                                                          .adminDefault
                                                                      : reply.user?.role?.toUpperCase() ==
                                                                              "CLIENT"
                                                                          ? MyAssets
                                                                              .clientDefault
                                                                          : MyAssets
                                                                              .employeeDefault)
                                                                  : NetworkImage(
                                                                      (reply.user?.profilePicture ??
                                                                              "")
                                                                          .socialMediaUrl),
                                                            ),
                                                          ),
                                                    subtitle: controller
                                                                .editingReplyId
                                                                .value ==
                                                            reply.id
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      controller
                                                                          .commentReplyEditTextController,
                                                                  maxLines:
                                                                      null,
                                                                  minLines: 1,
                                                                  style: MyColors
                                                                          .l111111_dwhite(
                                                                              context)
                                                                      .medium13,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                            10.0.w),
                                                                    fillColor:
                                                                        MyColors
                                                                            .noColor,
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      borderSide: BorderSide(
                                                                          color: MyColors
                                                                              .lightGrey,
                                                                          width:
                                                                              0.5),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon: controller
                                                                        .isReplyLoading
                                                                        .value
                                                                    ? CupertinoActivityIndicator(
                                                                        radius:
                                                                            10, // Adjust the radius for size
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .send,
                                                                        color: MyColors
                                                                            .primaryLight),
                                                                onPressed: controller
                                                                        .isReplyLoading
                                                                        .value
                                                                    ? null
                                                                    : () async {
                                                                        controller.updateCommentReply(
                                                                            controller.socialPostInfo.value.id,
                                                                            c.id,
                                                                            reply.id);
                                                                      },
                                                              ),
                                                            ],
                                                          ) // Show editable field if in edit mode
                                                        : CopyableTextWidget(
                                                            text: reply.text ??
                                                                "",
                                                            textStyle:
                                                                TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .lightGrey,
                                                            ),
                                                            textColor: MyColors
                                                                .lightGrey,
                                                            linkColor:
                                                                Colors.blue,
                                                          ),
                                                    // Text(
                                                    //         reply.text ?? "",
                                                    //         style: TextStyle(
                                                    //           fontFamily: MyAssets
                                                    //               .fontMontserrat,
                                                    //           fontSize: 12,
                                                    //           color: MyColors
                                                    //               .lightGrey,
                                                    //         ),
                                                    //       ),
                                                    trailing: reply.user?.id ==
                                                            controller
                                                                .appController
                                                                .user
                                                                .value
                                                                .userId
                                                        ? PopupMenuButton<
                                                            String>(
                                                            onSelected:
                                                                (value) {
                                                              if (value ==
                                                                  'edit') {
                                                                controller
                                                                    .startEditingReply(
                                                                        c.id!,
                                                                        reply);
                                                              } else if (value ==
                                                                  'delete') {
                                                                controller.deleteCommentReply(
                                                                    controller
                                                                        .socialPostInfo
                                                                        .value
                                                                        .id!,
                                                                    c.id!,
                                                                    reply.id!);
                                                              }
                                                            },
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context) =>
                                                                    [
                                                              PopupMenuItem(
                                                                value: 'edit',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        color: MyColors
                                                                            .primaryLight),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      "Edit",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              MyAssets.fontMontserrat),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              PopupMenuItem(
                                                                value: 'delete',
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      "Delete",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                              MyAssets.fontMontserrat),
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
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                              ),
                                            )
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildPostPublishersDetails(
    BuildContext context, SocialPostModel socialPost) {
  return Expanded(
    child: GestureDetector(
      onTap: () => socialPost.user?.role?.toLowerCase() == "client"
          ? Get.toNamed(Routes.individualSocialFeeds,
              arguments: socialPost.user)
          : Get.toNamed(Routes.employeeDetails,
              arguments: {'employeeId': socialPost.user?.id ?? ""}),
      child: Row(
        children: [
          CircleAvatar(
              radius: 18,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  socialPost.user?.name != null &&
                          socialPost.user!.name!.length > 17
                      ? Utils.truncateCharacters(
                          socialPost.user!.name ?? '', 17)
                      : socialPost.user?.name ?? '',
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
                          socialPost.user!.countryName.toString()),
                      width: 10,
                      height: 10,
                    ),
                    if (socialPost.user?.role?.toUpperCase() != "CLIENT" &&
                        socialPost.user?.role?.toUpperCase() != "ADMIN")
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: CircleAvatar(
                          radius: 1.5,
                          backgroundColor: MyColors.l111111_dwhite(context),
                        ),
                      ),
                    if (socialPost.user?.role?.toUpperCase() != "CLIENT" &&
                        socialPost.user?.role?.toUpperCase() != "ADMIN")
                      Text(
                        socialPost.user?.positionName ?? "",
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
                    socialPost.active != null && socialPost.active!
                        ? Text(
                            Utils.formatDateTime(
                              socialFeed: true,
                              socialPost.createdAt ?? DateTime.now(),
                            ),
                            style: TextStyle(
                                fontFamily: MyAssets.fontMontserrat,
                                fontSize: 11,
                                color: MyColors.lightGrey),
                          )
                        : Text(
                            "HOLD",
                            style: TextStyle(
                                fontFamily: MyAssets.fontMontserrat,
                                fontSize: 11,
                                color: MyColors.lightGrey),
                          ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

PopupMenuButton<int> _buildPostMenuButtons(
    BuildContext context,
    SocialPostModel socialPost,
    User appUser,
    CommonSocialFeedController controller) {
  return PopupMenuButton<int>(
    color: MyColors.lightCard(context),
    icon: Image.asset(MyAssets.socialMenu, height: 4, color: MyColors.c_9A9A9A),
    onSelected: (int result) async {
      // Handle the selected menu item
      if (result == 0) {
        Get.toNamed(Routes.updatePost, arguments: [socialPost]);
      } else if (result == 1) {
        controller.activeInActivePost(
            context: context,
            postId: socialPost.id ?? "",
            active: !(socialPost.active!));
      } else if (result == 2) {
        controller.deletePost(postId: socialPost.id ?? "", context: context);
      } else if (result == 3) {
        controller.followUnfollowUser(socialPost.user?.id ?? '');
      } else if (result == 4) {
        controller.blockUser(
            userId: socialPost.user?.id ?? '', context: context);
      } else if (result == 5) {
        appUser.isAdmin
            ? null
            : _showReport(
                postId: socialPost.id ?? '',
                context: context,
                controller: controller);
      } else if (result == 6) {
        Share.share(DeepLinkService.generateAppLink(
            'social-post_details', {'id': socialPost.id ?? ''}));
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
      if (socialPost.user?.id == appUser.userId)
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
      if (socialPost.user?.id == appUser.userId || appUser.isAdmin)
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            socialPost.active != null && socialPost.active!
                ? MyStrings.inactive.tr
                : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id == appUser.userId || appUser.isAdmin)
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
      if (socialPost.user?.id != appUser.userId && !appUser.isAdmin)
        PopupMenuItem<int>(
          value: 3,
          child: Text(
            controller.appController.isFollowing(socialPost.user?.id ?? '')
                ? MyStrings.following.tr
                : MyStrings.follow.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      if (socialPost.user?.id != appUser.userId && !appUser.isAdmin)
        PopupMenuItem<int>(
          value: 4,
          child: Text(
            'Block',
            // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          ),
        ),
      PopupMenuItem(
          value: 5,
          child: Text(
            'Report',
            // isActive ? MyStrings.inactive.tr : MyStrings.active.tr,
            style: TextStyle(
                fontFamily: MyAssets.fontMontserrat,
                fontSize: 13,
                color: MyColors.l111111_dwhite(context)),
          )),
      PopupMenuItem(
          value: 6,
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
        Container(
          height: Get.width * 0.5,
          child: GestureDetector(
            onTap: () => controller.seeMediaDetails(socialPost, 0),
            // onTap: () => Get.to(
            //   () => MediaViewAllWidget(
            //     index: 0,
            //     mediaList: (repost.media ?? []),
            //   ),
            // ),
            child: (repost.media ?? [])[0].type == 'video'
                ? Center(
                    child: Image.asset(
                      MyAssets.videoThumbnail,
                      fit: BoxFit.cover, height: Get.width * 0.5,
                      width: Get.width,
                      // width: Get.width,
                    ),
                  )
                : _buildMediaWidget(
                    hasAspect: false,
                    post: visibleMedia[0],
                    height: Get.width * 0.5,
                  ),
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
                child: (repost.media ?? [])[1].type == 'video'
                    ? Center(
                        child: Image.asset(
                          MyAssets.videoThumbnail,
                          fit: BoxFit.cover, height: Get.width * 0.35,
                          // width: Get.width,
                        ),
                      )
                    : _buildMediaWidget(
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
                child: (repost.media ?? [])[2].type == 'video'
                    ? Center(
                        child: Image.asset(
                          MyAssets.videoThumbnail,
                          fit: BoxFit.cover,
                          height: Get.width * 0.35,
                          // width: Get.width,
                        ),
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
            (repost.media ?? [])[3].type == 'video'
                ? thumbImageWidget(
                    url:
                        (repost.media ?? [])[3].thumbnail?.socialMediaUrl ?? '',
                    height: Get.height,
                  )
                : _buildMediaWidget(
                    post: post,
                    height: Get.height,
                  ),
            // Overlay the count of additional items on the 4th media
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 3),
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
          onTap: () => controller.seeMediaDetails(socialPost, 0),
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
          onTap: () => controller.seeMediaDetails(socialPost, 1),
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
          onTap: () => controller.seeMediaDetails(socialPost, 2),
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
          onTap: () => controller.seeMediaDetails(socialPost, 3),
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
        onTap: () => controller.seeMediaDetails(socialPost, index),
        // onTap: () => Get.to(() => MediaViewAllWidget(
        //     index: 0, mediaList: (widget.socialPost.media ?? []))),
        child: _buildMediaWidget(post: post, height: Get.height),
      );
    }).toList(),
  );
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
            (socialPost.media ?? [])[3].type == 'video'
                ? thumbImageWidget(
                    url:
                        (socialPost.media ?? [])[3].thumbnail?.socialMediaUrl ??
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
                onTap: () => controller.seeMediaDetails(socialPost, 3),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 3,
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

      if (index == 0 && (socialPost.media ?? [])[0].type == 'video') {
        return GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 0),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 0, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
            url: (socialPost.media ?? [])[0].thumbnail?.socialMediaUrl ?? '',
            height: Get.height,
          ),
        );
      }
      if (index == 1 && (socialPost.media ?? [])[1].type == 'video') {
        return GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 1),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 1, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
            url: (socialPost.media ?? [])[1].thumbnail?.socialMediaUrl ?? '',
            height: Get.height,
          ),
        );
      }
      if (index == 2 && (socialPost.media ?? [])[2].type == 'video') {
        return GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 2),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 2, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
            url: (socialPost.media ?? [])[2].thumbnail?.socialMediaUrl ?? '',
            height: Get.height,
          ),
        );
      }
      if (index == 3 && (socialPost.media ?? [])[3].type == 'video') {
        return GestureDetector(
          onTap: () => controller.seeMediaDetails(socialPost, 3),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 3, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
            url: (socialPost.media ?? [])[3].thumbnail?.socialMediaUrl ?? '',
            height: Get.height,
          ),
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
        Container(
          height: Get.width * 0.5,
          child: GestureDetector(
            onTap: () => controller.seeMediaDetails(socialPost, 0),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 0, mediaList: (socialPost.media ?? []))),
            child: (socialPost.media ?? [])[0].type == 'video'
                ? thumbImageWidget(
                    url:
                        (socialPost.media ?? [])[0].thumbnail?.socialMediaUrl ??
                            '',
                    height: Get.width * 0.5,
                  )
                : _buildMediaWidget(
                    post: visibleMedia[0], height: Get.width * 0.5),
          ),
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
                child: (socialPost.media ?? [])[1].type == 'video'
                    ? thumbImageWidget(
                        url: (socialPost.media ?? [])[1]
                                .thumbnail
                                ?.socialMediaUrl ??
                            '',
                        height: Get.width * 0.35,
                      )
                    : _buildMediaWidget(
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
                child: (socialPost.media ?? [])[2].type == 'video'
                    ? thumbImageWidget(
                        url: (socialPost.media ?? [])[2]
                                .thumbnail
                                ?.socialMediaUrl ??
                            '',
                        height: Get.width * 0.35,
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

Widget _buildInteractionCount(BuildContext context, SocialPostModel socialPost,
    String appUserId, CommonSocialFeedController controller, int index) {
  return Obx(() => Padding(
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
            controller.selectedIndex.value == index &&
                    controller.isCommentLoading.value
                ? Text(
                    socialPost.comments!.isEmpty
                        ? ""
                        : "${controller.getTotalCommentCount(comments: socialPost.comments!)} comments",
                    style: TextStyle(
                      fontFamily: MyAssets.fontMontserrat,
                      fontSize: 12,
                      color: MyColors.dividerColor,
                    ),
                  )
                : Text(
                    socialPost.comments!.isEmpty
                        ? ""
                        : "${controller.getTotalCommentCount(comments: socialPost.comments!)} comments",
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
      ));
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
  return Obx(() => Padding(
        padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
        child: Row(
          // mainAxisAlignment: (socialPost.repost != null)
          //     ? MainAxisAlignment.spaceAround
          //     : MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () {
                    appUser.isAdmin ? null : react();
                  },
                  onLongPress: () {
                    controller.getSocialPostInfoByPostId(
                        context, socialPost.id);
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
                              : MyColors.dividerColor),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () {
                    controller.getSocialPostInfoByPostId(
                        context, socialPost.id);
                  },
                  child: Text(
                    "${socialPost.likes?.length}",
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
              onTap: () {},
              child: Row(
                children: [
                  Icon(CupertinoIcons.chat_bubble,
                      size: 24.w, color: MyColors.dividerColor),
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
                            color: MyColors.dividerColor,
                          ),
                        )
                      : Text(
                          socialPost.comments!.isEmpty
                              ? "0"
                              : "${getTotalCommentCount(comments: socialPost.comments!)}",
                          style: TextStyle(
                            fontFamily: MyAssets.fontMontserrat,
                            fontSize: 14,
                            color: MyColors.dividerColor,
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
                      color: isSave
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
      ));
}

// int getTotalCommentCount({required List<Comment> comments}) {
//   int totalCount = 0;
//
//   if (comments.isNotEmpty) {
//     for (Comment comment in comments) {
//       totalCount++; // Count the main comment
//       totalCount += getTotalCommentCount(
//           comments:
//           comment.children ?? []); // Count the child comments recursively
//     }
//   }
//
//   return totalCount;
// }

Widget _buildShowComment(
    BuildContext context, CommonSocialFeedController controller) {
  return Padding(
    padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w),
    child: Column(
      children: [
        SizedBox(height: 15.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 10,
              child: SizedBox(
                height: 40,
                child: _buildCommentTextField(context, controller),
              ),
            ),
            SizedBox(width: 10.w),
            _buildCommentButton(context, controller)
          ],
        ),
        // Text('comment show korbe')
        _buildComments(controller)
      ],
    ),
  );
}

Widget _buildComments(CommonSocialFeedController controller) {
  return Obx(() => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        reverse: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.socialPostInfo.value.comments!.length,
        itemBuilder: (BuildContext context, int index) {
          Comment c = controller.socialPostInfo.value.comments![index];
          Comment comment = c;

          return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: _buildComentsListTitle(c, context),
                leading: controller.editingCommentId.value == comment.id &&
                        controller.editingReplyId.value == ''
                    ? GestureDetector(
                        onTap: () {
                          controller.onTapCancelCommentEditing();
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                        ))
                    : GestureDetector(
                        onTap: () => c.user?.role?.toLowerCase() == "client"
                            ? Get.toNamed(Routes.individualSocialFeeds,
                                arguments: c.user)
                            : Get.toNamed(Routes.employeeDetails,
                                arguments: {'employeeId': c.user?.id ?? ""}),
                        child: CircleAvatar(
                          backgroundImage: ((c.user?.profilePicture ?? "")
                                      .isEmpty ||
                                  c.user?.profilePicture == "undefined")
                              ? AssetImage(
                                  c.user?.role?.toUpperCase() == "ADMIN"
                                      ? MyAssets.adminDefault
                                      : c.user?.role?.toUpperCase() == "CLIENT"
                                          ? MyAssets.clientDefault
                                          : MyAssets.employeeDefault)
                              : NetworkImage((c.user?.profilePicture ?? "")
                                  .socialMediaUrl),
                        ),
                      ),
                subtitle: controller.editingCommentId.value == comment.id &&
                        controller.editingReplyId.value == ''
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.commentEditTextController,
                              maxLines: null,
                              minLines: 1,
                              style: MyColors.l111111_dwhite(context).medium13,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0.w),
                                // hintText: MyStrings.editCommentHint.tr,
                                fillColor: MyColors.noColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide(
                                      color: MyColors.lightGrey, width: 0.5),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: controller.isEditCommentLoading.value
                                ? CupertinoActivityIndicator(
                                    radius: 10, // Adjust the radius for size
                                  )
                                : Icon(Icons.send,
                                    color: MyColors.primaryLight),
                            onPressed: controller.isEditCommentLoading.value
                                ? null
                                : () async {
                                    controller.updateExistingComment(
                                        controller.socialPostInfo.value.id!,
                                        controller.editingCommentId.value);
                                  },
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.text ?? "",
                            style: TextStyle(
                              fontFamily: MyAssets.fontMontserrat,
                              fontSize: 12,
                              color: MyColors.l111111_dwhite(context),
                            ),
                          ),
                          SizedBox(height: 5.w),
                          GestureDetector(
                            onTap: () {
                              controller.activeReplyCommentId.value =
                                  (controller.activeReplyCommentId.value ==
                                          c.id)
                                      ? ''
                                      : c.id ?? "";
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
                      ),
                trailing: comment.user?.id ==
                        controller.appController.user.value.userId
                    ? PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            controller.editingReplyId.value = '';
                            controller.editingCommentId.value =
                                comment.id.toString();
                            controller.commentEditTextController.text =
                                comment.text ?? "";
                          } else if (value == 'delete') {
                            controller.deleteComment(
                                controller.socialPostInfo.value.id!,
                                comment.id!);
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
              // if (activeReplyCommentId == c.id)
              //   _buildActiveReplyComment(context, c, index),
              // if ((c.children ?? []).isNotEmpty) _buildChildComment(c)
            ],
          );
        },
      ));
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

Widget _buildCommentTextField(
    BuildContext context, CommonSocialFeedController controller) {
  return TextField(
    controller: controller.newCommentEditTextController,
    maxLines: null,
    minLines: 1,
    style: MyColors.l111111_dwhite(context).medium13,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.all(10.0.w),
      filled: true,
      hintText: MyStrings.writeAComment.tr,
      hintStyle: MyColors.lightGrey.medium14,
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

Widget _buildCommentButton(
    BuildContext context, CommonSocialFeedController controller) {
  return Obx(
    () => Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: controller.isCommentLoading.value
            ? null
            : () async {
                Utils.unFocus();
                controller.addNewComment();
              },
        child: controller.isCommentLoading.value
            ? CupertinoActivityIndicator(
                radius: 10, // Adjust the radius for size
              )
            : const Icon(
                Icons.send_outlined,
                color: MyColors.primaryLight,
              ),
      ),
    ),
  );
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

void _showReport(
    {required String postId,
    required BuildContext context,
    required CommonSocialFeedController controller}) {
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
            controller: controller.reportEditTextController,
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
                controller.reportPost(postId: postId);
              })
        ],
      ),
    ),
  ));
}

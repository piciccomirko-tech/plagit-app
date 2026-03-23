import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/modules/common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../common/data/data.dart';
import '../../../../common/deep_link_service/deep_link_service.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/values/my_strings.dart';
import '../../../../common/widgets/custom_buttons.dart';
import '../../../../common/widgets/custom_image_widget.dart';
import '../../../../common/widgets/custom_video_widget.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../enums/custom_button_style.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../models/user.dart';
import '../../../../routes/app_pages.dart';
import '../../splash/controllers/splash_controller.dart';

export '../../../../common/extensions/extensions.dart';

class CommonSocialFeedView extends GetView<CommonSocialFeedController> {
  const CommonSocialFeedView({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: 120.h),
          child: controller.isSocialFeedLoading.value
              ? Center(
                  child: ShimmerWidget.socialPostShimmerWidget(),
                )
              : controller.socialPostList.isEmpty
                  ? const Center(
                      child: NoItemFound(),
                    )
                  : ListView.builder(
                      itemCount: controller.socialPostList.length,
                      physics: NeverScrollableScrollPhysics(),
                      primary: false,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == controller.socialPostList.length - 1 &&
                            controller.moreSocialDataAvailable.value == true) {
                          return const SpinKitThreeBounce(
                            color: MyColors.primaryLight,
                            size: 30,
                          );
                        }
                        // SocialPostModel socialPost =
                        //     controller.socialPostList[index];
                        return ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 100.0),
                          child: VisibilityDetector(
                            key: Key(
                                'post_${controller.socialPostList[index].id}'),
                            onVisibilityChanged: (visibilityInfo) {
                              if (visibilityInfo.visibleFraction > 0.5) {
                                if (!controller.isPostCurrentlyVisible(index)) {
                                  controller.markPostAsVisible(index);
                                  controller.incrementPostViews(
                                      controller.socialPostList[index].id ??
                                          '');
                                }
                              } else {
                                controller.markPostAsHidden(index);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    controller.seePostDetails(index);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 5.w),
                                    padding: EdgeInsets.only(
                                        top: 15.0.w, bottom: 15.0.w),
                                    decoration: BoxDecoration(
                                      color: MyColors.lightCard(context),
                                      border: Border.all(
                                          color: MyColors.noColor, width: 0.5),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 15.0.w, right: 15.0.w),
                                          child: Row(
                                            children: [
                                              buildPostPublishersDetails(
                                                  context,
                                                  controller
                                                      .socialPostList[index]),
                                              // Spacer(),
                                              buildPostMenuButtons(
                                                  context,
                                                  controller
                                                      .socialPostList[index],
                                                  controller
                                                      .appController.user.value,
                                                  controller),
                                            ],
                                          ),
                                        ),
                                        if ((controller.socialPostList[index]
                                                    .content ??
                                                "")
                                            .isNotEmpty) ...[
                                          SizedBox(height: 8.w),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 15.0.w, right: 15.0.w),
                                            child: SocialCaptionWidget(
                                                text: controller
                                                        .socialPostList[index]
                                                        .content ??
                                                    ""),
                                          ),
                                        ],
                                        SizedBox(
                                            height: controller
                                                        .socialPostList[index]
                                                        .repost !=
                                                    null
                                                ? 5.w
                                                : 20.w),
                                        if (controller
                                                .socialPostList[index].repost !=
                                            null)
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left: 15.0.w, right: 15.0.w),
                                            child: repostWidget(
                                                context,
                                                controller.socialPostList[index]
                                                    .repost!,
                                                controller
                                                    .socialPostList[index],
                                                controller,
                                                index),
                                          ),
                                        if ((controller.socialPostList[index]
                                                        .media ??
                                                    [])
                                                .length ==
                                            1)
                                          (controller.socialPostList[index]
                                                              .media ??
                                                          [])
                                                      .first
                                                      .type ==
                                                  'image'
                                              ? buildSingleImage(
                                                  controller
                                                      .socialPostList[index],
                                                  controller,
                                                  index)
                                              : buildSingleVideo(controller
                                                  .socialPostList[index])
                                        else if ((controller
                                                    .socialPostList[index]
                                                    .media ??
                                                [])
                                            .isEmpty)
                                          const Wrap()
                                        else
                                          SizedBox(
                                            height: (controller
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .length >=
                                                    3
                                                ? Get.width * 0.95
                                                : 200.w,
                                            child: (controller
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .length ==
                                                    3
                                                ? buildOnlyThreeItems(
                                                    (controller
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .take(4)
                                                        .toList(),
                                                    controller
                                                        .socialPostList[index],
                                                    controller,
                                                    index)
                                                : buildMoreThanThreeView(
                                                    (controller
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .take(4)
                                                        .toList(),
                                                    (controller
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .length,
                                                    controller
                                                        .socialPostList[index],
                                                    controller,
                                                    index),
                                          ),
                                        buildInteractionCount(
                                            context,
                                            controller.socialPostList[index],
                                            controller.appController.user.value
                                                .userId,
                                            controller,
                                            index),
                                        buildInteraction(
                                            context,
                                            controller.socialPostList[index],
                                            controller.appController.user.value,
                                            () => controller.reactPost(
                                                postId: controller
                                                    .socialPostList[index].id
                                                    .toString(),
                                                index: index),
                                            () =>
                                                controller.commentToggle(index),
                                            () => controller
                                                .seePostDetails(index),
                                            () => controller.savePost(controller
                                                .socialPostList[index].id
                                                .toString()),
                                            () => controller.deleteSavePost(savedPostList
                                                    .firstWhere((post) => post.post?.id == controller.socialPostList[index].id.toString(),
                                                        orElse: () =>
                                                            SavedPostModel())
                                                    .id ??
                                                ""),
                                            controller,
                                            controller.isPostSaved(
                                                controller.socialPostList[index].id.toString()),
                                            index),
                                        Obx(
                                          () =>
                                              controller.selectedIndexForComment
                                                              .value ==
                                                          index &&
                                                      controller
                                                          .showComment.value
                                                  ? controller.isCommentLoading
                                                          .value
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 15.0.w,
                                                                  right:
                                                                      15.0.w),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height: 15.h),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 10,
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          40,
                                                                      child: buildCommentTextField(
                                                                          context,
                                                                          controller),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10.w),
                                                                  buildCommentButton(
                                                                      context,
                                                                      controller)
                                                                ],
                                                              ),
                                                              ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                // reverse: true,
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                itemCount: (controller
                                                                            .socialPostList[index]
                                                                            .comments ??
                                                                        [])
                                                                    .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  Comment c = (controller
                                                                          .socialPostList[
                                                                              index]
                                                                          .comments ??
                                                                      [])[index];
                                                                  Comment
                                                                      comment =
                                                                      c;

                                                                  return Column(
                                                                    children: [
                                                                      ListTile(
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        title: buildComentsListTitle(
                                                                            c,
                                                                            context),
                                                                        leading: controller.editingCommentId.value == comment.id &&
                                                                                controller.editingReplyId.value == ''
                                                                            ? GestureDetector(
                                                                                onTap: () {
                                                                                  controller.onTapCancelCommentEditing();
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.red,
                                                                                ),
                                                                              )
                                                                            : GestureDetector(
                                                                                onTap: () => c.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: c.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': c.user?.id ?? ""}),
                                                                                child: CircleAvatar(
                                                                                  backgroundImage: ((c.user?.profilePicture ?? "").isEmpty || c.user?.profilePicture == "undefined")
                                                                                      ? AssetImage(c.user?.role?.toUpperCase() == "ADMIN"
                                                                                          ? MyAssets.adminDefault
                                                                                          : c.user?.role?.toUpperCase() == "CLIENT"
                                                                                              ? MyAssets.clientDefault
                                                                                              : MyAssets.employeeDefault)
                                                                                      : NetworkImage((c.user?.profilePicture ?? "").socialMediaUrl),
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
                                                                                          borderSide: BorderSide(color: MyColors.lightGrey, width: 0.5),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  IconButton(
                                                                                    icon: controller.isEditCommentLoading.value
                                                                                        ? CupertinoActivityIndicator(
                                                                                            radius: 10, // Adjust the radius for size
                                                                                          )
                                                                                        : Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                                    onPressed: controller.isEditCommentLoading.value
                                                                                        ? null
                                                                                        : () async {
                                                                                            controller.updateExistingComment(controller.socialPostInfo.value.id!, controller.editingCommentId.value);
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
                                                                                      controller.showCommentReplyInputField(c);
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
                                                                                    controller.isCommentLoading.value = true;
                                                                                    controller.editingReplyId.value = '';
                                                                                    controller.editingCommentId.value = comment.id.toString();
                                                                                    controller.commentEditTextController.text = comment.text ?? "";
                                                                                    controller.isCommentLoading.value = false;
                                                                                  } else if (value == 'delete') {
                                                                                    controller.deleteComment(controller.socialPostInfo.value.id!, comment.id!);
                                                                                  }
                                                                                },
                                                                                itemBuilder: (BuildContext context) => [
                                                                                  PopupMenuItem(
                                                                                    value: 'edit',
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Icon(Icons.edit, color: MyColors.primaryLight),
                                                                                        SizedBox(width: 8),
                                                                                        Text("Edit"),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  PopupMenuItem(
                                                                                    value: 'delete',
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Icon(Icons.delete, color: Colors.red),
                                                                                        SizedBox(width: 8),
                                                                                        Text("Delete"),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : null,
                                                                      ),
                                                                      if ((c.children ??
                                                                              [])
                                                                          .isNotEmpty)
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 30.0.w),
                                                                          child:
                                                                              ListView.builder(
                                                                            itemCount:
                                                                                (c.children ?? []).length,
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              Comment reply = (c.children ?? [])[index];
                                                                              return ListTile(
                                                                                contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                                                title: Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () => reply.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': reply.user?.id ?? ""}),
                                                                                      child: Text(
                                                                                        reply.user?.name != null && reply.user!.name!.length > 13 ? Utils.truncateCharacters(reply.user!.name ?? '', 13) : reply.user?.name ?? '',
                                                                                        style: TextStyle(
                                                                                          fontFamily: MyAssets.fontMontserrat,
                                                                                          fontSize: 14,
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
                                                                                      Utils.formatDateTime(reply.createdAt ?? DateTime.now(), socialFeed: true),
                                                                                      style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: 12, color: MyColors.lightGrey),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                leading: controller.editingReplyId.value == reply.id
                                                                                    ? GestureDetector(
                                                                                        onTap: () {
                                                                                          controller.onTapCancelCommentEditing();
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.close,
                                                                                          color: Colors.red,
                                                                                        ))
                                                                                    : GestureDetector(
                                                                                        onTap: () => reply.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': reply.user?.id ?? ""}),
                                                                                        child: CircleAvatar(
                                                                                          backgroundImage: ((reply.user?.profilePicture ?? "").isEmpty || reply.user?.profilePicture == "undefined")
                                                                                              ? AssetImage(reply.user?.role?.toUpperCase() == "ADMIN"
                                                                                                  ? MyAssets.adminDefault
                                                                                                  : reply.user?.role?.toUpperCase() == "CLIENT"
                                                                                                      ? MyAssets.clientDefault
                                                                                                      : MyAssets.employeeDefault)
                                                                                              : NetworkImage((reply.user?.profilePicture ?? "").socialMediaUrl),
                                                                                        ),
                                                                                      ),
                                                                                subtitle: controller.editingReplyId.value == reply.id
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: TextField(
                                                                                              controller: controller.commentReplyEditTextController,
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
                                                                                            icon: controller.isReplyLoading.value
                                                                                                ? CupertinoActivityIndicator(
                                                                                                    radius: 10, // Adjust the radius for size
                                                                                                  )
                                                                                                : Icon(Icons.send, color: MyColors.primaryLight),
                                                                                            onPressed: controller.isReplyLoading.value
                                                                                                ? null
                                                                                                : () async {
                                                                                                    controller.updateCommentReply(controller.socialPostList[index].id, c.id, reply.id);
                                                                                                  },
                                                                                          ),
                                                                                        ],
                                                                                      ) // Show editable field if in edit mode
                                                                                    : Text(
                                                                                        reply.text ?? "",
                                                                                        style: TextStyle(
                                                                                          fontFamily: MyAssets.fontMontserrat,
                                                                                          fontSize: 12,
                                                                                          color: MyColors.lightGrey,
                                                                                        ),
                                                                                      ),
                                                                                trailing: reply.user?.id == controller.appController.user.value.userId
                                                                                    ? PopupMenuButton<String>(
                                                                                        onSelected: (value) {
                                                                                          if (value == 'edit') {
                                                                                          } else if (value == 'delete') {
                                                                                            controller.deleteCommentReply(controller.socialPostList[index].id!, c.id!, reply.id!);
                                                                                          }
                                                                                        },
                                                                                        itemBuilder: (BuildContext context) => [
                                                                                          PopupMenuItem(
                                                                                            value: 'edit',
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Icon(Icons.edit, color: MyColors.primaryLight),
                                                                                                SizedBox(width: 8),
                                                                                                Text("Edit"),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          PopupMenuItem(
                                                                                            value: 'delete',
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Icon(Icons.delete, color: Colors.red),
                                                                                                SizedBox(width: 8),
                                                                                                Text("Delete"),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : null,
                                                                              );
                                                                            },
                                                                            shrinkWrap:
                                                                                true,
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
                                                              EdgeInsets.only(
                                                                  left: 15.0.w,
                                                                  right:
                                                                      15.0.w),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                  height: 15.h),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 10,
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          40,
                                                                      child: buildCommentTextField(
                                                                          context,
                                                                          controller),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          10.w),
                                                                  buildCommentButton(
                                                                      context,
                                                                      controller)
                                                                ],
                                                              ),
                                                              ListView.builder(
                                                                shrinkWrap:
                                                                    true,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                // reverse: true,
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                itemCount: (controller
                                                                            .socialPostList[index]
                                                                            .comments ??
                                                                        [])
                                                                    .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  Comment c = (controller
                                                                          .socialPostList[
                                                                              index]
                                                                          .comments ??
                                                                      [])[index];
                                                                  Comment
                                                                      comment =
                                                                      c;

                                                                  return Column(
                                                                    children: [
                                                                      ListTile(
                                                                        contentPadding:
                                                                            EdgeInsets.zero,
                                                                        title: buildComentsListTitle(
                                                                            c,
                                                                            context),
                                                                        leading: controller.editingCommentId.value == comment.id &&
                                                                                controller.editingReplyId.value == ''
                                                                            ? GestureDetector(
                                                                                onTap: () {
                                                                                  controller.onTapCancelCommentEditing();
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.close,
                                                                                  color: Colors.red,
                                                                                ),
                                                                              )
                                                                            : GestureDetector(
                                                                                onTap: () => c.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: c.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': c.user?.id ?? ""}),
                                                                                child: CircleAvatar(
                                                                                  backgroundImage: ((c.user?.profilePicture ?? "").isEmpty || c.user?.profilePicture == "undefined")
                                                                                      ? AssetImage(c.user?.role?.toUpperCase() == "ADMIN"
                                                                                          ? MyAssets.adminDefault
                                                                                          : c.user?.role?.toUpperCase() == "CLIENT"
                                                                                              ? MyAssets.clientDefault
                                                                                              : MyAssets.employeeDefault)
                                                                                      : NetworkImage((c.user?.profilePicture ?? "").socialMediaUrl),
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
                                                                                          borderSide: BorderSide(color: MyColors.lightGrey, width: 0.5),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  IconButton(
                                                                                    icon: controller.isEditCommentLoading.value
                                                                                        ? CupertinoActivityIndicator(
                                                                                            radius: 10, // Adjust the radius for size
                                                                                          )
                                                                                        : Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                                    onPressed: controller.isEditCommentLoading.value
                                                                                        ? null
                                                                                        : () async {
                                                                                            controller.updateExistingComment(controller.socialPostInfo.value.id!, controller.editingCommentId.value);
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
                                                                                      controller.showCommentReplyInputField(c);
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
                                                                                    controller.isCommentLoading.value = true;
                                                                                    controller.editingReplyId.value = '';
                                                                                    controller.editingCommentId.value = comment.id.toString();
                                                                                    controller.commentEditTextController.text = comment.text ?? "";
                                                                                    controller.isCommentLoading.value = false;
                                                                                  } else if (value == 'delete') {
                                                                                    controller.deleteComment(controller.socialPostInfo.value.id!, comment.id!);
                                                                                  }
                                                                                },
                                                                                itemBuilder: (BuildContext context) => [
                                                                                  PopupMenuItem(
                                                                                    value: 'edit',
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Icon(Icons.edit, color: MyColors.primaryLight),
                                                                                        SizedBox(width: 8),
                                                                                        Text("Edit"),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  PopupMenuItem(
                                                                                    value: 'delete',
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Icon(Icons.delete, color: Colors.red),
                                                                                        SizedBox(width: 8),
                                                                                        Text("Delete"),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : null,
                                                                      ),
                                                                      if (controller
                                                                              .activeReplyCommentId
                                                                              .value ==
                                                                          c.id)
                                                                        Row(
                                                                          children: [
                                                                            const SizedBox(width: 20),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: GestureDetector(
                                                                                onTap: () {
                                                                                  controller.isCommentLoading.value = true;
                                                                                  controller.activeReplyCommentId.value = '';
                                                                                  controller.isCommentLoading.value = false;
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
                                                                                    controller: controller.commentReplyEditTextController,
                                                                                    style: MyColors.l111111_dwhite(context).medium13,
                                                                                    decoration: InputDecoration(contentPadding: EdgeInsets.all(10.0.w), filled: true, hintText: MyStrings.writeAReply.tr, hintStyle: MyColors.lightGrey.medium13, fillColor: MyColors.noColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey))),
                                                                                  ),
                                                                                )),
                                                                            const SizedBox(width: 10),
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: GestureDetector(
                                                                                onTap: controller.isReplyLoading.value
                                                                                    ? null
                                                                                    : () {
                                                                                        controller.addReply(c, index);
                                                                                      },
                                                                                child: controller.isReplyLoading.value
                                                                                    ? CupertinoActivityIndicator(
                                                                                        radius: 10, // Adjust the radius for size
                                                                                      ) // Show loading if true
                                                                                    : const Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      if ((c.children ??
                                                                              [])
                                                                          .isNotEmpty)
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 30.0.w),
                                                                          child:
                                                                              ListView.builder(
                                                                            itemCount:
                                                                                (c.children ?? []).length,
                                                                            padding:
                                                                                EdgeInsets.zero,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              Comment reply = (c.children ?? [])[index];
                                                                              return ListTile(
                                                                                contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                                                title: Row(
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () => reply.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': reply.user?.id ?? ""}),
                                                                                      child: Text(
                                                                                        reply.user?.name != null && reply.user!.name!.length > 13 ? Utils.truncateCharacters(reply.user!.name ?? '', 13) : reply.user?.name ?? '',
                                                                                        style: TextStyle(
                                                                                          fontFamily: MyAssets.fontMontserrat,
                                                                                          fontSize: 14,
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
                                                                                      Utils.formatDateTime(reply.createdAt ?? DateTime.now(), socialFeed: true),
                                                                                      style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: 12, color: MyColors.lightGrey),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                leading: controller.editingReplyId.value == reply.id
                                                                                    ? GestureDetector(
                                                                                        onTap: () {
                                                                                          controller.onTapCancelCommentEditing();
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.close,
                                                                                          color: Colors.red,
                                                                                        ))
                                                                                    : GestureDetector(
                                                                                        onTap: () => reply.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': reply.user?.id ?? ""}),
                                                                                        child: CircleAvatar(
                                                                                          backgroundImage: ((reply.user?.profilePicture ?? "").isEmpty || reply.user?.profilePicture == "undefined")
                                                                                              ? AssetImage(reply.user?.role?.toUpperCase() == "ADMIN"
                                                                                                  ? MyAssets.adminDefault
                                                                                                  : reply.user?.role?.toUpperCase() == "CLIENT"
                                                                                                      ? MyAssets.clientDefault
                                                                                                      : MyAssets.employeeDefault)
                                                                                              : NetworkImage((reply.user?.profilePicture ?? "").socialMediaUrl),
                                                                                        ),
                                                                                      ),
                                                                                subtitle: controller.editingReplyId.value == reply.id
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: TextField(
                                                                                              controller: controller.commentReplyEditTextController,
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
                                                                                            icon: controller.isReplyLoading.value
                                                                                                ? CupertinoActivityIndicator(
                                                                                                    radius: 10, // Adjust the radius for size
                                                                                                  )
                                                                                                : Icon(Icons.send, color: MyColors.primaryLight),
                                                                                            onPressed: controller.isReplyLoading.value
                                                                                                ? null
                                                                                                : () async {
                                                                                                    controller.updateCommentReply(controller.socialPostList[index].id, c.id, reply.id);
                                                                                                  },
                                                                                          ),
                                                                                        ],
                                                                                      ) // Show editable field if in edit mode
                                                                                    : Text(
                                                                                        reply.text ?? "",
                                                                                        style: TextStyle(
                                                                                          fontFamily: MyAssets.fontMontserrat,
                                                                                          fontSize: 12,
                                                                                          color: MyColors.lightGrey,
                                                                                        ),
                                                                                      ),
                                                                                trailing: reply.user?.id == controller.appController.user.value.userId
                                                                                    ? PopupMenuButton<String>(
                                                                                        onSelected: (value) {
                                                                                          if (value == 'edit') {
                                                                                            controller.startEditingReply(c.id!, reply);
                                                                                          } else if (value == 'delete') {
                                                                                            controller.deleteCommentReply(controller.socialPostList[index].id!, c.id!, reply.id!);
                                                                                          }
                                                                                        },
                                                                                        itemBuilder: (BuildContext context) => [
                                                                                          PopupMenuItem(
                                                                                            value: 'edit',
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Icon(Icons.edit, color: MyColors.primaryLight),
                                                                                                SizedBox(width: 8),
                                                                                                Text("Edit"),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          PopupMenuItem(
                                                                                            value: 'delete',
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Icon(Icons.delete, color: Colors.red),
                                                                                                SizedBox(width: 8),
                                                                                                Text("Delete"),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : null,
                                                                              );
                                                                            },
                                                                            shrinkWrap:
                                                                                true,
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
                                controller.socialPostList[index]
                                                .recommendation !=
                                            null &&
                                        controller.socialPostList[index]
                                            .recommendation!.isNotEmpty &&
                                        controller
                                            .appController.user.value.isClient
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, top: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Plagit',
                                              style: TextStyle(
                                                fontFamily: 'Klavika',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: MyColors.primaryLight,
                                              ),
                                            ),
                                            Text(
                                              ' Candidates',
                                              style: TextStyle(
                                                fontFamily: 'Klavika',
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal,
                                                color: MyColors.l111111_dwhite(
                                                    context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                                controller.socialPostList[index]
                                                .recommendation !=
                                            null &&
                                        controller.socialPostList[index]
                                            .recommendation!.isNotEmpty &&
                                        controller
                                            .appController.user.value.isClient
                                    ? SizedBox(
                                        height: 320,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: controller
                                              .socialPostList[index]
                                              .recommendation!
                                              .length,
                                          itemBuilder: (context, index1) {
                                            final candidate = controller
                                                .socialPostList[index]
                                                .recommendation![index1];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: Card(
                                                color: Colors.white,
                                                elevation: 4,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: MyColors.lightCard(
                                                        context),
                                                    border: Border.all(
                                                        color: MyColors.noColor,
                                                        width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  width: 250,
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        height: 150,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          image:
                                                              DecorationImage(
                                                            fit: BoxFit.fill,
                                                            image: ((candidate.profilePicture ??
                                                                            "")
                                                                        .isEmpty ||
                                                                    candidate
                                                                            .profilePicture ==
                                                                        "undefined")
                                                                ? AssetImage(candidate
                                                                            .role
                                                                            ?.toUpperCase() ==
                                                                        "ADMIN"
                                                                    ? MyAssets
                                                                        .adminDefault
                                                                    : candidate.role?.toUpperCase() ==
                                                                            "CLIENT"
                                                                        ? MyAssets
                                                                            .clientDefault
                                                                        : MyAssets
                                                                            .employeeDefault)
                                                                : NetworkImage((candidate.profilePicture ??
                                                                                "")
                                                                            .toString() ==
                                                                        ""
                                                                    ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                                                                    : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${candidate.profilePicture}"),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        candidate.name !=
                                                                    null &&
                                                                candidate.name!
                                                                        .length >
                                                                    17
                                                            ? Utils.truncateCharacters(
                                                                candidate
                                                                        .name ??
                                                                    '',
                                                                17)
                                                            : candidate.name ??
                                                                '',
                                                        style: TextStyle(
                                                            fontFamily: MyAssets
                                                                .fontMontserrat,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: MyColors
                                                                .l111111_dwhite(
                                                                    context)),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            MyAssets.exp,
                                                            width: 14.w,
                                                            height: 14.w,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child: Text(
                                                              '${MyStrings.exp.tr}: ${candidate.employeeExperience} Years',
                                                              style: TextStyle(
                                                                  fontSize: 14),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          SvgPicture.network(
                                                            Data.getCountryFlagByName(
                                                                candidate
                                                                    .countryName
                                                                    .toString()),
                                                            width: 10,
                                                            height: 10,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              ("${candidate.countryName}")
                                                                  .toUpperCase(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: MyColors
                                                                      .l111111_dwhite(
                                                                          context)
                                                                  .regular11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            MyAssets.rate,
                                                            width: 14.w,
                                                            height: 14.w,
                                                          ),
                                                          SizedBox(width: 5),
                                                          Expanded(
                                                            child: Text(
                                                              ("${MyStrings.rate.tr} ${Utils.getCurrencySymbol()}${candidate.hourlyRate ?? 0}")
                                                                  .toUpperCase(),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: MyColors
                                                                      .l111111_dwhite(
                                                                          context)
                                                                  .regular11,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              Utils.showToast(
                                                                  message:
                                                                      'coming soon',
                                                                  bgColor:
                                                                      Colors
                                                                          .red);
                                                            },
                                                            child: 1 != 1
                                                                ? const SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CupertinoActivityIndicator(),
                                                                    ),
                                                                  )
                                                                : 1 == 1
                                                                    ? Icon(
                                                                        Icons
                                                                            .bookmark,
                                                                        color: MyColors
                                                                            .c_C6A34F,
                                                                        size: Get.width >
                                                                                600
                                                                            ? 35
                                                                            : 25,
                                                                      )
                                                                    : Icon(
                                                                        Icons
                                                                            .bookmark_outline_rounded,
                                                                        color: Colors
                                                                            .grey,
                                                                        size: Get.width >
                                                                                600
                                                                            ? 35
                                                                            : 25),
                                                          ),
                                                          SizedBox(
                                                            width: 122.w,
                                                            child: CustomButtons
                                                                .button(
                                                                    height: 30,
                                                                    text: MyStrings
                                                                        .bookNow
                                                                        .tr,
                                                                    margin:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    fontSize:
                                                                        12.sp,
                                                                    customButtonStyle:
                                                                        CustomButtonStyle
                                                                            .radiusTopBottomCorner,
                                                                    onTap: () {
                                                                      Utils.showToast(
                                                                          message:
                                                                              'coming soon',
                                                                          bgColor:
                                                                              Colors.red);
                                                                    }),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                        );
                      }),
        ),
      ),
    );
  }
}

Widget buildPostPublishersDetails(
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

                    // if (socialPost.user?.role?.toUpperCase() != "CLIENT" &&
                    //     socialPost.user?.role?.toUpperCase() != "ADMIN")
                    //   Padding(
                    //     padding: EdgeInsets.symmetric(horizontal: 10.w),
                    //     child: CircleAvatar(
                    //       radius: 1.5,
                    //       backgroundColor: MyColors.l111111_dwhite(context),
                    //     ),
                    //   ),
                    // Text(
                    //   socialPost.user?.countryName ?? "",
                    //   style: TextStyle(
                    //       fontFamily: MyAssets.fontMontserrat,
                    //       fontSize: 11,
                    //       color: MyColors.lightGrey),
                    // ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

PopupMenuButton<int> buildPostMenuButtons(
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
        // Get.toNamed(Routes.createPost, arguments: [socialPost, 'edit']);
        Get.toNamed(Routes.updatePost, arguments: [socialPost]);

        ///Changed
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
        // if (socialPost.repost == null) {
        //   appUser.isAdmin
        //       ? null
        //       : _showRepost(
        //           postId: socialPost.id ?? '',
        //           context: context,
        //           controller: controller);
        // }
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

Widget repostWidget(
    BuildContext context,
    Repost repost,
    SocialPostModel socialPost,
    CommonSocialFeedController controller,
    int postIndex) {
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
                      buildRepostUser(repost),
                      SizedBox(width: 10.w),
                      Text(
                        repost.user?.name != null &&
                                repost.user!.name!.length > 17
                            ? Utils.truncateCharacters(
                                repost.user!.name ?? '', 17)
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
                          onTap: () => controller.seeMediaDetails(socialPost, 0,
                              postIndex: postIndex),
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
                          radius: 10,
                          hasAspect: false,
                          media: (repost.media ?? []).first,
                        )
                else if ((repost.media ?? []).isEmpty)
                  const Wrap()
                else
                  SizedBox(
                    height: mediaCount >= 3 ? Get.width * 0.95 : 200.w,
                    child: mediaCount == 3
                        ? buildRepostItemsThree(repost, visibleMedia,
                            socialPost, controller, postIndex)
                        : buildRepostItemsMoreThanThree(
                            visibleMedia,
                            mediaCount,
                            repost,
                            socialPost,
                            controller,
                            postIndex),
                  ),
              ],
            ),
          ),
        );
}

GestureDetector buildRepostUser(Repost repost) {
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

Widget buildRepostItemsThree(
    Repost repost,
    List<Media> visibleMedia,
    SocialPostModel socialPost,
    CommonSocialFeedController controller,
    int postIndex) {
  return SingleChildScrollView(
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          height: Get.width * 0.5,
          child: GestureDetector(
            onTap: () =>
                controller.seeMediaDetails(socialPost, 0, postIndex: postIndex),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 0, mediaList: (widget.socialPost.media ?? []))),
            child: (repost.media ?? [])[0].type == 'video'
                ? thumbImageWidget(
                    url:
                        (repost.media ?? [])[0].thumbnail?.socialMediaUrl ?? '',
                    height: Get.width * 0.5,
                  )
                : buildMediaWidget(
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
                onTap: () => controller.seeMediaDetails(socialPost, 1,
                    postIndex: postIndex),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 1,
                //     mediaList: (widget.socialPost.media ?? []),
                //   ),
                // ),
                child: (repost.media ?? [])[1].type == 'video'
                    ? thumbImageWidget(
                        url:
                            (repost.media ?? [])[1].thumbnail?.socialMediaUrl ??
                                '',
                        height: Get.width * 0.5,
                      )
                    : buildMediaWidget(
                        post: visibleMedia[1], height: Get.width * 0.35),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 2,
                    postIndex: postIndex),
                // onTap: () => Get.to(
                //   () => MediaViewAllWidget(
                //     index: 2,
                //     mediaList: (widget.socialPost.media ?? []),
                //   ),
                // ),
                child: (repost.media ?? [])[2].type == 'video'
                    ? thumbImageWidget(
                        url:
                            (repost.media ?? [])[2].thumbnail?.socialMediaUrl ??
                                '',
                        height: Get.width * 0.5,
                      )
                    : buildMediaWidget(
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

Widget buildRepostItemsMoreThanThree(
    List<Media> visibleMedia,
    int mediaCount,
    Repost repost,
    SocialPostModel socialPost,
    CommonSocialFeedController controller,
    int postIndex) {
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
                : buildMediaWidget(
                    post: post,
                    height: Get.height,
                  ),
            // Overlay the count of additional items on the 4th media
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 3,
                    postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 0, postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 1, postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 2, postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 3, postIndex: postIndex),
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
        onTap: () =>
            controller.seeMediaDetails(socialPost, index, postIndex: postIndex),
        // onTap: () => Get.to(() => MediaViewAllWidget(
        //     index: 0, mediaList: (widget.socialPost.media ?? []))),
        child: buildMediaWidget(post: post, height: Get.height),
      );
    }).toList(),
  );
}

Widget thumbImageWidget({required String url, double? height}) {
  return Container(
    height: height,
    width: Get.width,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      // borderRadius: BorderRadius.circular(widget.radius ?? 10.0),
      image: DecorationImage(
        // Added image decoration
        image: CachedNetworkImageProvider(url), // Replace with your image URL
        fit: BoxFit.cover, // Adjust the fit as needed
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

//Helper function to build media widget (image or video)
Widget buildMediaWidget(
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
    return thumbImageWidget(
      url: post.thumbnail?.socialMediaUrl ?? '',
      height: height,
    );
  }
  return Container(); // Fallback in case of unknown media type
}

Widget buildSingleVideo(SocialPostModel socialPost) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15.w),
    child: CustomVideoWidget(
      radius: 1,
      hasAspect: false,
      media: (socialPost.media ?? []).first,
    ),
  );
}

Widget buildSingleImage(SocialPostModel socialPost,
    CommonSocialFeedController controller, int postIndex) {
  return Padding(
    padding: EdgeInsets.only(bottom: 15.w),
    child: GestureDetector(
      ///Todo
      onTap: () =>
          controller.seeMediaDetails(socialPost, 0, postIndex: postIndex),
      // onTap: () => Get.to(() =>
      //     MediaViewAllWidget(index: 0, mediaList: socialPost.media ?? [])),
      child: CustomImageWidget(
        imgUrl: ((socialPost.media ?? []).first.url ?? "").socialMediaUrl,
        radius: 1.0,
        width: Get.width,
        height: (socialPost.media ?? []).first.scaledHeight,
        fit: BoxFit.cover,
      ),
    ),
  );
}

Widget buildMoreThanThreeView(
    List<Media> visibleMedia,
    int mediaCount,
    SocialPostModel socialPost,
    CommonSocialFeedController controller,
    int postIndex) {
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
                : buildMediaWidget(
                    post: post,
                    height: Get.height,
                  ),
            // Overlay the count of additional items on the 4th media
            Positioned.fill(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 3,
                    postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 0, postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 1, postIndex: postIndex),
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
          onTap: () =>
              controller.seeMediaDetails(socialPost, 2, postIndex: postIndex),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 2, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
              url: (socialPost.media ?? [])[2].thumbnail?.socialMediaUrl ?? '',
              height: Get.height),
        );
      }
      if (index == 3 && (socialPost.media ?? [])[3].type == 'video') {
        return GestureDetector(
          onTap: () =>
              controller.seeMediaDetails(socialPost, 3, postIndex: postIndex),
          // onTap: () => Get.to(() => MediaViewAllWidget(
          //     index: 3, mediaList: (socialPost.media ?? []))),
          child: thumbImageWidget(
              url: (socialPost.media ?? [])[3].thumbnail?.socialMediaUrl ?? '',
              height: Get.height),
        );
      }

      // Regular media items (image or video)
      return GestureDetector(
        onTap: () =>
            controller.seeMediaDetails(socialPost, index, postIndex: postIndex),
        // onTap: () => Get.to(() =>
        //     MediaViewAllWidget(index: 0, mediaList: (socialPost.media ?? []))),
        child: buildMediaWidget(post: post, height: Get.height),
      );
    }).toList(),
  );
}

Widget buildOnlyThreeItems(List<Media> visibleMedia, SocialPostModel socialPost,
    CommonSocialFeedController controller, int postIndex) {
  return SingleChildScrollView(
    primary: false,
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        Container(
          height: Get.width * 0.5,
          child: GestureDetector(
            onTap: () =>
                controller.seeMediaDetails(socialPost, 0, postIndex: postIndex),
            // onTap: () => Get.to(() => MediaViewAllWidget(
            //     index: 0, mediaList: (socialPost.media ?? []))),
            child: buildMediaWidget(
                hasAspect: false,
                post: visibleMedia[0],
                height: Get.width * 0.5),
          ),
        ),
        SizedBox(height: 3.w),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 1,
                    postIndex: postIndex),
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
                    : buildMediaWidget(
                        post: visibleMedia[1], height: Get.width * 0.35),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.seeMediaDetails(socialPost, 2,
                    postIndex: postIndex),
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
                    : buildMediaWidget(
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

Widget buildInteractionCount(BuildContext context, SocialPostModel socialPost,
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
            // controller.selectedIndex.value == index &&
            //         controller.isCommentLoading.value
            //     ? Text(
            //         socialPost.comments!.isEmpty
            //             ? ""
            //             : "${controller.getTotalCommentCount(comments: socialPost.comments!)} comments",
            //         style: TextStyle(
            //           fontFamily: MyAssets.fontMontserrat,
            //           fontSize: 12,
            //           color: MyColors.dividerColor,
            //         ),
            //       )
            //     : Text(
            //         socialPost.comments!.isEmpty
            //             ? ""
            //             : "${controller.getTotalCommentCount(comments: socialPost.comments!)} comments",
            //         style: TextStyle(
            //           fontFamily: MyAssets.fontMontserrat,
            //           fontSize: 12,
            //           color: MyColors.dividerColor,
            //         ),
            //       ),
            // Text(
            //   "${socialPost.views ?? 0} views",
            //   style: TextStyle(
            //     fontFamily: MyAssets.fontMontserrat,
            //     fontSize: 12,
            //     color: MyColors.dividerColor,
            //   ),
            // ),
          ],
        ),
      ));
}

Widget buildInteraction(
    BuildContext context,
    SocialPostModel socialPost,
    User appUser,
    Function() react,
    Function() commentToggle,
    Function() onTapComment,
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                          size: 24.w,
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
                    "${socialPost.likes!.length}",
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
                onTapComment();
                // appUser.isAdmin ? null :
                // commentToggle();
              },
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
            SizedBox(width: 12.w),
            Row(
              children: [
                Icon(Icons.remove_red_eye_outlined,
                    size: 24.w, color: MyColors.dividerColor),
                SizedBox(width: 10.w),
                Text(
                  "${socialPost.views ?? 0}",
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
                appUser.isAdmin
                    ? null
                    : isSave
                        ? deleteSavePost()
                        : savePost();
                // if (appUser.isAdmin) return;
                //
                // bool wasPostSaved =
                //     savedPostList.any((e) => e.post?.id == socialPost.id);
                //
                // if (wasPostSaved) {
                //   deleteSavePost();
                // } else {
                //   savePost();
                // }
                //
                // if (wasPostSaved) {
                //   savedPostList.removeWhere((e) => e.post?.id == socialPost.id);
                // } else {
                //   savedPostList.add(SavedPostModel(id: "", post: socialPost));
                // }
              },
              child: Row(
                children: [
                  Icon(
                      // savedPostList.any((e) => e.post?.id == socialPost.id)
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

            // if (socialPost.repost == null)
            // if (repost != null && socialPost.repost == null)
            if (socialPost.repost == null)
              GestureDetector(
                onTap: () {
                  appUser.isAdmin
                      ? null
                      : _showRepost(
                          postId: socialPost.id ?? '',
                          context: context,
                          controller: controller);

                  // appUser.isAdmin
                  //     ? null
                  //     : _showReport(
                  //         postId: socialPost.id ?? '',
                  //         context: context,
                  //         controller: controller);
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

Widget buildCommentTextField(
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

Widget buildCommentButton(
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

Widget buildComments(commentList, CommonSocialFeedController controller) {
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
            title: buildComentsListTitle(c, context),
            leading: controller.editingCommentId.value == comment.id &&
                    controller.editingReplyId.value == ''
                ? GestureDetector(
                    onTap: () {
                      controller.onTapCancelCommentEditing();
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                    ),
                  )
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
                          ? AssetImage(c.user?.role?.toUpperCase() == "ADMIN"
                              ? MyAssets.adminDefault
                              : c.user?.role?.toUpperCase() == "CLIENT"
                                  ? MyAssets.clientDefault
                                  : MyAssets.employeeDefault)
                          : NetworkImage(
                              (c.user?.profilePicture ?? "").socialMediaUrl),
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
                            : Icon(Icons.send_outlined,
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
                              (controller.activeReplyCommentId.value == c.id)
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
                            controller.socialPostInfo.value.id!, comment.id!);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: MyColors.primaryLight),
                            SizedBox(width: 8),
                            Text("Edit"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Delete"),
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
  );
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

Row buildComentsListTitle(Comment c, BuildContext context) {
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

void _showRepost(
    {required String postId,
    required BuildContext context,
    required CommonSocialFeedController controller}) {
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
                      postId: postId, context: context);
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

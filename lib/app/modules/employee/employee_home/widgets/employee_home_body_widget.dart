import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/bottom_nav_bar_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_location_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_name_widget.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../common/data/data.dart';
import '../../../../common/widgets/custom_badge.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../models/saved_post_model.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../../common_modules/common_social_feed/views/common_social_feed_view.dart';
import '../../../common_modules/splash/controllers/splash_controller.dart';
import 'employee_home_tab_widget.dart';
import 'employee_job_posts_widget.dart';
import 'employee_progress_indication_home.dart';

class EmployeeHomeBodyWidget extends GetWidget<EmployeeHomeController> {
  EmployeeHomeBodyWidget({super.key});

  final feedController = Get.put(
    CommonSocialFeedController(socialFeedRepository: Get.find()),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() => RefreshIndicator(
          onRefresh: () =>
              controller.onRefresh(refresh: true, needToJumpTop: false),
          backgroundColor: MyColors.lightCard(context),
          color: MyColors.primaryLight,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                controller: controller.scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildProfileProgress()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.w,
                        right: 15.0.w,
                        top: 15.0.w,
                      ),
                      child: const EmployeeNameWidget(),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildWorkSchedule()),
                  SliverToBoxAdapter(child: const BottomNavBarWidget()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(15.0.w),
                      child: const EmployeeHomeTabWidget(),
                    ),
                  ),
                  // SliverToBoxAdapter(child: const EmployeeTabItemWidget()),

                  Obx(() => SliverToBoxAdapter(
                      child: controller.selectedTabIndex.value == 0
                          ? EmployeeJobPostsWidget()
                          : Offstage())),

                  Obx(() {
                    if (controller.selectedTabIndex.value == 1) {
                      return feedController.isSocialFeedLoading.value
                          ? SliverToBoxAdapter(
                              child: Center(
                                child: ShimmerWidget.socialPostShimmerWidget(),
                              ),
                            )
                          : feedController.socialPostList.isEmpty
                              ? SliverToBoxAdapter(
                                  child: const Center(
                                    child: NoItemFound(),
                                  ),
                                )
                              : SliverList.builder(
                                  itemCount:
                                      feedController.socialPostList.length,
                                  // physics: NeverScrollableScrollPhysics(),
                                  // primary: false,
                                  // shrinkWrap: true,
                                  // padding: EdgeInsets.zero,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    if (index ==
                                            feedController
                                                    .socialPostList.length -
                                                1 &&
                                        feedController.moreSocialDataAvailable
                                                .value ==
                                            true) {
                                      return const SpinKitThreeBounce(
                                        color: MyColors.primaryLight,
                                        size: 30,
                                      );
                                    }
                                    // SocialPostModel socialPost =
                                    //     controller.socialPostList[index];
                                    return ConstrainedBox(
                                      constraints:
                                          BoxConstraints(minHeight: 100.0),
                                      child: VisibilityDetector(
                                        key: Key(
                                            'post_${feedController.socialPostList[index].id}'),
                                        onVisibilityChanged: (visibilityInfo) {
                                          if (visibilityInfo.visibleFraction >
                                              0.5) {
                                            if (!feedController
                                                .isPostCurrentlyVisible(
                                                    index)) {
                                              feedController
                                                  .markPostAsVisible(index);
                                              feedController.incrementPostViews(
                                                  feedController
                                                          .socialPostList[index]
                                                          .id ??
                                                      '');
                                            }
                                          } else {
                                            feedController
                                                .markPostAsHidden(index);
                                          }
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                feedController
                                                    .seePostDetails(index);
                                              },
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(top: 5.w),
                                                padding: EdgeInsets.only(
                                                    top: 15.0.w,
                                                    bottom: 15.0.w),
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
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 15.0.w,
                                                          right: 15.0.w),
                                                      child: Row(
                                                        children: [
                                                          buildPostPublishersDetails(
                                                              context,
                                                              feedController
                                                                      .socialPostList[
                                                                  index]),
                                                          // Spacer(),
                                                          buildPostMenuButtons(
                                                              context,
                                                              feedController
                                                                      .socialPostList[
                                                                  index],
                                                              feedController
                                                                  .appController
                                                                  .user
                                                                  .value,
                                                              feedController),
                                                        ],
                                                      ),
                                                    ),
                                                    if ((feedController
                                                                .socialPostList[
                                                                    index]
                                                                .content ??
                                                            "")
                                                        .isNotEmpty) ...[
                                                      SizedBox(height: 8.w),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15.0.w,
                                                                right: 15.0.w),
                                                        child: SocialCaptionWidget(
                                                            text: feedController
                                                                    .socialPostList[
                                                                        index]
                                                                    .content ??
                                                                ""),
                                                      ),
                                                    ],
                                                    SizedBox(
                                                        height: feedController
                                                                    .socialPostList[
                                                                        index]
                                                                    .repost !=
                                                                null
                                                            ? 5.w
                                                            : 20.w),
                                                    if (feedController
                                                            .socialPostList[
                                                                index]
                                                            .repost !=
                                                        null)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15.0.w,
                                                                right: 15.0.w),
                                                        child: repostWidget(
                                                            context,
                                                            feedController
                                                                .socialPostList[
                                                                    index]
                                                                .repost!,
                                                            feedController
                                                                    .socialPostList[
                                                                index],
                                                            feedController,
                                                            index),
                                                      ),
                                                    if ((feedController
                                                                    .socialPostList[
                                                                        index]
                                                                    .media ??
                                                                [])
                                                            .length ==
                                                        1)
                                                      (feedController
                                                                          .socialPostList[
                                                                              index]
                                                                          .media ??
                                                                      [])
                                                                  .first
                                                                  .type ==
                                                              'image'
                                                          ? buildSingleImage(
                                                              feedController
                                                                      .socialPostList[
                                                                  index],
                                                              feedController,
                                                              index)
                                                          : buildSingleVideo(
                                                              feedController
                                                                      .socialPostList[
                                                                  index])
                                                    else if ((feedController
                                                                .socialPostList[
                                                                    index]
                                                                .media ??
                                                            [])
                                                        .isEmpty)
                                                      const Wrap()
                                                    else
                                                      SizedBox(
                                                        height: (feedController
                                                                            .socialPostList[index]
                                                                            .media ??
                                                                        [])
                                                                    .length >=
                                                                3
                                                            ? Get.width * 0.95
                                                            : 200.w,
                                                        child: (feedController
                                                                            .socialPostList[
                                                                                index]
                                                                            .media ??
                                                                        [])
                                                                    .length ==
                                                                3
                                                            ? buildOnlyThreeItems(
                                                                (feedController
                                                                            .socialPostList[
                                                                                index]
                                                                            .media ??
                                                                        [])
                                                                    .take(4)
                                                                    .toList(),
                                                                feedController
                                                                        .socialPostList[
                                                                    index],
                                                                feedController,
                                                                index)
                                                            : buildMoreThanThreeView(
                                                                (feedController
                                                                            .socialPostList[
                                                                                index]
                                                                            .media ??
                                                                        [])
                                                                    .take(4)
                                                                    .toList(),
                                                                (feedController
                                                                            .socialPostList[
                                                                                index]
                                                                            .media ??
                                                                        [])
                                                                    .length,
                                                                feedController
                                                                        .socialPostList[
                                                                    index],
                                                                feedController,
                                                                index),
                                                      ),
                                                    // buildInteractionCount(
                                                    //     context,
                                                    //     feedController
                                                    //         .socialPostList[index],
                                                    //     feedController.appController
                                                    //         .user.value.userId,
                                                    //     feedController,
                                                    //     index),
                                                    SizedBox(height: 10.h),
                                                    Obx(() => buildInteraction(
                                                        context,
                                                        feedController.socialPostList[
                                                            index],
                                                        feedController
                                                            .appController
                                                            .user
                                                            .value,
                                                        () => feedController.reactPost(
                                                            postId: feedController
                                                                .socialPostList[
                                                                    index]
                                                                .id
                                                                .toString(),
                                                            index: index,
                                                            img: controller
                                                                    .employee
                                                                    .value
                                                                    .details
                                                                    ?.profilePicture ??
                                                                ''),
                                                        () => feedController
                                                            .commentToggle(index),
                                                        () => feedController.seePostDetails(index),
                                                        () => feedController.savePost(feedController.socialPostList[index].id.toString()),
                                                        () => feedController.deleteSavePost(savedPostList.firstWhere((post) => post.post?.id == feedController.socialPostList[index].id.toString(), orElse: () => SavedPostModel()).id ?? ""),
                                                        feedController,
                                                        feedController.isPostSaved(feedController.socialPostList[index].id.toString()),
                                                        index)),
                                                    /*Obx(
                                                      () => feedController
                                                                      .selectedIndexForComment
                                                                      .value ==
                                                                  index &&
                                                              feedController
                                                                  .showComment
                                                                  .value
                                                          ? feedController
                                                                  .isCommentLoading
                                                                  .value
                                                              ? Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 15.0
                                                                          .w,
                                                                      right: 15.0
                                                                          .w),
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                          height:
                                                                              15.h),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                10,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 40,
                                                                              child: buildCommentTextField(context, feedController),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10.w),
                                                                          buildCommentButton(
                                                                              context,
                                                                              feedController)
                                                                        ],
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        // reverse: true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemCount:
                                                                            (feedController.socialPostList[index].comments ?? []).length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int indexC) {
                                                                          Comment
                                                                              c1 =
                                                                              (feedController.socialPostList[index].comments ?? [])[indexC];
                                                                          Comment
                                                                              comment =
                                                                              c1;

                                                                          return Column(
                                                                            children: [
                                                                              ListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: buildComentsListTitle(c1, context),
                                                                                leading: feedController.editingCommentId.value == comment.id && feedController.editingReplyId.value == ''
                                                                                    ? GestureDetector(
                                                                                        onTap: () {
                                                                                          feedController.onTapCancelCommentEditing();
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.close,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      )
                                                                                    : GestureDetector(
                                                                                        onTap: () => c1.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: c1.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': c1.user?.id ?? ""}),
                                                                                        child: CircleAvatar(
                                                                                          backgroundImage: ((c1.user?.profilePicture ?? "").isEmpty || c1.user?.profilePicture == "undefined")
                                                                                              ? AssetImage(c1.user?.role?.toUpperCase() == "ADMIN"
                                                                                                  ? MyAssets.adminDefault
                                                                                                  : c1.user?.role?.toUpperCase() == "CLIENT"
                                                                                                      ? MyAssets.clientDefault
                                                                                                      : MyAssets.employeeDefault)
                                                                                              : NetworkImage((c1.user?.profilePicture ?? "").socialMediaUrl),
                                                                                        ),
                                                                                      ),
                                                                                subtitle: feedController.editingCommentId.value == comment.id && feedController.editingReplyId.value == ''
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: TextField(
                                                                                              controller: feedController.commentEditTextController,
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
                                                                                            icon: feedController.isEditCommentLoading.value
                                                                                                ? CupertinoActivityIndicator(
                                                                                                    radius: 10, // Adjust the radius for size
                                                                                                  )
                                                                                                : Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                                            onPressed: feedController.isEditCommentLoading.value
                                                                                                ? null
                                                                                                : () async {
                                                                                                    feedController.updateExistingComment(feedController.socialPostInfo.value.id!, feedController.editingCommentId.value);
                                                                                                  },
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            c1.text ?? "",
                                                                                            style: TextStyle(
                                                                                              fontFamily: MyAssets.fontKlavika,
                                                                                              fontSize: 12,
                                                                                              color: MyColors.l111111_dwhite(context),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 5.w),
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              feedController.showCommentReplyInputField(c1);
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
                                                                                trailing: comment.user?.id == feedController.appController.user.value.userId
                                                                                    ? PopupMenuButton<String>(
                                                                                        onSelected: (value) {
                                                                                          if (value == 'edit') {
                                                                                            feedController.isCommentLoading.value = true;
                                                                                            feedController.editingReplyId.value = '';
                                                                                            feedController.editingCommentId.value = comment.id.toString();
                                                                                            feedController.commentEditTextController.text = comment.text ?? "";
                                                                                            feedController.isCommentLoading.value = false;
                                                                                          } else if (value == 'delete') {
                                                                                            feedController.deleteComment(feedController.socialPostInfo.value.id!, comment.id!);
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
                                                                                                  style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                                  style: TextStyle(fontFamily: MyAssets.fontMontserrat),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : null,
                                                                              ),
                                                                              if ((c1.children ?? []).isNotEmpty)
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: 30.0.w),
                                                                                  child: ListView.builder(
                                                                                    itemCount: (c1.children ?? []).length,
                                                                                    padding: EdgeInsets.zero,
                                                                                    itemBuilder: (context, indexCC) {
                                                                                      Comment reply = (c1.children ?? [])[indexCC];
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
                                                                                        leading: feedController.editingReplyId.value == reply.id
                                                                                            ? GestureDetector(
                                                                                                onTap: () {
                                                                                                  feedController.onTapCancelCommentEditing();
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
                                                                                        subtitle: feedController.editingReplyId.value == reply.id
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    child: TextField(
                                                                                                      controller: feedController.commentReplyEditTextController,
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
                                                                                                    icon: feedController.isReplyLoading.value
                                                                                                        ? CupertinoActivityIndicator(
                                                                                                            radius: 10, // Adjust the radius for size
                                                                                                          )
                                                                                                        : Icon(Icons.send, color: MyColors.primaryLight),
                                                                                                    onPressed: feedController.isReplyLoading.value
                                                                                                        ? null
                                                                                                        : () async {
                                                                                                            feedController.updateCommentReply(feedController.socialPostList[index].id, c1.id, reply.id);
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
                                                                                        trailing: reply.user?.id == feedController.appController.user.value.userId
                                                                                            ? PopupMenuButton<String>(
                                                                                                onSelected: (value) {
                                                                                                  if (value == 'edit') {
                                                                                                  } else if (value == 'delete') {
                                                                                                    feedController.deleteCommentReply(feedController.socialPostList[index].id!, c1.id!, reply.id!);
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
                                                                                                          style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                                          style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                )
                                                                            ],
                                                                          );
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left: 15.0
                                                                          .w,
                                                                      right: 15.0
                                                                          .w),
                                                                  child: Column(
                                                                    children: [
                                                                      SizedBox(
                                                                          height:
                                                                              15.h),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                10,
                                                                            child:
                                                                                SizedBox(
                                                                              height: 40,
                                                                              child: buildCommentTextField(context, feedController),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10.w),
                                                                          buildCommentButton(
                                                                              context,
                                                                              feedController)
                                                                        ],
                                                                      ),
                                                                      ListView
                                                                          .builder(
                                                                        shrinkWrap:
                                                                            true,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                        // reverse: true,
                                                                        physics:
                                                                            const NeverScrollableScrollPhysics(),
                                                                        itemCount:
                                                                            (feedController.socialPostList[index].comments ?? []).length,
                                                                        itemBuilder:
                                                                            (BuildContext context,
                                                                                int indexRC) {
                                                                          Comment
                                                                              c2 =
                                                                              (feedController.socialPostList[index].comments ?? [])[indexRC];
                                                                          Comment
                                                                              comment =
                                                                              c2;

                                                                          return Column(
                                                                            children: [
                                                                              ListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: buildComentsListTitle(c2, context),
                                                                                leading: feedController.editingCommentId.value == comment.id && feedController.editingReplyId.value == ''
                                                                                    ? GestureDetector(
                                                                                        onTap: () {
                                                                                          feedController.onTapCancelCommentEditing();
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.close,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      )
                                                                                    : GestureDetector(
                                                                                        onTap: () => c2.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: c2.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': c2.user?.id ?? ""}),
                                                                                        child: CircleAvatar(
                                                                                          backgroundImage: ((c2.user?.profilePicture ?? "").isEmpty || c2.user?.profilePicture == "undefined")
                                                                                              ? AssetImage(c2.user?.role?.toUpperCase() == "ADMIN"
                                                                                                  ? MyAssets.adminDefault
                                                                                                  : c2.user?.role?.toUpperCase() == "CLIENT"
                                                                                                      ? MyAssets.clientDefault
                                                                                                      : MyAssets.employeeDefault)
                                                                                              : NetworkImage((c2.user?.profilePicture ?? "").socialMediaUrl),
                                                                                        ),
                                                                                      ),
                                                                                subtitle: feedController.editingCommentId.value == comment.id && feedController.editingReplyId.value == ''
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Expanded(
                                                                                            child: TextField(
                                                                                              controller: feedController.commentEditTextController,
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
                                                                                            icon: feedController.isEditCommentLoading.value
                                                                                                ? CupertinoActivityIndicator(
                                                                                                    radius: 10, // Adjust the radius for size
                                                                                                  )
                                                                                                : Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                                            onPressed: feedController.isEditCommentLoading.value
                                                                                                ? null
                                                                                                : () async {
                                                                                                    feedController.updateExistingComment(feedController.socialPostInfo.value.id!, feedController.editingCommentId.value);
                                                                                                  },
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            c2.text ?? "",
                                                                                            style: TextStyle(
                                                                                              fontFamily: MyAssets.fontMontserrat,
                                                                                              fontSize: 12,
                                                                                              color: MyColors.l111111_dwhite(context),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(height: 5.w),
                                                                                          GestureDetector(
                                                                                            onTap: () {
                                                                                              feedController.showCommentReplyInputField(c2);
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
                                                                                trailing: comment.user?.id == feedController.appController.user.value.userId
                                                                                    ? PopupMenuButton<String>(
                                                                                        onSelected: (value) {
                                                                                          if (value == 'edit') {
                                                                                            feedController.isCommentLoading.value = true;
                                                                                            feedController.editingReplyId.value = '';
                                                                                            feedController.editingCommentId.value = comment.id.toString();
                                                                                            feedController.commentEditTextController.text = comment.text ?? "";
                                                                                            feedController.isCommentLoading.value = false;
                                                                                          } else if (value == 'delete') {
                                                                                            feedController.deleteComment(feedController.socialPostInfo.value.id!, comment.id!);
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
                                                                                                  style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                                  style: TextStyle(fontFamily: MyAssets.fontMontserrat),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : null,
                                                                              ),
                                                                              if (feedController.activeReplyCommentId.value == c2.id)
                                                                                Row(
                                                                                  children: [
                                                                                    const SizedBox(width: 20),
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: GestureDetector(
                                                                                        onTap: () {
                                                                                          feedController.isCommentLoading.value = true;
                                                                                          feedController.activeReplyCommentId.value = '';
                                                                                          feedController.isCommentLoading.value = false;
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
                                                                                            controller: feedController.commentReplyEditTextController,
                                                                                            style: MyColors.l111111_dwhite(context).medium13,
                                                                                            decoration: InputDecoration(contentPadding: EdgeInsets.all(10.0.w), filled: true, hintText: MyStrings.writeAReply.tr, hintStyle: MyColors.lightGrey.medium13, fillColor: MyColors.noColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey)), focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(width: 0.05, color: MyColors.lightGrey))),
                                                                                          ),
                                                                                        )),
                                                                                    const SizedBox(width: 10),
                                                                                    Expanded(
                                                                                      flex: 1,
                                                                                      child: GestureDetector(
                                                                                        onTap: feedController.isReplyLoading.value
                                                                                            ? null
                                                                                            : () {
                                                                                                feedController.addReply(c2, index);
                                                                                              },
                                                                                        child: feedController.isReplyLoading.value
                                                                                            ? CupertinoActivityIndicator(
                                                                                                radius: 10, // Adjust the radius for size
                                                                                              ) // Show loading if true
                                                                                            : const Icon(Icons.send_outlined, color: MyColors.primaryLight),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              if ((c2.children ?? []).isNotEmpty)
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(left: 30.0.w),
                                                                                  child: ListView.builder(
                                                                                    itemCount: (c2.children ?? []).length,
                                                                                    padding: EdgeInsets.zero,
                                                                                    itemBuilder: (context, index) {
                                                                                      Comment reply = (c2.children ?? [])[index];
                                                                                      return ListTile(
                                                                                        contentPadding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                                                        title: Row(
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              onTap: () => reply.user?.role?.toLowerCase() == "client" ? Get.toNamed(Routes.individualSocialFeeds, arguments: reply.user) : Get.toNamed(Routes.employeeDetails, arguments: {'employeeId': reply.user?.id ?? ""}),
                                                                                              child: Text(
                                                                                                reply.user?.name != null && reply.user!.name!.length > 12 ? Utils.truncateCharacters(reply.user!.name ?? '', 12) : reply.user?.name ?? '',
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
                                                                                              Utils.formatDateTime(reply.createdAt ?? DateTime.now(), socialFeed: true),
                                                                                              style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: 12, color: MyColors.lightGrey),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        leading: feedController.editingReplyId.value == reply.id
                                                                                            ? GestureDetector(
                                                                                                onTap: () {
                                                                                                  feedController.onTapCancelCommentEditing();
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
                                                                                        subtitle: feedController.editingReplyId.value == reply.id
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Expanded(
                                                                                                    child: TextField(
                                                                                                      controller: feedController.commentReplyEditTextController,
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
                                                                                                    icon: feedController.isReplyLoading.value
                                                                                                        ? CupertinoActivityIndicator(
                                                                                                            radius: 10, // Adjust the radius for size
                                                                                                          )
                                                                                                        : Icon(Icons.send, color: MyColors.primaryLight),
                                                                                                    onPressed: feedController.isReplyLoading.value
                                                                                                        ? null
                                                                                                        : () async {
                                                                                                            feedController.updateCommentReply(feedController.socialPostList[index].id, c2.id, reply.id);
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
                                                                                        trailing: reply.user?.id == feedController.appController.user.value.userId
                                                                                            ? PopupMenuButton<String>(
                                                                                                onSelected: (value) {
                                                                                                  if (value == 'edit') {
                                                                                                    feedController.startEditingReply(c2.id!, reply);
                                                                                                  } else if (value == 'delete') {
                                                                                                    feedController.deleteCommentReply(feedController.socialPostList[index].id!, c2.id!, reply.id!);
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
                                                                                                          style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                                          style: TextStyle(fontFamily: MyAssets.fontMontserrat),
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
                                                                                )
                                                                            ],
                                                                          );
                                                                        },
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                          : SizedBox(),
                                                    ),*/
                                                  ],
                                                ),
                                              ),
                                            ),
                                            feedController.socialPostList[index]
                                                            .recommendation !=
                                                        null &&
                                                    feedController
                                                        .socialPostList[index]
                                                        .recommendation!
                                                        .isNotEmpty &&
                                                    feedController.appController
                                                        .user.value.isClient
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            top: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Plagit',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Klavika',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: MyColors
                                                                .primaryLight,
                                                          ),
                                                        ),
                                                        Text(
                                                          ' Candidates',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Klavika',
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: MyColors
                                                                .l111111_dwhite(
                                                                    context),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : SizedBox.shrink(),
                                            feedController.socialPostList[index]
                                                            .recommendation !=
                                                        null &&
                                                    feedController
                                                        .socialPostList[index]
                                                        .recommendation!
                                                        .isNotEmpty &&
                                                    feedController.appController
                                                        .user.value.isClient
                                                ? SizedBox(
                                                    height: 320,
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount: feedController
                                                          .socialPostList[index]
                                                          .recommendation!
                                                          .length,
                                                      itemBuilder:
                                                          (context, index1) {
                                                        final candidate =
                                                            feedController
                                                                .socialPostList[
                                                                    index]
                                                                .recommendation![index1];
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 16.0),
                                                          child: Card(
                                                            color: Colors.white,
                                                            elevation: 4,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          16),
                                                            ),
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: MyColors
                                                                    .lightCard(
                                                                        context),
                                                                border: Border.all(
                                                                    color: MyColors
                                                                        .noColor,
                                                                    width: 0.5),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              width: 250,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(16),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                    width: double
                                                                        .infinity,
                                                                    height: 150,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          200],
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image: ((candidate.profilePicture ?? "").isEmpty ||
                                                                                candidate.profilePicture == "undefined")
                                                                            ? AssetImage(candidate.role?.toUpperCase() == "ADMIN"
                                                                                ? MyAssets.adminDefault
                                                                                : candidate.role?.toUpperCase() == "CLIENT"
                                                                                    ? MyAssets.clientDefault
                                                                                    : MyAssets.employeeDefault)
                                                                            : NetworkImage((candidate.profilePicture ?? "").toString() == "" ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png" : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${candidate.profilePicture}"),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          8),
                                                                  Text(
                                                                    candidate.name !=
                                                                                null &&
                                                                            candidate.name!.length >
                                                                                17
                                                                        ? Utils.truncateCharacters(
                                                                            candidate.name ??
                                                                                '',
                                                                            17)
                                                                        : candidate.name ??
                                                                            '',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Klavika',
                                                                        fontSize:
                                                                            16,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: MyColors.l111111_dwhite(
                                                                            context)),
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        MyAssets
                                                                            .exp,
                                                                        width:
                                                                            14.w,
                                                                        height:
                                                                            14.w,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                5),
                                                                        child:
                                                                            Text(
                                                                          '${MyStrings.exp.tr}: ${candidate.employeeExperience} Years',
                                                                          style:
                                                                              TextStyle(fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Row(
                                                                    children: [
                                                                      SvgPicture
                                                                          .network(
                                                                        Data.getCountryFlagByName(candidate
                                                                            .countryName
                                                                            .toString()),
                                                                        width:
                                                                            10,
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          ("${candidate.countryName}")
                                                                              .toUpperCase(),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              MyColors.l111111_dwhite(context).regular11,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          4),
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        MyAssets
                                                                            .rate,
                                                                        width:
                                                                            14.w,
                                                                        height:
                                                                            14.w,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              5),
                                                                      Expanded(
                                                                        child:
                                                                            Text(
                                                                          ("${MyStrings.rate.tr} ${Utils.getCurrencySymbol()}${candidate.hourlyRate ?? 0}")
                                                                              .toUpperCase(),
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              MyColors.l111111_dwhite(context).regular11,
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
                                                                        onTap:
                                                                            () {
                                                                          Utils.showToast(
                                                                              message: 'coming soon',
                                                                              bgColor: Colors.red);
                                                                        },
                                                                        child: 1 !=
                                                                                1
                                                                            ? const SizedBox(
                                                                                width: 20,
                                                                                height: 20,
                                                                                child: Center(
                                                                                  child: CupertinoActivityIndicator(),
                                                                                ),
                                                                              )
                                                                            : 1 == 1
                                                                                ? Icon(
                                                                                    Icons.bookmark,
                                                                                    color: MyColors.c_C6A34F,
                                                                                    size: Get.width > 600 ? 35 : 25,
                                                                                  )
                                                                                : Icon(Icons.bookmark_outline_rounded, color: Colors.grey, size: Get.width > 600 ? 35 : 25),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            122.w,
                                                                        child: CustomButtons.button(
                                                                            height: 30,
                                                                            text: MyStrings.bookNow.tr,
                                                                            margin: EdgeInsets.zero,
                                                                            fontSize: 12.sp,
                                                                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                                                            onTap: () {
                                                                              Utils.showToast(message: 'coming soon', bgColor: Colors.red);
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
                                  });
                    } else {
                      return SliverToBoxAdapter(child: Offstage());
                    }
                  }),

                  Obx(() => SliverToBoxAdapter(
                      child: controller.selectedTabIndex.value == 2
                          ? Padding(
                              padding: EdgeInsets.all(15.0.w),
                              child: Column(
                                children: [
                                  InkResponse(
                                    onTap: controller.onHiredHistoryClick,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      margin: const EdgeInsets.only(top: 10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5,
                                              color: MyColors.noColor),
                                          borderRadius:
                                              BorderRadius.circular(10.84),
                                          color: MyColors.lightCard(context)),
                                      child: ListTile(
                                        leading: Image.asset(
                                            MyAssets.hiredHistory,
                                            height: 36.w,
                                            width: 36.w),
                                        title: Row(
                                          children: [
                                            Text(MyStrings.hiredHistory.tr,
                                                style: ResponsiveHelper.isTab(
                                                        Get.context)
                                                    ? MyColors.l111111_dwhite(
                                                            context)
                                                        .medium10
                                                    : MyColors.l111111_dwhite(
                                                            context)
                                                        .medium15),
                                            const SizedBox(width: 10),
                                            Obx(
                                              () => Visibility(
                                                visible: controller
                                                    .hiredHistoryList
                                                    .isNotEmpty,
                                                child: CustomBadge(
                                                  controller
                                                      .hiredHistoryList.length
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Image.asset(MyAssets.trailing,
                                            height: 25.h, width: 25.w),
                                      ),
                                    ),
                                  ),
                                  InkResponse(
                                    onTap: controller.onBookedHistoryClick,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10.0),
                                      margin: const EdgeInsets.only(top: 10.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5,
                                              color: MyColors.noColor),
                                          borderRadius:
                                              BorderRadius.circular(10.84),
                                          color: MyColors.lightCard(context)),
                                      child: ListTile(
                                        leading: Image.asset(
                                            MyAssets.bookedHistory,
                                            height: 36.w,
                                            width: 36.w),
                                        title: Row(
                                          children: [
                                            Text(MyStrings.bookedHistory.tr,
                                                style: ResponsiveHelper.isTab(
                                                        Get.context)
                                                    ? MyColors.l111111_dwhite(
                                                            context)
                                                        .medium10
                                                    : MyColors.l111111_dwhite(
                                                            context)
                                                        .medium15),
                                            const SizedBox(width: 10),
                                            Obx(
                                              () => Visibility(
                                                visible: controller
                                                    .bookingHistoryList
                                                    .isNotEmpty,
                                                child: CustomBadge(
                                                  controller
                                                      .bookingHistoryList.length
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Image.asset(MyAssets.trailing,
                                            height: 25.h, width: 25.w),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Offstage())),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 15.0.w,
                        right: 15.0.w,
                        top: 15.0.w,
                      ),
                      child: const EmployeeLocationWidget(),
                    ),
                  ),
                ],
              ),
              if (controller.isNewPostAvailable.value &&
                  controller.selectedTabIndex.value == 1)
                Align(
                  alignment: Alignment.topCenter,
                  child: Obx(() => GestureDetector(
                        onTap: () => controller.onRefresh(
                            refresh: true,
                            refreshLoader: true,
                            needToJumpTop: true),
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: MyColors.primaryLight,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              feedController.isNewPostLoading.value
                                  ? SizedBox(
                                      height: 16.h,
                                      width: 16.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.r,
                                        color: MyColors.white,
                                      ),
                                    )
                                  : Icon(
                                      CupertinoIcons.arrow_up_circle_fill,
                                      // Icons.arrow_circle_up_outlined,
                                      color: MyColors.white,
                                      size: 16,
                                    ),
                              SizedBox(width: 4.w),
                              Text(
                                "New Post",
                                style: MyColors.white.semiBold16,
                              ),
                            ],
                          ),
                        ),
                      )),
                ),
            ],
          ),
        ));
  }

  Widget _buildWorkSchedule() {
    return Obx(
      () => controller.todayWorkSchedule.value.todayWorkScheduleDetailsModel ==
              null
          ? const Wrap()
          : Padding(
              padding: EdgeInsets.only(
                left: 15.0.w,
                right: 15.0.w,
                top: 15.0.w,
              ),
              child: SizedBox(
                height: ResponsiveHelper.isTab(Get.context) ? 250 : 150,
                width: Get.width,
                child: Obx(
                  () => CarouselSlider(
                    options: CarouselOptions(
                      enableInfiniteScroll:
                          controller.employeeTodayList.length > 1
                              ? true
                              : false,
                      height: ResponsiveHelper.isTab(Get.context) ? 250 : 150,
                      viewportFraction: 1.0,
                    ),
                    items: controller.employeeTodayList,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildProfileProgress() {
    return Obx(
      () => Visibility(
        visible: controller.profileCompletionDataLoaded.value == true &&
            (controller.userProfileCompletionDetails.value?.profileCompleted ??
                    0) <
                80,
        child: Padding(
          padding: EdgeInsets.only(
            left: 15.0.w,
            top: 15.0.w,
            right: 15.0.w,
          ),
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.employeeEditProfile),
            child: EmployeeProgressIndicatorHomeWidget(
              progress: double.tryParse(
                    controller.userProfileCompletionDetails.value
                            ?.profileCompleted
                            .toString() ??
                        '0.0',
                  ) ??
                  0.0,
              message: controller.getProgressMessage(),
            ),
          ),
        ),
      ),
    );
  }
}

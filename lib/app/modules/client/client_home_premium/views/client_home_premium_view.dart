import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/models/saved_post_model.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_candidate_category_slider_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_header_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_tab_widget.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../common/data/data.dart';
import '../../../../common/local_storage/storage.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../common/style/my_decoration.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../../../../common/widgets/social_caption_widget.dart';
import '../../../../helpers/responsive_helper.dart';
import '../../../../models/dropdown_item.dart';
import '../../../common_modules/common_social_feed/controllers/common_social_feed_controller.dart';
import '../../../common_modules/common_social_feed/views/common_social_feed_view.dart';
import '../../../common_modules/splash/controllers/splash_controller.dart';
import '../../client_shortlisted/models/add_to_shortlist_request_model.dart';
import '../widgets/client_job_posts_widget.dart';
import '../widgets/client_progress_indicator_home.dart';

class ClientHomePremiumView extends GetView<ClientHomePremiumController> {
  ClientHomePremiumView({super.key});
  final feedController = Get.put(
    CommonSocialFeedController(socialFeedRepository: Get.find()),
  );

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    // Ensure tutorial is created only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((Storage.getValue<String>('isFirstTimeOpen') ?? '') == '') {
        if (controller.alreadyCreatedTutorial.value == 0) {
          _createTutorial();
          _showTutorial(controller.context);
        }
      }
    });

    return Obx(() => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppbar.appbar(
            context: context,
            onRefresh: controller.onRefresh,
            title: MyStrings.home.tr,
            isPlagItPlus: false,
            centerTitle: false,
            visibleBack: false,
            actions: [
              SizedBox(width: 10.w),

              InkResponse(
                key: controller.keySearch,
                onTap: () => Get.toNamed(Routes.commonSearch),
                child: Image.asset(MyAssets.search,
                    height: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                    width: ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                    color: MyColors.l111111_dwhite(context)),
              ),
              SizedBox(
                  width: ResponsiveHelper.isTab(Get.context) ? 10.w : 30.w),
              // const LanguageDropdown(),
              // SizedBox(width: 10.w),
              Obx(() {
                int count =
                    controller.notificationsController.unreadCount.value;
                return GestureDetector(
                  key: controller.keyNotifications,
                  onTap: () => Get.toNamed(Routes.notifications),
                  child: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: MyColors.c_C6A34F,
                    label: Text(
                      count >= 20
                          ? '20+'
                          : count == 0
                              ? ''
                              : count.toString(),
                      style: TextStyle(
                          fontSize: Get.width > 600 ? 13 : 12,
                          color: MyColors.white,
                          fontFamily: MyAssets.fontKlavika),
                    ),
                    child: Image.asset(MyAssets.bell,
                        height:
                            ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                        width:
                            ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                        color: MyColors.l111111_dwhite(context)),
                  ),
                );
              }),
              SizedBox(
                  width: ResponsiveHelper.isTab(Get.context) ? 10.w : 30.w),
              Obx(() {
                int msgCount =
                    Get.find<ClientHomeController>().unreadMessages.value;
                return InkResponse(
                  key: controller.keyMessages,
                  onTap: () => Get.toNamed(Routes.chatIt),
                  child: Badge(
                    isLabelVisible: msgCount > 0,
                    backgroundColor: MyColors.c_C6A34F,
                    label: Text(msgCount > 0 ? msgCount.toString() : '',
                        style: TextStyle(
                            fontSize: Get.width > 600 ? 13 : 12,
                            color: MyColors.white,
                            fontFamily: MyAssets.fontKlavika)),
                    child: Image.asset(MyAssets.chat,
                        height:
                            ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                        width:
                            ResponsiveHelper.isTab(Get.context) ? 15.w : 25.w,
                        color: MyColors.l111111_dwhite(context)),
                  ),
                );
              }),
              SizedBox(
                  width: ResponsiveHelper.isTab(Get.context) ? 10.w : 20.w),
            ],
          ),
          body: RefreshIndicator(
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
                    // Sliver for profile progress section
                    SliverToBoxAdapter(
                      child: Obx(() => Visibility(
                            visible: (controller.userProfileCompletionDetails
                                            .value?.profileCompleted ??
                                        0) <
                                    80 &&
                                controller.socialPostDataLoaded.value == true,
                            child: Padding(
                              padding: EdgeInsets.all(15.0.w),
                              child: GestureDetector(
                                onTap: () =>
                                    Get.toNamed(Routes.clientEditProfile),
                                child: ClientProgressIndicatorHomeWidget(
                                  message: controller.getProgressMessage(),
                                  progress: (controller
                                              .userProfileCompletionDetails
                                              .value
                                              ?.profileCompleted ??
                                          0) -
                                      0,
                                ),
                              ),
                            ),
                          )),
                    ),

                    // Sliver for ClientHomePremiumHeaderWidget
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(15.0.w),
                        child: const ClientHomePremiumHeaderWidget(),
                      ),
                    ),

                    // Sliver for ClientHomePremiumCandidateCategorySliderWidget
                    SliverToBoxAdapter(
                      child: Obx(
                        () => Visibility(
                          visible: controller.selectedTabIndex.value != 0,
                          child: Padding(
                            padding: EdgeInsets.all(15.0.w),
                            child:
                                const ClientHomePremiumCandidateCategorySliderWidget(),
                          ),
                        ),
                      ),
                    ),

                    // SliverList for suggested employees and shortlisted employees
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _suggestedEmployees,
                        _employeeShortlisted,
                      ]),
                    ),

                    // Sliver for ClientHomePremiumTabWidget and ClientHomePremiumTabItemWidget
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 15.0.w, right: 15.0.w, bottom: 10.0.w),
                        child: const ClientHomePremiumTabWidget(),
                      ),
                    ),

                    Obx(() => SliverToBoxAdapter(
                        child: controller.selectedTabIndex.value == 0
                            ? Padding(
                                padding: EdgeInsets.only(bottom: 120),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GridView.builder(
                                    itemCount: controller.positionList.length,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      childAspectRatio: 1.6,
                                    ),
                                    itemBuilder: (context, index) {
                                      return _item(
                                          controller.positionList[index]);
                                    },
                                  ),
                                ))
                            : Offstage())),

                    Obx(() {
                      if (controller.selectedTabIndex.value == 1) {
                        return feedController.isSocialFeedLoading.value
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child:
                                      ShimmerWidget.socialPostShimmerWidget(),
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
                                          onVisibilityChanged:
                                              (visibilityInfo) {
                                            if (visibilityInfo.visibleFraction >
                                                0.5) {
                                              if (!feedController
                                                  .isPostCurrentlyVisible(
                                                      index)) {
                                                feedController
                                                    .markPostAsVisible(index);
                                                feedController
                                                    .incrementPostViews(
                                                        feedController
                                                                .socialPostList[
                                                                    index]
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
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
                                                                  right:
                                                                      15.0.w),
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
                                                                  right:
                                                                      15.0.w),
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
                                                        (feedController.socialPostList[index].media ??
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
                                                      //             .socialPostList[
                                                      //         index],
                                                      //     feedController
                                                      //         .appController
                                                      //         .user
                                                      //         .value
                                                      //         .userId,
                                                      //     feedController,
                                                      //     index),
                                                      SizedBox(height: 10.w),
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
                                                                      .client
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

                                                      ///Comments
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
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SizedBox(
                                                                            height:
                                                                                15.h),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 10,
                                                                              child: SizedBox(
                                                                                height: 40,
                                                                                child: buildCommentTextField(context, feedController),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 10.w),
                                                                            buildCommentButton(context,
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
                                                                              (BuildContext context, int indexRC) {
                                                                            final comments =
                                                                                feedController.socialPostList[index].comments ?? [];
                                                                            if (indexRC >=
                                                                                comments.length)
                                                                              return const SizedBox();
                                                                            Comment
                                                                                c1 =
                                                                                comments[indexRC];
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
                                                                                                fontFamily: MyAssets.fontMontserrat,
                                                                                                fontSize: 13,
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
                                                                                                  fontSize: 13,
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
                                                                                      itemBuilder: (context, indexRCC) {
                                                                                        final replies = c1.children ?? [];
                                                                                        if (indexRCC >= replies.length) return const SizedBox();
                                                                                        Comment reply = replies[indexRCC];
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
                                                                                                      feedController.startEditingReply(c1.id!, reply);
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
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SizedBox(
                                                                            height:
                                                                                15.h),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 10,
                                                                              child: SizedBox(
                                                                                height: 40,
                                                                                child: buildCommentTextField(context, feedController),
                                                                              ),
                                                                            ),
                                                                            SizedBox(width: 10.w),
                                                                            buildCommentButton(context,
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
                                                                              (BuildContext context, int indexC) {
                                                                            final comments =
                                                                                feedController.socialPostList[index].comments ?? [];
                                                                            if (indexC >=
                                                                                comments.length)
                                                                              return const SizedBox();
                                                                            Comment
                                                                                c2 =
                                                                                comments[indexC];
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
                                                                                                  feedController.addReply(c2, indexC);
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
                                                                                      itemBuilder: (context, indexRRR) {
                                                                                        final replies = c2.children ?? [];
                                                                                        if (indexRRR >= replies.length) return const SizedBox();
                                                                                        Comment reply = replies[indexRRR];
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
                                                                                                    fontSize: 13,
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

                                                      ///
                                                      if (feedController
                                                                  .socialPostList[
                                                                      index]
                                                                  .user
                                                                  ?.role
                                                                  ?.toUpperCase() ==
                                                              "EMPLOYEE" &&
                                                          feedController
                                                                  .appController
                                                                  .user
                                                                  .value
                                                                  .client
                                                                  ?.countryName ==
                                                              feedController
                                                                  .socialPostList[
                                                                      index]
                                                                  .user
                                                                  ?.countryName)
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 15.0.w,
                                                                  right: 15.w,
                                                                  top: 20.0.w),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 18,
                                                                backgroundColor:
                                                                    MyColors
                                                                        .noColor,
                                                                child: SvgPicture
                                                                    .network(
                                                                  Data.getCountryFlagByName(feedController
                                                                          .socialPostList[
                                                                              index]
                                                                          .user
                                                                          ?.countryName
                                                                          .toString() ??
                                                                      ''),
                                                                  width: 10,
                                                                  height: 10,
                                                                ),
                                                                // backgroundImage:
                                                                // ((feedController.socialPostList[index].user?.profilePicture ??
                                                                //                 "")
                                                                //             .isEmpty ||
                                                                //         feedController.socialPostList[index].user?.profilePicture ==
                                                                //             "undefined")
                                                                //     ? AssetImage(feedController
                                                                //                 .socialPostList[
                                                                //                     index]
                                                                //                 .user
                                                                //                 ?.role
                                                                //                 ?.toUpperCase() ==
                                                                //             "ADMIN"
                                                                //         ? MyAssets
                                                                //             .adminDefault
                                                                //         : feedController.socialPostList[index].user?.role?.toUpperCase() ==
                                                                //                 "CLIENT"
                                                                //             ? MyAssets
                                                                //                 .clientDefault
                                                                //             : MyAssets
                                                                //                 .employeeDefault)
                                                                //     : NetworkImage(
                                                                //         (feedController.socialPostList[index].user?.profilePicture ?? "").toString() ==
                                                                //                 ""
                                                                //             ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png"
                                                                //             : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${feedController.socialPostList[index].user?.profilePicture}")
                                                                //
                                                              ),
                                                              SizedBox(
                                                                  width: 10.w),
                                                              Expanded(
                                                                child: RichText(
                                                                  text:
                                                                      TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            '${feedController.socialPostList[index].user?.name} ',
                                                                        style: TextStyle(
                                                                            fontFamily: MyAssets
                                                                                .fontMontserrat,
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: MyColors.l111111_dwhite(context)),
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            "is available near you!",
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              MyAssets.fontMontserrat,
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              MyColors.dividerColor,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 122.w,
                                                                child: CustomButtons
                                                                    .button(
                                                                        height:
                                                                            30,
                                                                        text: MyStrings
                                                                            .bookNow
                                                                            .tr,
                                                                        margin: EdgeInsets
                                                                            .zero,
                                                                        fontSize: 12
                                                                            .sp,
                                                                        customButtonStyle:
                                                                            CustomButtonStyle
                                                                                .radiusTopBottomCorner,
                                                                        onTap:
                                                                            () {
                                                                          feedController.onBookNowClick(feedController
                                                                              .socialPostList[index]
                                                                              .user
                                                                              ?.id);
                                                                          // Utils.showToast(
                                                                          //     message:
                                                                          //         'coming soon',
                                                                          //     bgColor:
                                                                          //         Colors.red);
                                                                        }),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              feedController
                                                              .socialPostList[
                                                                  index]
                                                              .recommendation !=
                                                          null &&
                                                      feedController
                                                          .socialPostList[index]
                                                          .recommendation!
                                                          .isNotEmpty &&
                                                      feedController
                                                          .appController
                                                          .user
                                                          .value
                                                          .isClient
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
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: MyColors
                                                                  .primaryLight,
                                                            ),
                                                          ),
                                                          Text(
                                                            ' Candidates',
                                                            style: TextStyle(
                                                              fontFamily: MyAssets
                                                                  .fontMontserrat,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: MyColors
                                                                  .l111111_dwhite(
                                                                      context),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                              feedController
                                                              .socialPostList[
                                                                  index]
                                                              .recommendation !=
                                                          null &&
                                                      feedController
                                                          .socialPostList[index]
                                                          .recommendation!
                                                          .isNotEmpty &&
                                                      feedController
                                                          .appController
                                                          .user
                                                          .value
                                                          .isClient
                                                  ? SizedBox(
                                                      height: Get.width > 600
                                                          ? 300.h
                                                          : 200, // Increased height for tablets
                                                      child: ListView.builder(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        itemCount:
                                                            feedController
                                                                .socialPostList[
                                                                    index]
                                                                .recommendation!
                                                                .length,
                                                        itemBuilder:
                                                            (context, index1) {
                                                          final candidate =
                                                              feedController
                                                                  .socialPostList[
                                                                      index]
                                                                  .recommendation![index1];
                                                          return InkWell(
                                                            onTap: () =>
                                                                Get.toNamed(
                                                                    Routes
                                                                        .employeeDetails,
                                                                    arguments: {
                                                                  'employeeId':
                                                                      candidate
                                                                              .id ??
                                                                          ""
                                                                }),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                  right:
                                                                      Get.width >
                                                                              600
                                                                          ? 10.w
                                                                          : 5.0),
                                                              child: Card(
                                                                color: Colors
                                                                    .white,
                                                                elevation: 4,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              16),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: MyColors
                                                                        .lightCard(
                                                                            context),
                                                                    border: Border.all(
                                                                        color: MyColors
                                                                            .noColor,
                                                                        width:
                                                                            0.5),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  width: Get.width >
                                                                          600
                                                                      ? 300.w
                                                                      : 210, // Wider cards for tablets
                                                                  padding: EdgeInsets.all(
                                                                      Get.width >
                                                                              600
                                                                          ? 20.w
                                                                          : 16),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          CircleAvatar(
                                                                            radius: Get.width > 600
                                                                                ? 25
                                                                                : 18, // Larger avatar for tablets
                                                                            backgroundColor:
                                                                                MyColors.noColor,
                                                                            backgroundImage: ((candidate.profilePicture ?? "").isEmpty || candidate.profilePicture == "undefined")
                                                                                ? AssetImage(candidate.role?.toUpperCase() == "ADMIN"
                                                                                    ? MyAssets.adminDefault
                                                                                    : candidate.role?.toUpperCase() == "CLIENT"
                                                                                        ? MyAssets.clientDefault
                                                                                        : MyAssets.employeeDefault)
                                                                                : NetworkImage((candidate.profilePicture ?? "").toString() == "" ? "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460__340.png" : "https://d1ew68mie4ej5v.cloudfront.net/public/users/profile/${candidate.profilePicture}"),
                                                                          ),
                                                                          SizedBox(
                                                                              width: Get.width > 600 ? 15.w : 10.w),
                                                                          Flexible(
                                                                            child:
                                                                                Text(
                                                                              candidate.name != null && candidate.name!.length > (Get.width > 600 ? 25 : 17) ? Utils.truncateCharacters(candidate.name ?? '', Get.width > 600 ? 25 : 17) : candidate.name ?? '',
                                                                              style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: Get.width > 600 ? 18.sp : 16, fontWeight: FontWeight.bold, color: MyColors.l111111_dwhite(context)),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: Get.width > 600
                                                                              ? 12.h
                                                                              : 8),
                                                                      SizedBox(
                                                                          height: Get.width > 600
                                                                              ? 8.h
                                                                              : 4),
                                                                      Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            MyAssets.exp,
                                                                            width: Get.width > 600
                                                                                ? 18.w
                                                                                : 14.w,
                                                                            height: Get.width > 600
                                                                                ? 18.w
                                                                                : 14.w,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.only(left: Get.width > 600 ? 8 : 5),
                                                                            child:
                                                                                Text(
                                                                              '${MyStrings.exp.tr} ${candidate.employeeExperience} Years',
                                                                              style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: Get.width > 600 ? 13.sp : 11, fontWeight: FontWeight.w500, color: MyColors.l111111_dwhite(context)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: Get.width > 600
                                                                              ? 8.h
                                                                              : 4),
                                                                      Row(
                                                                        children: [
                                                                          SvgPicture
                                                                              .network(
                                                                            Data.getCountryFlagByName(candidate.countryName.toString()),
                                                                            width: Get.width > 600
                                                                                ? 14.w
                                                                                : 10.w,
                                                                            height: Get.width > 600
                                                                                ? 14.w
                                                                                : 10.w,
                                                                          ),
                                                                          SizedBox(
                                                                              width: Get.width > 600 ? 8 : 5),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              ("${candidate.countryName}").toUpperCase(),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: Get.width > 600 ? 13.sp : 11, fontWeight: FontWeight.w500, color: MyColors.l111111_dwhite(context)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height: Get.width > 600
                                                                              ? 8.h
                                                                              : 4),
                                                                      Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            MyAssets.rate,
                                                                            width: Get.width > 600
                                                                                ? 18.w
                                                                                : 14.w,
                                                                            height: Get.width > 600
                                                                                ? 18.w
                                                                                : 14.w,
                                                                          ),
                                                                          SizedBox(
                                                                              width: 5),
                                                                          Expanded(
                                                                            child:
                                                                                Text(
                                                                              ("${MyStrings.rate.tr}: ${Utils.getCurrencySymbol()}${candidate.hourlyRate ?? 0}").toUpperCase(),
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: TextStyle(fontFamily: MyAssets.fontMontserrat, fontSize: Get.width > 600 ? 13.sp : 11, fontWeight: FontWeight.w500, color: MyColors.l111111_dwhite(context)),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const Spacer(),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          Obx(
                                                                            () => feedController.shortlistController.getIcon(
                                                                                requestedDateList: <RequestDateModel>[],
                                                                                employeeId: candidate.id!,
                                                                                isFetching: feedController.shortlistController.isFetching.value,
                                                                                fromWhere: '',
                                                                                uniformMandatory: false),
                                                                          ),
                                                                          SizedBox(
                                                                            width: Get.width > 600
                                                                                ? 150.w
                                                                                : 122.w,
                                                                            child: CustomButtons.button(
                                                                                height: Get.width > 600 ? 40 : 30,
                                                                                text: MyStrings.bookNow.tr,
                                                                                margin: EdgeInsets.zero,
                                                                                fontSize: Get.width > 600 ? 14.sp : 12.sp,
                                                                                customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                                                                                onTap: () {
                                                                                  feedController.onBookNowClick(candidate.id);
                                                                                }),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
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
                                child: const ClientJobPostsWidget(),
                                // child: const CommonJobPostsView(userType: 'client',isMyJobPost: true,),
                              )
                            : Offstage())),
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
          ),
          // floatingActionButton: controller.isNewPostAvailable.value &&
          //         controller.selectedTabIndex.value == 1
          //     ? Padding(
          //         padding:
          //             EdgeInsets.only(bottom: Platform.isIOS ? 100.0 : 60.0),
          //         child: FloatingActionButton(
          //           backgroundColor: MyColors.primaryDark,
          //           mini: true,
          //           onPressed: () {
          //             controller.onRefresh();
          //           },
          //           child: Icon(
          //             CupertinoIcons.refresh,
          //             size: 20,
          //           ),
          //         ),
          //       )
          //     : null,
        ));
  }

  void _showTutorial(context) {
    controller.tutorialCoachMark.show(context: context);
  }

  void _createTutorial() {
    controller.tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: MyColors.primaryDark,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
        StorageHelper.setFirstTimeLogin(isFirstTime: 'No');
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        StorageHelper.setFirstTimeLogin(isFirstTime: 'No');
        return true;
      },
    );
    controller.alreadyCreatedTutorial(1);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Search",
        keyTarget: controller.keySearch,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Tap here to search.\nFind what you need instantly! Use our powerful search feature to quickly discover different profile content, jobs, or social posts.",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyAssets.fontKlavika,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Notifications",
        keyTarget: controller.keyNotifications,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Check your notifications here.\n You will get Candidate Check in Check out Notification, also Social Post Updates and Payment Updates as well as new tips notification from admin",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyAssets.fontKlavika,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Messages",
        keyTarget: controller.keyMessages,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Check your messages here.\nStay connected! Chat in real time with Contractors, Business, or Admin Support.",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyAssets.fontKlavika,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Dashboard",
        keyTarget: controller.keyDashboard,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "\n\n\nIn Dashboard\nYou can see your hired candidates check in check out histories also can change their time log and give feedback",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyAssets.fontKlavika,
                  fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "MyCandidate",
        keyTarget: controller.keyMyCandidate,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "\n\n\nIn My candidates\nYou can find your hired and short listed candidates as well as you can message them directly, also can rebook them",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: MyAssets.fontKlavika,
                  fontSize: 18),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _item(DropdownItem position) {
    return Center(
      child: Container(
        width: 182.w,
        height: 112.w,
        decoration:
            MyDecoration.cardBoxDecoration(context: controller.context!),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(10.0),
            onTap: () => controller.onPositionClick(position),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.w,
                  child: CustomNetworkImage(
                      url: (position.logo ?? '').uniformImageUrl),
                ),
                SizedBox(height: 9.h),
                Text(
                  position.name ?? "-",
                  style: Get.width > 600
                      ? MyColors.l111111_dwhite(controller.context!).medium12
                      : MyColors.l111111_dwhite(controller.context!).medium14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _suggestedEmployees => Obx(
        () => Visibility(
          visible:
              Get.find<ClientHomeController>().countTotalRequestedEmployees() >
                  0,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15.0.w,
              right: 15.0.w,
              top: 10.0.w,
              bottom: 10.0.w,
            ),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: Get.find<ClientHomeController>()
                      .onSuggestedEmployeesClick,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    margin: EdgeInsets.only(bottom: 15.0.w),
                    decoration: BoxDecoration(
                        border: Border.all(color: MyColors.noColor, width: 0.5),
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: Utils.primaryGradient),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Get.find<ClientHomeController>().countTotalRequestedEmployees()} ${MyStrings.candidates.tr} ${MyStrings.areRequested.tr}",
                                style: Get.width > 600
                                    ? MyColors.white.semiBold13
                                    : MyColors.white.semiBold12,
                              ),
                              SizedBox(height: 7.h),
                              Text(
                                "${AppInfo.appName.toUpperCase()} ${MyStrings.suggestYou.tr} ${Get.find<ClientHomeController>().countSuggestedEmployees()} ${MyStrings.candidates.tr}",
                                style: Get.width > 600
                                    ? (MyColors.white.regular9)
                                        .copyWith(fontSize: 12.sp)
                                    : MyColors.white.regular10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.c_C6A34F,
                          ),
                          child: Icon(Icons.arrow_forward,
                              color: MyColors.white,
                              size: Get.width > 600 ? 16.sp : 15),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.find<ClientHomeController>()
                          .deleteAllRequestsFromClient();
                      // controller.isRequestRemove.value = true; // Update the state
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );

  Widget get _employeeShortlisted => Obx(
        () => Visibility(
          visible: Get.find<ClientHomeController>()
                  .shortlistController
                  .totalShortlisted
                  .value >
              0,
          child: Padding(
            padding:
                EdgeInsets.only(left: 15.0.w, right: 15.0.w, bottom: 10.0.w),
            child: Stack(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: Get.find<ClientHomeController>().onShortlistClick,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: Utils.primaryGradient),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Get.find<ClientHomeController>().shortlistController.totalShortlisted.value} ${Get.find<ClientHomeController>().shortlistController.totalShortlisted.value > 1 ? MyStrings.candidates.tr : MyStrings.candidate.tr} ${MyStrings.areShortListed.tr}",
                                style: Get.width > 600
                                    ? MyColors.white.semiBold13
                                    : MyColors.white.semiBold12,
                              ),
                              SizedBox(height: 7.h),
                              Text(
                                MyStrings.hireThem.tr,
                                style: Get.width > 600
                                    ? MyColors.white.regular9
                                    : MyColors.white.regular10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.c_C6A34F,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: MyColors.white,
                            size: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.find<ClientHomeController>()
                          .shortlistController
                          .deleteAllShortList();
                      // controller.isShortListRemove.value = true; // Update the state
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
}

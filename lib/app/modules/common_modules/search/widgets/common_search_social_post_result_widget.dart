import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

import '../../../../common/values/my_assets.dart';
import '../../../../common/values/my_color.dart';
import '../../../../common/widgets/social_post_widget.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/common_search_controller.dart';

class CommonSocialFeedSearchResultWidget
    extends GetWidget<CommonSearchController> {
  const CommonSocialFeedSearchResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=>controller.socialPostList.isNotEmpty
        ? SingleChildScrollView(
      controller: controller.scrollController,
      child: ListView.builder(
          itemCount: controller.socialPostList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          primary: false,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            if (index == controller.socialPostList.length - 1 &&
                controller.moreSocialDataAvailable.value ==
                    true) {
              return SpinKitThreeBounce(
                color: MyColors.primaryLight,
                size: 30,
              );
            }
            SocialPostModel s = controller.socialPostList[index];
            return Obx(()=>SocialPostWidget(
              socialPost: s,
              addReport: controller.addReport,
              repost: controller.repost,
              blockUserAndRefreshSocialFeed: () =>
                  controller.blockUserAndRefreshSocialFeed(
                      userId: s.user?.id ?? ""),
              react: () =>
                  controller.reactPost(postId: s.id ?? "", index: index),
              save: () => controller.commonSocialFeedController
                  .savePost(s.id.toString()),
              isSave: controller.commonSocialFeedController
                  .isPostSaved(s.id.toString()),
              deleteSavePost: () => controller.commonSocialFeedController
                  .deleteSavePost(savedPostList
                  .firstWhere(
                      (post) => post.post?.id == s.id.toString(),
                  orElse: () => SavedPostModel())
                  .id ??
                  ""),
              commonSocialFeedController: controller.commonSocialFeedController,
            ));
          }),
    )
        : const Center(child: Text('No post found.',
      style:TextStyle(fontFamily: MyAssets.fontKlavika),)));
  }
}

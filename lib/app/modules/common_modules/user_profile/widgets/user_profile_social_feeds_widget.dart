import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/common/widgets/social_post_widget.dart';
import 'package:mh/app/models/social_feed_response_model.dart';

import '../../../../models/saved_post_model.dart';
import '../../splash/controllers/splash_controller.dart';
import '../controllers/user_profile_controller.dart';

class UserProfileSocialFeedsWidget extends GetWidget<UserProfileController> {
  const UserProfileSocialFeedsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Obx(() {
      if (controller.socialPostDataLoaded.value == false) {
        return Center(child: ShimmerWidget.socialPostShimmerWidget());
      } else if (controller.socialPostDataLoaded.value == true &&
          controller.socialPostList.isEmpty) {
        return const Center(child: NoItemFound());
      } else {
        return ListView.builder(
            itemCount: controller.socialPostList.length,
            shrinkWrap: true,
            controller: controller.scrollController,
            padding: EdgeInsets.zero,
            itemBuilder: (BuildContext context, int index) {
              if (index == controller.socialPostList.length - 1 &&
                  controller.moreSocialPostsAvailable.value == true) {
                return const SpinKitThreeBounce(
                  color: MyColors.primaryLight,
                  size: 30,
                );
              }
              SocialPostModel s = controller.socialPostList[index];
              return Obx(() => Padding(
                    padding: EdgeInsets.only(top: 10.0.w),
                    child: SocialPostWidget(
                      socialPost: s,
                      fullView: true,
                      isDetails: true,
                      addReport: controller.addReport,
                      repost: controller.repost,
                      blockUserAndRefreshSocialFeed: () =>
                          controller.blockUserAndRefreshSocialFeed(
                              userId: s.user?.id ?? ""),
                      react: () => controller.reactPost(
                          postId: s.id ?? "", index: index),
                      save: () => controller.commonSocialFeedController
                          .savePost(s.id.toString()),
                      isSave: controller.commonSocialFeedController
                          .isPostSaved(s.id.toString()),
                      deleteSavePost: () => controller
                          .commonSocialFeedController
                          .deleteSavePost(savedPostList
                                  .firstWhere(
                                      (post) =>
                                          post.post?.id == s.id.toString(),
                                      orElse: () => SavedPostModel())
                                  .id ??
                              ""),
                      commonSocialFeedController:
                          controller.commonSocialFeedController,
                    ),
                  ));
            });
      }
    });
  }
}

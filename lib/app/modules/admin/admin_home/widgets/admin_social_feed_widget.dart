import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/common/widgets/social_post_widget.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';

import '../../../../models/saved_post_model.dart';
import '../../../common_modules/splash/controllers/splash_controller.dart';

class AdminSocialFeedWidget extends GetWidget<AdminHomeController> {
  const AdminSocialFeedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(bottom: 120.h),
      child: Obx(() {
        if (controller.socialPostDataLoaded.value == false) {
          return Center(child: ShimmerWidget.socialPostShimmerWidget());
        } else if (controller.socialPostDataLoaded.value == true &&
            controller.socialPostList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return ListView.builder(
              itemCount: controller.socialPostList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              primary: false,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                if (index == controller.socialPostList.length - 1 &&
                    controller.moreSocialDataAvailable.value == true) {
                  return const SpinKitThreeBounce(
                    color: MyColors.primaryLight,
                    size: 30,
                  );
                }
                SocialPostModel s = controller.socialPostList[index];
                return SocialPostWidget(
                  socialPost: s,
                  inActivePost: controller.inActivePost,
                  deletePost: controller.deletePost,
                  addReport: controller.addReport,
                  repost: controller.repost,
                  blockUserAndRefreshSocialFeed: () => controller
                      .blockUserAndRefreshSocialFeed(userId: s.user?.id ?? ""),
                  react: () =>
                      controller.reactPost(postId: s.id ?? "", index: index),
                  save: () => controller.commonSocialFeedController
                      .savePost(s.id.toString()),
                  isSave: controller.commonSocialFeedController.isPostSaved(
                      s.id.toString()),
                  deleteSavePost: () => controller.commonSocialFeedController
                      .deleteSavePost(savedPostList
                      .firstWhere(
                          (post) =>
                      post.post?.id ==
                          s.id.toString(),
                      orElse: () => SavedPostModel())
                      .id ??
                      ""),
                  commonSocialFeedController: controller.commonSocialFeedController,
                );
              });
        }
      }),
    ));
  }
}

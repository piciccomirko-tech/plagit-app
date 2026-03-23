
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../common/widgets/shimmer_widget.dart';
import '../../../../common/widgets/social_post_widget.dart';
import '../../../../models/saved_post_model.dart';
import '../controllers/client_saved_post_controller.dart';

class ClientSavedPostView extends GetView<ClientSavedPostController> {
  const ClientSavedPostView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.mySavedPost.tr,
        context: context,
      ),
      body: Obx(() {
        if (controller.savedPostDataLoaded.value == false) {
          return Padding(
            padding: EdgeInsets.all(15.0.w),
            child: Center(child: ShimmerWidget.socialPostShimmerWidget()),
          );
        } else if (controller.savedPostDataLoaded.value == true &&
            controller.savedPostList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return RefreshIndicator(
              onRefresh: controller.onRefresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                // controller: controller.scrollController,
                slivers: [
                  SliverList.builder(
                      itemCount: controller.savedPostList.length,
                      itemBuilder: (BuildContext context, int index) {
                        SavedPostModel s = controller.savedPostList[index];
                        return Obx(() => Padding(
                              padding: EdgeInsets.only(bottom: 5.0.w),
                              child: SocialPostWidget(
                                socialPost: s.post!,
                                addReport: controller.addReport,
                                repost: controller.repost,
                                blockUserAndRefreshSocialFeed: () =>
                                    controller.blockUserAndRefreshSocialFeed(
                                        userId: s.post?.user?.id ?? ""),
                                followUnfollow: () => controller
                                    .followUnfollow(s.post?.user?.id ?? ""),
                                react: () => controller.reactPost(
                                    postId: s.post?.id ?? "", index: index),
                                save: () => controller
                                    .commonSocialFeedController
                                    .savePost(s.post!.id.toString()),
                                isSave: controller.commonSocialFeedController
                                    .isPostSaved(s.post!.id.toString()),
                                deleteSavePost: () {
                                  controller.commonSocialFeedController
                                      .deleteSavePost(controller.savedPostList
                                              .firstWhere(
                                                  (post) =>
                                                      post.id ==
                                                      s.id.toString(),
                                                  orElse: () =>
                                                      SavedPostModel())
                                              .id ??
                                          "")
                                      .then((v) => controller.getSavedPost());
                                },
                                commonSocialFeedController: controller.commonSocialFeedController,
                              ),
                            ));
                      })
                ],
              ));
        }
      }),
    );
  }
}

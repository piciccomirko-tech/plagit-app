import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/common/widgets/social_post_widget.dart';
import 'package:mh/app/models/social_feed_response_model.dart';
import 'package:mh/app/modules/common_modules/my_social_feed/controllers/my_social_feed_controller.dart';
import '../../../../models/saved_post_model.dart';
import '../../../../routes/app_pages.dart';
import '../../splash/controllers/splash_controller.dart';

class MySocialFeedView extends GetView<MySocialFeedController> {
  const MySocialFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
          radius: 0.0,
          title: MyStrings.mySocialPost.tr,
          context: context,
          centerTitle: true),
      body: Obx(() {
        if (controller.socialPostDataLoaded.value == false) {
          return Padding(
            padding: EdgeInsets.all(15.0.w),
            child: Center(child: ShimmerWidget.socialPostShimmerWidget()),
          );
        } else if (controller.socialPostDataLoaded.value == true &&
            controller.socialPostList.isEmpty) {
          return const Center(child: NoItemFound());
        } else {
          return RefreshIndicator(
              onRefresh: controller.onRefresh,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                controller: controller.scrollController,
                slivers: [
                  SliverList.builder(
                      itemCount: controller.socialPostList.length,
                      // physics: NeverScrollableScrollPhysics(),
                      // primary: false,
                      // shrinkWrap: true,
                      // padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == controller.socialPostList.length - 1 &&
                            controller.moreDataAvailable.value == true) {
                          return const SpinKitThreeBounce(
                            color: MyColors.primaryLight,
                            size: 30,
                          );
                        }
                        SocialPostModel s = controller.socialPostList[index];
                        return Obx(() => Padding(
                              padding: EdgeInsets.only(bottom: 5.0.w),
                              child: SocialPostWidget(
                                socialPost: s,
                                fullView: true,
                                isDetails: true,
                                deletePost: controller.deletePost,
                                inActivePost: controller.inActivePost,
                                addReport: controller.addReport,
                                repost: controller.repost,
                                blockUserAndRefreshSocialFeed: () =>
                                    controller.blockUserAndRefreshSocialFeed(
                                        userId: s.user?.id ?? ""),
                                react: () => controller.reactPost(
                                    postId: s.id ?? "", index: index),
                                save: () => controller
                                    .commonSocialFeedController
                                    .savePost(s.id.toString()),
                                isSave: controller.commonSocialFeedController
                                    .isPostSaved(s.id.toString()),
                                deleteSavePost: () => controller
                                    .commonSocialFeedController
                                    .deleteSavePost(savedPostList
                                            .firstWhere(
                                                (post) =>
                                                    post.post?.id ==
                                                    s.id.toString(),
                                                orElse: () => SavedPostModel())
                                            .id ??
                                        ""),
                                commonSocialFeedController:
                                    controller.commonSocialFeedController,
                              ),
                            ));
                      })
                ],
              )
              // child: ListView.builder(
              //     itemCount: controller.socialPostList.length,
              //     shrinkWrap: true,
              //     controller: controller.scrollController,
              //     padding: EdgeInsets.zero,
              //     physics: const BouncingScrollPhysics(),
              //     itemBuilder: (BuildContext context, int index) {
              //       if (index == controller.socialPostList.length - 1 &&
              //           controller.moreDataAvailable.value == true) {
              //         return const SpinKitThreeBounce(
              //           color: MyColors.primaryLight,
              //           size: 30,
              //         );
              //       }
              //       SocialPostModel s = controller.socialPostList[index];
              //       return Padding(
              //         padding: EdgeInsets.only(bottom: 5.0.w),
              //         child: SocialPostWidget(
              //             socialPost: s,
              //             fullView: true,
              //             isDetails: true,
              //             deletePost: controller.deletePost,
              //             inActivePost: controller.inActivePost,
              //             addReport: controller.addReport,
              //             repost: controller.repost,
              //             blockUserAndRefreshSocialFeed:()=> controller.blockUserAndRefreshSocialFeed(userId: s.user?.id??""),
              //             react: () => controller.reactPost(
              //                 postId: s.id ?? "", index: index)),
              //       );
              //     }),
              );
        }
      }),
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              backgroundColor: MyColors.primaryLight,
              onPressed: () => Get.toNamed(Routes.createPost),
              child: const Icon(Icons.add, color: MyColors.white),
            )
          : null,
    );
  }
}

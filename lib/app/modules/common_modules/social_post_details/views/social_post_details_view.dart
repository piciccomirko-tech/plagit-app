
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/social_post_widget.dart';
import 'package:mh/app/modules/common_modules/social_post_details/controllers/social_post_details_controller.dart';

import '../../../../models/saved_post_model.dart';
import '../../splash/controllers/splash_controller.dart';

class SocialPostDetailsView extends GetView<SocialPostDetailsController> {
  const SocialPostDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
          radius: 0.0, title: MyStrings.socialPostDetails.tr, context: context),
      body: Obx(() => controller.socialPostInfoDataLoading.value == true
          ? Center(child: CustomLoader.loading())
          : controller.noDataFound.value == true
              ? Center(child: NoItemFound())
              :
              // Get.find<AppController>().user.value.userId !=
              //                     controller.socialPostInfo.value.user?.id &&
              controller.socialPostInfo.value.active == true
                  ? SingleChildScrollView(
                      child: SocialPostWidget(
                        isDetails: true,
                        fullView: false,
                        socialPost: controller.socialPostInfo.value,
                        react: controller.reactPost,
                        addReport: controller.addReport,
                        blockUserAndRefreshSocialFeed: () =>
                            controller.blockUserAndRefreshSocialFeed(
                                userId:
                                    controller.socialPostInfo.value.user?.id ??
                                        ""),
                        repost: controller.repost,
                        save: () => controller.commonSocialFeedController
                            .savePost(controller.socialPostId),
                        isSave: controller.commonSocialFeedController
                            .isPostSaved(controller.socialPostId),
                        deleteSavePost: () => controller
                            .commonSocialFeedController
                            .deleteSavePost(savedPostList
                                    .firstWhere(
                                        (post) =>
                                            post.post?.id ==
                                            controller.socialPostId,
                                        orElse: () => SavedPostModel())
                                    .id ??
                                ""),
                        commonSocialFeedController: controller.commonSocialFeedController,
                      ),
                    )
                  : Center(child: NoItemFound())),
    );
  }
}

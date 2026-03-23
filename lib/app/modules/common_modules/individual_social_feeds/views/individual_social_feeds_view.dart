import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/common_modules/individual_social_feeds/controllers/individual_social_feeds_controller.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../widgets/individual_details_tab_items_widget.dart';
import '../widgets/individual_details_tab_widget.dart';
import '../widgets/social_user_info_widget.dart';

class IndividualSocialFeedsView
    extends GetView<IndividualSocialFeedsController> {
  const IndividualSocialFeedsView({super.key});

  @override
  Widget build(BuildContext context) {
    // controller.context = context;

    return Scaffold(
      appBar:
          // CustomAppbar.appbar(title: MyStrings.socialFeed.tr, context: context),
          CustomAppbar.appbar(title: 'User Profile', context: Get.context!),
      body: Obx(() => controller.loading.value == true
          ? Center(child: CustomLoader.loading())
          : controller.loadingFollowers.value == true?Center(child: CustomLoader.loading()):SingleChildScrollView(
              controller: controller.scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 15.w),
                  SocialUserInfoWidget(),
                  IndividualDetailsTabWidget(),
                  IndividualDetailsTabItemWidget(),
                ],
              ),
            )),
      
      //  const Column(
      //   children: [
      //     SocialUserInfoWidget(),hh
      //     Flexible(child: IndividualSocialFeedsWidget())
      //   ],
      // ),
    );
  }
}

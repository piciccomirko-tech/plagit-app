import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../common_job_posts/view/common_job_posts_view.dart';
import '../controllers/user_profile_controller.dart';
import 'user_profile_social_feeds_widget.dart';

class UserProfileTabItemWidget extends GetWidget<UserProfileController> {
  const UserProfileTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? const UserProfileSocialFeedsWidget()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: CommonJobPostsView(
              userType: 'individual',
              isMyJobPost: false,
              clientName: controller.socialUser.value.name,
              clientId: controller.socialUser.value.id,
            ),
          ));
  }
}

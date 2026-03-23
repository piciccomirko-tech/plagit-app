import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../controllers/individual_social_feeds_controller.dart';
import 'individual_job_posts_widget.dart';
import 'individual_social_feeds_widget.dart';

class IndividualDetailsTabItemWidget
    extends GetWidget<IndividualSocialFeedsController> {
  const IndividualDetailsTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? const IndividualSocialFeedsWidget()
        : const IndividualJobPostsWidget());
        // :   Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: CommonJobPostsView(userType: 'individual',isMyJobPost: false,clientName: controller.socialUser.name, clientId: controller.socialUser.id,),
        // ));
        // : const Text("Rahat"));
  }
}

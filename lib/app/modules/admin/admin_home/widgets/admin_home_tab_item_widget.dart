import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/admin_home/widgets/admin_job_posts_widget.dart';
import 'package:mh/app/modules/common_modules/common_social_feed/views/common_social_feed_view.dart';
import '../../../../common/utils/exports.dart';

class AdminHomeTabItemWidget extends GetWidget<AdminHomeController> {
  const AdminHomeTabItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.selectedTabIndex.value == 0
        ? const CommonSocialFeedView()
        : Padding(
          padding: EdgeInsets.all(15.0.w),
          child: const AdminJobPostsWidget(),
          // child: const CommonJobPostsView(userType: 'admin',isMyJobPost: false, ),
        ));
  }
}

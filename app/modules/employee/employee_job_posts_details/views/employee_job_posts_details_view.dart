import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/widgets/employee_job_post_details_basic_info_widget.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/widgets/employee_job_post_details_bottom_nav_bar.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/widgets/employee_job_post_details_comment_info_widget.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/widgets/employee_job_post_details_skills_info_widget.dart';

import '../controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostsDetailsView extends GetView<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostsDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: '${MyStrings.jobPosts.tr} ${MyStrings.details.tr}',
      ),
      bottomNavigationBar: const EmployeeJobPostDetailsBottomNavBar(),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              EmployeeJobPostDetailsBasicInfoWidget(),
              EmployeeJobPostDetailsSkillsInfoWidget(),
              EmployeeJobPostDetailsCommentInfoWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

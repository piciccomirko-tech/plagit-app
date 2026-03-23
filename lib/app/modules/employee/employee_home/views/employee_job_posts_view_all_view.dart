import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/client_home_premium/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_job_post_widget.dart';

import '../controllers/employee_home_controller.dart';

class EmployeeJobPostsViewAllView extends StatelessWidget {
  final List<Job> jobPostList;
   EmployeeJobPostsViewAllView({super.key, required this.jobPostList});

  final EmployeeHomeController employeeHomeController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: '${MyStrings.viewAll.tr} ${MyStrings.jobPosts.tr}',
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10.0.w, top: 15.0.w, bottom: 10.0.w),
        child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 0.0,
            mainAxisSpacing: 10.0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            childAspectRatio: 0.75,
            children: List.generate(jobPostList.length, (index) => EmployeeJobPostWidget(
                jobPost: jobPostList[index], isMyJobPost:employeeHomeController.isMyJobPost ))),
      ),
    );
  }
}

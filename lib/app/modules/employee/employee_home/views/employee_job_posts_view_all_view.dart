import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/job_requests/models/job_post_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/job_post_widget.dart';

class EmployeeJobPostsViewAllView extends StatelessWidget {
  final List<Job> jobPostList;
  const EmployeeJobPostsViewAllView({super.key, required this.jobPostList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: 'View All Job Posts',
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 10.0.w, top: 15.0.w, bottom: 10.0.w),
        child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 0.0,
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            childAspectRatio: 0.75,
            children: List.generate(jobPostList.length, (index) => JobPostWidget(jobPost: jobPostList[index]))),
      ),
    );
  }
}

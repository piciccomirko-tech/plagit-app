import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/common_modules/job_post_details/controllers/job_post_details_controller.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/employee_item_widget.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/employee_job_post_details_basic_info_widget.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/employee_job_post_details_comment_info_widget.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/employee_job_post_details_skills_info_widget.dart';

import 'employee_job_details_client_card_widget.dart';

class JobPostDetailsWidget extends GetWidget<JobPostDetailsController> {
  const JobPostDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    if (( controller.jobPostDetails.value.users!.isNotEmpty 
    && controller.appController.user.value.client?.client==true
      && controller.isMyJobPost.value ==true)) {
      return 
      // Text("testinggggggg");
      
      ListView.builder(
          shrinkWrap: true,
          itemCount: (controller.jobPostDetails.value.users ?? []).length,
          itemBuilder: (context, index) => EmployeeItemWidget(
              user: (controller.jobPostDetails.value.users ?? [])[index]));
    } else {
      return controller.jobPostDetails.value.id == null
          ? NoItemFound()
          : SingleChildScrollView(
              child: Column(
                children: [
                
                  EmployeeJobPostDetailsBasicInfoWidget(),
                  EmployeeJobPostDetailsSkillsInfoWidget(),
                  EmployeeJobPostDetailsCommentInfoWidget(),
                if (controller.jobPostDetails.value.clientId!=null)  EmployeeJobPostClientInfoCard(),
                ],
              ),
            );
    }
  }
}

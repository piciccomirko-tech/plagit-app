import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../../common_job_posts/widgets/common_job_post_widget.dart';
import '../controllers/common_search_controller.dart';

class CommonSearchProfileResultWidget extends GetWidget<CommonSearchController> {
  const CommonSearchProfileResultWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
                  itemCount: controller.jobsList.length,
                  itemBuilder: (context, index) {
                    final Job job = controller.jobsList[index];
                    return CommonJobPostWidget(
                      jobPost: job,
                      isMyJobPost: false,
                    );
                  },
                );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/client/job_requests/widgets/job_request_widget.dart';

import '../controllers/job_requests_controller.dart';

class JobRequestsView extends GetView<JobRequestsController> {
  const JobRequestsView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.jobRequests,
        centerTitle: true,
        context: context,
      ),
      body: Obx(() => controller.jobPostDataLoading.value == true
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 115),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: ListView.builder(
                itemCount: (controller.jobPostRequest.value.jobs ?? []).length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return JobRequestWidget(jobRequest: (controller.jobPostRequest.value.jobs ?? [])[index]);
                },
              ),
            )),
    );
  }
}

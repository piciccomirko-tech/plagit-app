import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/client/job_request_details/widgets/employee_item_widget.dart';
import '../controllers/job_request_details_controller.dart';

class JobRequestDetailsView extends GetView<JobRequestDetailsController> {
  const JobRequestDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppbar.appbar(
          title: controller.jobDetails.positionId?.name ?? "",
          centerTitle: true,
          context: context,
        ),
        body: (controller.jobDetails.users ?? []).isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                itemCount: (controller.jobDetails.users ?? []).length,
                itemBuilder: (context, index) => EmployeeItemWidget(user: (controller.jobDetails.users ?? [])[index]))
            : const Center(child: NoItemFound()));
  }
}

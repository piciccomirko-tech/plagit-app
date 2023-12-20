import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';

import '../controllers/job_requests_controller.dart';

class JobRequestsView extends GetView<JobRequestsController> {
  const JobRequestsView({super.key});
  @override
  Widget build(BuildContext context) {
    print('JobRequestsView.build: ${Get.find<AppController>().user.value.client?.id}');
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.createJobPost,
        centerTitle: true,
        context: context,
      ),
      body: const Center(
        child: Text(
          'JobRequestsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

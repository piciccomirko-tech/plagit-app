import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/create_job_time_range_widget.dart';

class TimeRangeForCreateJob extends GetWidget<CreateJobPostController> {
  const TimeRangeForCreateJob({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: controller.requestDateList.isNotEmpty,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(controller.requestDateList.length,
                (int index) => CreateJobTimeRangeWidget(requestDate: controller.requestDateList[index], index: index)),
          ),
        )));
  }
}

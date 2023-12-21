import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostDetailsCommentInfoWidget extends GetWidget<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostDetailsCommentInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 15.0.h),
        padding: const EdgeInsets.all(15.0),
        decoration: MyDecoration.cardBoxDecoration(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Comments:", style: MyColors.c_A6A6A6.medium13),
            SizedBox(height: 10.h),
            const Divider(
              height: 0.0,
              thickness: 0.5,
              color: MyColors.c_A6A6A6,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                 Image.asset(MyAssets.chefDePartie, height: 18, width: 18),
                Text("  ${controller.jobPostDetails.description??""}",
                    maxLines: null,
                    style: MyColors.l111111_dwhite(context).medium13)
              ],
            )
          ],
        ));
  }
}

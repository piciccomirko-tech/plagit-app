import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class TotalDaysCountWidget extends GetWidget<CreateJobPostController> {
  const TotalDaysCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30.0), color: MyColors.c_C6A34F),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(MyAssets.calender1, height: 20, width: 20),
          Text(' Total ', style: MyColors.white.medium13),
          Obx(() => Text('${controller.requestDateList.calculateTotalDays()}', style: MyColors.white.semiBold24)),
          Text(' Days have been selected', style: MyColors.white.medium13),
        ],
      ),
    );
  }
}

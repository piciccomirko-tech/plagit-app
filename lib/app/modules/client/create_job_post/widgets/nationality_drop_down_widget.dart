import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

import '../../../../common/values/my_assets.dart';

class NationalityDropDownWidget extends GetWidget<CreateJobPostController> {
  const NationalityDropDownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            CustomDropdown(
              prefixIcon: Icons.flag,
              hints: MyStrings.nationality.tr,
              value: '',
              items: controller.nationalities.map((e) => e.nationality ?? "").toList(),
              onChange: controller.onNationalityChange,
            ),
            SizedBox(height: 10.h),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Wrap(
                  children: List.generate(controller.nationalityList.length,
                      (int index) {
                    String skill = controller.nationalityList[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Chip(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: MyColors.c_C6A34F.withOpacity(0.5))
                        ),
                        backgroundColor: MyColors.c_C6A34F.withOpacity(0.5),
                        label: Text(skill, style: TextStyle(fontSize: 11.sp,fontFamily: MyAssets.fontKlavika),),
                        deleteIconColor: Colors.red,
                        onDeleted: () {
                          controller.onNationalityClearClick(index: index);
                        },
                      ),
                    );
                    // return Container(
                    //   margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    //   padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
                    //   decoration: BoxDecoration(
                    //       color: MyColors.c_C6A34F.withOpacity(0.5), borderRadius: BorderRadius.circular(5.0)),
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       Text(skill, style: Get.width>600?MyColors.l111111_dffffff(context).medium9:MyColors.l111111_dffffff(context).medium14),
                    //       SizedBox(width: 5.w),
                    //       InkWell(
                    //           onTap: () => controller.onNationalityClearClick(index: index),
                    //           child: Container(
                    //               decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:Colors.red),
                    //               child: Icon(Icons.clear, color: MyColors.l111111_dffffff(context), size: 15))),
                    //     ],
                    //   ),
                    // );
                  }),
                ))
          ],
        ));
  }
}

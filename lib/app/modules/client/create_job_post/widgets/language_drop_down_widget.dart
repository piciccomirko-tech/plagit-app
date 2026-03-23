import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/data/data.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

import '../../../../common/values/my_assets.dart';

class LanguageDropDownWidget extends GetWidget<CreateJobPostController> {
  const LanguageDropDownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            CustomDropdown(
              prefixIcon: Icons.supervised_user_circle_outlined,
              hints: MyStrings.language.tr,
              value: '',
              items: Data.language.toList(),
              onChange: controller.onLanguageChange,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Wrap(
                children:
                    List.generate(controller.languageList.length, (int index) {
                  String skill = controller.languageList[index];
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
                        controller.onLanguageClearClick(index: index);
                      },
                    ),
                  );
                }),
              ),
            )
          ],
        ));
  }
}

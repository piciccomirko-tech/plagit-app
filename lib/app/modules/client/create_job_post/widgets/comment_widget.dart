import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/validators.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class CommentWidget extends GetWidget<CreateJobPostController> {
  const CommentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.0.w),
        child: Obx(
          () => TextFormField(
            controller: controller.tecDescription.value,
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: null,
            cursorColor: MyColors.c_C6A34F,
            style: MyColors.l111111_dwhite(context).regular14,
            decoration: MyDecoration.inputFieldDecoration(
              context: context,
              label: MyStrings.description.tr,
            ),
            validator: (String? value) => Validators.emptyValidator(
              value?.trim(),
              MyStrings.required.tr,
            ),
          ),
        ));
  }
}

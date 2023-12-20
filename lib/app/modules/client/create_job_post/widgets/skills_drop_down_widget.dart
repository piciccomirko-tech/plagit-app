import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dropdown.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class SkillsDropDownWidget extends GetWidget<CreateJobPostController> {
  const SkillsDropDownWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Column(
          children: [
            CustomDropdown(
              prefixIcon: Icons.supervised_user_circle_outlined,
              hints: MyStrings.skills.tr,
              value: '',
              items: controller.appController.skills.map((e) => e.name!).toList(),
              onChange: controller.onSkillsChange,
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Wrap(
                children: List.generate((controller.createJobPostRequestModel.value.skills ?? []).length, (int index) {
                  String skill = (controller.createJobPostRequestModel.value.skills ?? [])[index];
                  return Container(
                    margin: EdgeInsets.only(right: 10.w, bottom: 10.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 8.h),
                    decoration: BoxDecoration(
                        color: MyColors.c_C6A34F.withOpacity(0.5), borderRadius: BorderRadius.circular(5.0)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(skill, style: MyColors.black.medium14),
                        SizedBox(width: 5.w),
                        InkWell(
                            onTap: () => controller.onSkillClearClick(index: index),
                            child: const Icon(Icons.clear, color: MyColors.black, size: 18))
                      ],
                    ),
                  );
                }),
              ),
            )
          ],
        ));
  }
}

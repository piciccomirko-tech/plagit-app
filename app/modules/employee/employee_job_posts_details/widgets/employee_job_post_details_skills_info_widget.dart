import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/employee/employee_job_posts_details/controllers/employee_job_posts_details_controller.dart';

class EmployeeJobPostDetailsSkillsInfoWidget extends GetWidget<EmployeeJobPostsDetailsController> {
  const EmployeeJobPostDetailsSkillsInfoWidget({super.key});

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
            Text("${MyStrings.skills.tr} ${MyStrings.requirements.tr}:", style: MyColors.c_A6A6A6.medium13),
            SizedBox(height: 10.h),
            const Divider(
              height: 0.0,
              thickness: 0.5,
              color: MyColors.c_A6A6A6,
            ),
            SizedBox(height: 10.h),
            ListView.builder(
                shrinkWrap: true,
                itemCount: (controller.jobPostDetails.skills ?? []).length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding:  EdgeInsets.only(bottom: 10.0.h),
                    child: Row(
                      children: [
                        Image.asset(MyAssets.skill, height: 18, width: 18),
                        Text("  ${(controller.jobPostDetails.skills ?? [])[index]}",
                            style: MyColors.l111111_dwhite(context).medium13)
                      ],
                    ),
                  );
                })
          ],
        ));
  }
}

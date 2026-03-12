import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
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
            Text("${MyStrings.comments.tr}:", style: MyColors.c_A6A6A6.medium13),
            SizedBox(height: 10.h),
            const Divider(
              height: 0.0,
              thickness: 0.5,
              color: MyColors.c_A6A6A6,
            ),
            SizedBox(height: 10.h),
            HtmlWidget("  ${controller.jobPostDetails.description ?? ""}",
                textStyle: MyColors.l111111_dwhite(context).medium13),
          ],
        ));
  }
}

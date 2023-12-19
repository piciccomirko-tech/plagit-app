import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/language_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/nationality_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/hourly_rate_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/position_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/skills_drop_down_widget.dart';
import '../controllers/create_job_post_controller.dart';

class CreateJobPostView extends GetView<CreateJobPostController> {
  const CreateJobPostView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.createJobPost,
        centerTitle: true,
        context: context,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15.h),
            const PositionDropDownWidget(),
            SizedBox(height: 15.h),
            const HourlyRateWidget(),
            SizedBox(height: 15.h),
            const SkillsDropDownWidget(),
            SizedBox(height: 15.h),
            const NationalityDropDownWidget(),
            SizedBox(height: 15.h),
            const LanguageDropDownWidget(),
            SizedBox(height: 15.h),

          ],
        ),
      ),
    );
  }
}

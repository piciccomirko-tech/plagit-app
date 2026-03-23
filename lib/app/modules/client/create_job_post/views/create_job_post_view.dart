
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/comment_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/create_job_bottom_nav_bar_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/end_date_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/language_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/nationality_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/position_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/publish_date_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/skills_drop_down_widget.dart';
import 'package:mh/app/modules/client/create_job_post/widgets/vacancy_widget.dart';
import '../../../../common/widgets/custom_text_input_field.dart';
import '../../client_home_premium/controllers/client_home_premium_controller.dart';
import '../controllers/create_job_post_controller.dart';
import '../widgets/multi_month_dialog_picker_widget.dart';

class CreateJobPostView extends GetView<CreateJobPostController> {
  const CreateJobPostView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: controller.type == "create"
            ? MyStrings.createJobPost.tr.replaceAll("\n", " ")
            : MyStrings.updateJobPost.tr.replaceAll("\n", " "),
        centerTitle: true,
        onBackButtonPressed: () async {
          // controller.revertToOriginalData();
          controller.skillList.value = [];
          controller.skillList.refresh();
          Get.find<ClientHomePremiumController>().getMyJobPosts();
          Get.back(); // Navigates back after handling
        },
        context: context,
      ),
      bottomNavigationBar: Obx(() {
        return controller.isJobPostCreateButtonShown.value
            ? const CreateJobBottomNavBarWidget()
            : SizedBox.shrink(); // Returns an empty widget when false
      }),
      body: WillPopScope(
          onWillPop: () async {
            controller.skillList.value = [];
            controller.skillList.refresh();
            Get.find<ClientHomePremiumController>().getMyJobPosts();
            Get.back(); // Navigates back after handling
            // Return true to allow the pop action
            return Future.value(true);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (controller.type == "create") ...[
                  SizedBox(height: 20.h),
                  const PositionDropDownWidget(),
                ],
                SizedBox(height: 20.h),
                // const HourlyRateWidget(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.sp),
                  child: CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.salaryAmount,
                    label: 'Salary',
                    prefixIcon: Icons.money,
                    textInputType: TextInputType.text,
                    // isRequired: true,
                  ),
                ),
                SizedBox(height: 15.h),
                const SkillsDropDownWidget(),
                SizedBox(height: 15.h),
                // const SelectedDatesWidget(),
                MultiMonthDropdownPicker(),
                SizedBox(height: 15.h),
                const NationalityDropDownWidget(),
                SizedBox(height: 15.h),
                // const ExperienceWidget(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.sp),
                  child: CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.experienceAmount,
                    label: 'Experience',
                    prefixIcon: Icons.lock_clock,
                    textInputType: TextInputType.text,
                    // isRequired: true,
                  ),
                ),
                SizedBox(height: 15.h),
                const LanguageDropDownWidget(),
                SizedBox(height: 15.h),
                // const AgeWidget(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18.sp),
                  child: CustomTextInputField(
                    padding: EdgeInsets.all(0),
                    controller: controller.ageAmount,
                    textInputType: TextInputType.text,
                    label: 'Age',
                    prefixIcon: Icons.person,
                    // isRequired: true,
                  ),
                ),
                SizedBox(height: 15.h),
                const VacancyWidget(),
                SizedBox(height: 15.h),
                const Row(
                  children: [
                    Expanded(flex: 1, child: PublishDateWidget()),
                    Expanded(flex: 1, child: EndDateWidget())
                  ],
                ),
                SizedBox(height: 15.h),
                const CommentWidget(),
                SizedBox(height: 15.h),
              ],
            ),
          )),
    );
  }
}

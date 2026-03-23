import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/employee_job_post_details_bottom_nav_bar.dart';
import 'package:mh/app/modules/common_modules/job_post_details/widgets/job_post_details_widget.dart';
import '../controllers/job_post_details_controller.dart';

class JobPostDetailsView extends GetView<JobPostDetailsController> {
  const JobPostDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: CustomAppbar.appbar(
          title: controller.jobPostDetails.value.positionId?.name ?? "",
          centerTitle: true,
          context: context,
        ),
        bottomNavigationBar: const EmployeeJobPostDetailsBottomNavBar(),
        body: controller.jobPostDetailsDataLoading.value == true
            ? Center(child: CustomLoader.loading())
            : controller.noDataFound.value == true
                ? Center(child: NoItemFound())
                : Padding(
                    padding: EdgeInsets.all(15.0.w),
                    child: JobPostDetailsWidget(),
                  ),
      ),
    );
  }
}

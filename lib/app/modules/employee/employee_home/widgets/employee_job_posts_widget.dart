import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/job_post_widget.dart';

class EmployeeJobPostsWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeJobPostsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => controller.jobPostDataLoading.value == true
        ? ShimmerWidget.employeeJobPostsShimmerWidget(
            height: MediaQuery.sizeOf(context).height * 0.3, width: MediaQuery.sizeOf(context).width * 0.5)
        : Visibility(
            visible: (controller.jobPostRequest.value.jobs ?? []).isNotEmpty,
            child: Column(
              children: [
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 5.w),
                        Image.asset(MyAssets.job, height: 25, width: 25),
                        Text("  Job Posts", style: MyColors.l111111_dwhite(context).medium15)
                      ],
                    ),
                    Visibility(
                        visible: (controller.jobPostRequest.value.jobs ?? []).length > 1,
                        child: InkResponse(
                            onTap: controller.onViewAllClick,
                            child: Text("View All >> ", style: MyColors.c_C6A34F.semiBold12)))
                  ],
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.3,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: (controller.jobPostRequest.value.jobs ?? []).length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return JobPostWidget(jobPost: (controller.jobPostRequest.value.jobs ?? [])[index]);
                      }),
                ),
                SizedBox(height: 15.h),
              ],
            )));
  }
}

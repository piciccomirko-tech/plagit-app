import 'package:lottie/lottie.dart';
import 'package:mh/app/common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../../common_job_posts/widgets/common_job_post_widget.dart';
import '../controllers/common_search_controller.dart';
import '../widgets/common_search_input_widget.dart';
import '../widgets/common_search_social_post_result_widget.dart';

class CommonSearchView extends GetView<CommonSearchController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
          title: MyStrings.search.tr, context: context, centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Box with Button
            Lottie.asset(MyAssets.lottie.searchLottie,
                height: 200.h, width: Get.width),
            const CommonSearchInputWidget(),

            SizedBox(height: 16.h),

            // Tabs Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTabItem(MyStrings.profile, 0),
                _buildTabItem(MyStrings.jobs, 1),
                _buildTabItem(MyStrings.feeds, 2),
              ],
            ),

            const SizedBox(height: 16),

            // Search Results
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (controller.errorMessage.isNotEmpty) {
                  return Center(
                    child: Text(
                      controller.errorMessage.value.tr,
                      style: const TextStyle(color: Colors.red,fontFamily: MyAssets.fontKlavika),
                    ),
                  );
                } else if (controller.activeTab.value == 0 &&
                    controller.suggestionsList.isEmpty) {
                  return const Center(child: Text('No profiles found.',
                      style:TextStyle(fontFamily: MyAssets.fontKlavika),));
                } else if (controller.activeTab.value == 1 &&
                    controller.jobsList.isEmpty) {
                  return const Center(child: Text('No jobs found.',
                    style:TextStyle(fontFamily: MyAssets.fontKlavika),));
                } else if (controller.activeTab.value == 0) {
                  return
                      //  CommonSearchProfileResultWidget();  // Profile Results
                      ListView.builder(
                    itemCount: controller.suggestionsList.length,
                    itemBuilder: (context, index) {
                      final suggestion = controller.suggestionsList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6.h),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: MyColors.noColor, width: 0.5),
                            borderRadius: BorderRadius.circular(10.0),
                            color: MyColors.lightCard(context)),
                        child: GestureDetector(
                          onTap:
                            () => suggestion.role?.toLowerCase() == "client"
                                ? Get.toNamed(Routes.individualSocialFeeds,
                                arguments: SocialUser(
                                    id: suggestion.id,
                                    name:(suggestion.positionName?.isNotEmpty ?? false)
                                        ? suggestion.name!
                                        : (suggestion.restaurantName?.isNotEmpty ??
                                        false)
                                        ? suggestion.restaurantName!
                                        : suggestion.name ?? '',
                                    positionName:suggestion.positionName,
                                    countryName: suggestion.countryName ?? '',
                                    role: suggestion.role
                                ))
                                : Get.toNamed(Routes.employeeDetails,
                                arguments: {'employeeId': suggestion.id ?? ""}),
                          child: ListTile(
                            leading: suggestion.profilePicture != null &&
                                    suggestion.profilePicture!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        (suggestion.profilePicture ?? '')
                                            .imageUrl),
                                  )
                                : CircleAvatar(
                                    backgroundImage: AssetImage(
                                        suggestion.role?.toLowerCase() ==
                                            'employee'?
                                            MyAssets.employeeDefault
                                            : MyAssets.clientDefault),
                                  ),
                            title: Text(
                              style:TextStyle(fontFamily: MyAssets.fontKlavika),
                              (suggestion.positionName?.isNotEmpty ?? false)
                                  ? suggestion.name!
                                  : (suggestion.restaurantName?.isNotEmpty ??
                                          false)
                                      ? suggestion.restaurantName!
                                      : suggestion.name ?? '',
                            ),
                            subtitle: Text(
                                style:TextStyle(fontFamily: MyAssets.fontKlavika),
                                '${suggestion.positionName ?? ''}${suggestion.positionName == null ? '' : ', '}${suggestion.countryName ?? ''}'),
                            // trailing: Text('Following'),
                          ),
                        ),
                      );
                    },
                  );
                } else if (controller.activeTab.value == 1) {
                  return ListView.builder(
                    itemCount: controller.jobsList.length,
                    itemBuilder: (context, index) {
                      final Job job = controller.jobsList[index];
                      return CommonJobPostWidget(
                        jobPost: job,
                        isMyJobPost: false,
                      );
                    },
                  );
                } else if (controller.activeTab.value == 2) {
                  return CommonSocialFeedSearchResultWidget();
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for building tab items
  Widget _buildTabItem(String title, int index) {
    return GestureDetector(
      onTap: () => controller.setActiveTab(index),
      child: Obx(() {
        final isActive = controller.activeTab.value == index;
        return Column(
          children: [
            Text(
              title.tr,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isActive ? MyColors.primaryLight : Colors.grey,
                  fontFamily: MyAssets.fontKlavika
              ),
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                color: MyColors.primaryLight,
              ),
          ],
        );
      }),
    );
  }
}

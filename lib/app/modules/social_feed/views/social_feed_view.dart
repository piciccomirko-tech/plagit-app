import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import '../controllers/social_feed_controller.dart';
import '../widgets/social_post_card.dart';

class SocialFeedView extends GetView<SocialFeedController> {
  const SocialFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: 'Social Feed',
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: MyColors.c_C6A34F),
          );
        }

        if (controller.hasError.value) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.wifi_slash, size: 60, color: MyColors.c_A6A6A6),
                  SizedBox(height: 16.h),
                  Text(
                    controller.errorMessage.value,
                    style: MyColors.c_A6A6A6.semiBold15,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: controller.fetchPosts,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors.c_C6A34F,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.news, size: 60, color: MyColors.c_A6A6A6),
                SizedBox(height: 16.h),
                Text(
                  'No posts yet',
                  style: MyColors.c_A6A6A6.semiBold15,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: MyColors.c_C6A34F,
          onRefresh: controller.fetchPosts,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
            itemCount: controller.posts.length,
            itemBuilder: (context, index) {
              return SocialPostCard(
                post: controller.posts[index],
                controller: controller,
              );
            },
          ),
        );
      }),
    );
  }
}

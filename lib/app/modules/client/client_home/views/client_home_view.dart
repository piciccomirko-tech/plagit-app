import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/social_feed/controllers/social_feed_controller.dart';
import 'package:mh/app/modules/social_feed/widgets/social_post_card.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../controllers/client_home_controller.dart';

class ClientHomeView extends GetView<ClientHomeController> {
  const ClientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return WillPopScope(
      onWillPop: () async => Utils.appExitConfirmation(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top app bar
              _buildTopBar(context),

              // Main scrollable content
              Expanded(
                child: RefreshIndicator(
                  color: MyColors.c_C6A34F,
                  onRefresh: () async {
                    controller.refreshPage();
                    final feedCtrl = _getSocialFeedController();
                    if (feedCtrl != null) await feedCtrl.fetchPosts();
                  },
                  child: SingleChildScrollView(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.h),
                        // Profile + Dashboard/My Candidates row
                        _buildProfileRow(context),
                        SizedBox(height: 16.h),
                        // Job category circles
                        _buildCategoryRow(),
                        SizedBox(height: 16.h),
                        // Tab toggle: Social Feed | Job Posts
                        Obx(() => _buildTabToggle(context)),
                        SizedBox(height: 8.h),
                        // Tab content
                        Obx(() => controller.selectedTab.value == 0
                            ? _buildSocialFeedContent(context)
                            : _buildJobPostsContent(context)),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom navigation bar
        bottomNavigationBar: _buildBottomNavBar(context),
        floatingActionButton: SizedBox(
          width: 56,
          height: 56,
          child: FloatingActionButton(
            shape: const CircleBorder(),
            backgroundColor: MyColors.c_C6A34F,
            elevation: 4,
            onPressed: controller.onCreateJobPostClick,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // ─── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          // Plagit logo
          Image.asset(MyAssets.logo, height: 36.h, width: 36.w),
          SizedBox(width: 10.w),
          Text(
            'Home',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          // Notification bell
          Obx(() => controller.notificationsController.unreadCount.value == 0
              ? InkResponse(
                  onTap: () => Get.toNamed(Routes.notifications),
                  child: Icon(CupertinoIcons.bell, size: 24, color: Colors.grey.shade700),
                )
              : InkResponse(
                  onTap: () => Get.toNamed(Routes.notifications),
                  child: Badge(
                    backgroundColor: MyColors.c_C6A34F,
                    label: Obx(() => Text(
                      controller.notificationsController.unreadCount.value >= 20
                          ? '20+'
                          : controller.notificationsController.unreadCount.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    )),
                    child: Icon(CupertinoIcons.bell, size: 24, color: Colors.grey.shade700),
                  ),
                )),
          SizedBox(width: 16.w),
          // Chat icon
          Obx(() => controller.unreadMessageFromAdmin.value == 0
              ? InkResponse(
                  onTap: controller.onHelpAndSupportClick,
                  child: Icon(CupertinoIcons.chat_bubble_text, size: 24, color: Colors.grey.shade700),
                )
              : InkResponse(
                  onTap: controller.onHelpAndSupportClick,
                  child: Badge(
                    backgroundColor: MyColors.c_C6A34F,
                    label: Text(
                      controller.unreadMessageFromAdmin.value.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                    child: Icon(CupertinoIcons.chat_bubble_text, size: 24, color: Colors.grey.shade700),
                  ),
                )),
        ],
      ),
    );
  }

  // ─── PROFILE ROW ──────────────────────────────────────
  Widget _buildProfileRow(BuildContext context) {
    final clientName = controller.appController.user.value.client?.restaurantName ?? 'User';
    final initial = clientName.isNotEmpty ? clientName[0].toUpperCase() : 'U';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: MyColors.c_C6A34F,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Dashboard + My Candidates pill
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.c_C6A34F.withOpacity(0.4), width: 1.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: controller.onDashboardClick,
                      child: Column(
                        children: [
                          Image.asset(MyAssets.dashboard, height: 28.h, width: 28.w),
                          SizedBox(height: 4.h),
                          Text('Dashboard', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, height: 36.h, color: Colors.grey.shade300),
                  Expanded(
                    child: InkWell(
                      onTap: controller.onMhEmployeeClick,
                      child: Column(
                        children: [
                          Image.asset(MyAssets.mhEmployees, height: 28.h, width: 28.w),
                          SizedBox(height: 4.h),
                          Text('My Candidates', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY ROW ─────────────────────────────────────
  Widget _buildCategoryRow() {
    final categories = [
      {'name': 'Manager', 'icon': MyAssets.manager},
      {'name': 'Chef', 'icon': MyAssets.chef},
      {'name': 'Commis C.', 'icon': MyAssets.commisChef},
      {'name': 'Waiter', 'icon': MyAssets.waiter},
      {'name': 'K. Porter', 'icon': MyAssets.kitchenPorter},
      {'name': 'Bartender', 'icon': MyAssets.bartender},
      {'name': 'Runner', 'icon': MyAssets.runner},
      {'name': 'Barista', 'icon': MyAssets.barista},
    ];

    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: InkWell(
              onTap: () {
                // Find matching position and navigate
                final matching = controller.appController.allActivePositions
                    .where((p) => (p.name ?? '').toLowerCase().contains(
                        (cat['name'] as String).replaceAll('.', '').toLowerCase()))
                    .toList();
                if (matching.isNotEmpty) {
                  controller.onSearchItemTap(position: matching.first);
                }
              },
              child: Column(
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(10.sp),
                        child: Image.asset(cat['icon']!, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    cat['name']!,
                    style: TextStyle(fontSize: 11.sp, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── TAB TOGGLE ───────────────────────────────────────
  Widget _buildTabToggle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedTab.value == 0 ? MyColors.c_C6A34F : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Social Feed',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.selectedTab.value == 0 ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedTab.value = 1,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: controller.selectedTab.value == 1 ? MyColors.c_C6A34F : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      'Job Posts',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.selectedTab.value == 1 ? Colors.white : Colors.black54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SOCIAL FEED CONTENT ──────────────────────────────
  SocialFeedController? _getSocialFeedController() {
    try {
      return Get.find<SocialFeedController>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildSocialFeedContent(BuildContext context) {
    // Ensure social feed controller is registered
    if (!Get.isRegistered<SocialFeedController>()) {
      Get.put(SocialFeedController());
    }
    final feedController = Get.find<SocialFeedController>();

    return Obx(() {
      if (feedController.isLoading.value) {
        return Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: const Center(
            child: CircularProgressIndicator(color: MyColors.c_C6A34F),
          ),
        );
      }

      if (feedController.hasError.value) {
        return Padding(
          padding: EdgeInsets.all(30.sp),
          child: Center(
            child: Column(
              children: [
                Icon(CupertinoIcons.wifi_slash, size: 50, color: MyColors.c_A6A6A6),
                SizedBox(height: 12.h),
                Text(feedController.errorMessage.value, style: MyColors.c_A6A6A6.semiBold15, textAlign: TextAlign.center),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: feedController.fetchPosts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.c_C6A34F,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }

      if (feedController.posts.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Center(
            child: Column(
              children: [
                Icon(CupertinoIcons.news, size: 50, color: MyColors.c_A6A6A6),
                SizedBox(height: 12.h),
                Text('No posts yet', style: MyColors.c_A6A6A6.semiBold15),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h),
        itemCount: feedController.posts.length,
        itemBuilder: (context, index) {
          return SocialPostCard(
            post: feedController.posts[index],
            controller: feedController,
          );
        },
      );
    });
  }

  // ─── JOB POSTS CONTENT ────────────────────────────────
  Widget _buildJobPostsContent(BuildContext context) {
    return Obx(() {
      final jobs = controller.jobPostRequest.value.jobs ?? [];
      if (controller.jobPostDataLoading.value) {
        return Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: const Center(child: CircularProgressIndicator(color: MyColors.c_C6A34F)),
        );
      }
      if (jobs.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Center(
            child: Column(
              children: [
                Icon(CupertinoIcons.doc_text, size: 50, color: MyColors.c_A6A6A6),
                SizedBox(height: 12.h),
                Text('No job posts yet', style: MyColors.c_A6A6A6.semiBold15),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: controller.onCreateJobPostClick,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.c_C6A34F,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  ),
                  child: const Text('Create Job Post', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h),
        itemCount: jobs.length,
        itemBuilder: (context, index) {
          final job = jobs[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            padding: EdgeInsets.all(14.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: controller.onJobRequestsClick,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work_outline, color: MyColors.c_C6A34F, size: 20),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          job.positionId?.name ?? 'Job Post',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  if (job.vacancy != null)
                    Text(
                      '${job.vacancy} vacancy(s) \u00B7 ${job.status ?? ''}',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // ─── BOTTOM NAV BAR ───────────────────────────────────
  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 65,
        color: Colors.white,
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'Home', true, onTap: () {}),
            _navItem(Icons.search, 'Search', false, onTap: controller.onMhEmployeeClick),
            const SizedBox(width: 40), // space for FAB
            _navItem(Icons.payment_outlined, 'Payments', false, onTap: controller.onInvoiceAndPaymentClick),
            _navItem(Icons.support_agent, 'Support', false, onTap: controller.onHelpAndSupportClick),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {required VoidCallback onTap}) {
    final color = isActive ? MyColors.c_C6A34F : Colors.grey.shade500;
    return InkResponse(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: color, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

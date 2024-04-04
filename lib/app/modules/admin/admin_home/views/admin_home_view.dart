import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/common/widgets/custom_feature_box.dart';
import 'package:mh/app/common/widgets/refresh_widget.dart';
import 'package:mh/app/modules/auth/login/widgets/language_drop_down.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_menu.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return WillPopScope(
      onWillPop: () async => Utils.appExitConfirmation(context),
      child: Scaffold(
        appBar: CustomAppbar.appbar(
          context: context,
          title: MyStrings.features.tr,
          centerTitle: false,
          visibleBack: false,
          actions: [
            const SizedBox(width: 10),
            const LanguageDropdown(),
            const SizedBox(width: 10),
            Obx(() => controller.notificationsController.unreadCount.value == 0
                ? InkResponse(onTap: () => Get.toNamed(Routes.notifications), child: const Icon(CupertinoIcons.bell))
                : InkResponse(
              onTap: () => Get.toNamed(Routes.notifications),
              child: Badge(
                backgroundColor: MyColors.c_C6A34F,
                label: Obx(() {
                  return Text(
                      controller.notificationsController.unreadCount.value == 20
                          ? '20+'
                          : controller.notificationsController.unreadCount.toString(),
                      style: MyColors.white.semiBold12);
                }),
                child: const Icon(CupertinoIcons.bell, size: 20),
              ),
            )),
            const SizedBox(width: 20),
            InkResponse(
              onTap: () {
                CustomMenu.accountMenu(
                  context
                );
              },
              child: const Icon(
                  CupertinoIcons.person,
                  size: 20
              ),
            ),
            const SizedBox(width: 10)
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                        flex: 10,
                        child: _restaurantName("Hi, ${controller.appController.user.value.admin?.name ?? "-"}")),
                     SizedBox(width: 15.w),
                    Expanded(flex: 1, child: RefreshWidget(onTap: controller.reloadPage))
                  ],
                ),
                SizedBox(height: 20.h),
                _promotionText,
                SizedBox(height: 40.h),
                /*Obx(() => controller.loading.value == true
                    ? ShimmerWidget.clientMyEmployeesShimmerWidget()
                    : AnimationLimiter(
                        child: ListView.builder(
                            itemCount: adminHomeCardList.length,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            primary: false,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 800),
                                  child: SlideAnimation(
                                      horizontalOffset: 50.0,
                                      child: FadeInAnimation(
                                          child: AdminHomeCardWidget(
                                              adminHomeCardModel: adminHomeCardList[index], index: index))));
                            }),
                      ))*/
                Row(
                  children: [
                    Expanded(
                      child: CustomFeatureBox(
                        title: MyStrings.dashboard.tr,
                        icon: MyAssets.dashboard,
                        onTap: controller.onAdminDashboardClick,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Obx(
                        () => Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CustomFeatureBox(
                              title: MyStrings.requests.tr,
                              icon: MyAssets.request,
                              loading: controller.loading.value,
                              onTap: controller.onRequestClick,
                            ),
                            Positioned(
                              top: 4,
                              right: 5,
                              child: Visibility(
                                visible: controller.numberOfRequestFromClient > 0,
                                child: CustomBadge(controller.numberOfRequestFromClient.toString()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => Stack(
                          children: [
                            CustomFeatureBox(
                              title: MyStrings.employees.tr,
                              icon: MyAssets.myEmployees,
                              onTap: controller.onEmployeeClick,
                            ),
                            Positioned(
                              top: 4,
                              right: 5,
                              child: Visibility(
                                visible: controller.unreadMsgFromEmployee.value != 0,
                                child: CustomBadge(controller.unreadMsgFromEmployee.value.toString()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Obx(
                        () => Stack(
                          children: [
                            CustomFeatureBox(
                              title: MyStrings.client.tr,
                              icon: MyAssets.clientFixedLogo,
                              onTap: controller.onClientClick,
                            ),
                            Positioned(
                              top: 4,
                              right: 5,
                              child: Visibility(
                                visible: controller.unreadMsgFromClient.value != 0,
                                child: CustomBadge(controller.unreadMsgFromClient.value.toString()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomFeatureBox(
                        title: MyStrings.todaysEmployees.tr,
                        icon: MyAssets.manager,
                        onTap: controller.onTodaysEmployeesPressed,
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: CustomFeatureBox(
                        title: "Chat It",
                        icon: MyAssets.chat,
                        onTap: controller.onChatPressed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _restaurantName(String name) => Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: MyColors.l111111_dwhite(controller.context!).semiBold20,
      );

  Widget get _promotionText => Text(
        MyStrings.exploreTheFeaturesOfMhAppBelow.tr,
        style: MyColors.l777777_dtext(controller.context!).medium15,
      );
}

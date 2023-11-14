import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/common/widgets/refresh_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_feature_box.dart';
import '../../../../common/widgets/custom_menu.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return WillPopScope(
      onWillPop: () => Utils.appExitConfirmation(context),
      child: Scaffold(
        appBar: CustomAppbar.appbar(
          context: context,
          title: 'Feature',
          centerTitle: false,
          visibleBack: false,
          actions: [
            Obx(() => controller.notificationsController.unreadCount.value == 0
                ? IconButton(
                    onPressed: () {
                      Get.toNamed(Routes.notifications);
                    },
                    icon: const Icon(CupertinoIcons.bell))
                : InkWell(
                    onTap: () {
                      Get.toNamed(Routes.notifications);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 15.h, right: 15.w),
                      child: Badge(
                        backgroundColor: MyColors.c_C92C1A,
                        label: Obx(() {
                          return Text(
                              controller.notificationsController.unreadCount.value == 20
                                  ? '20+'
                                  :
                              controller.notificationsController.unreadCount.toString(),
                              style: MyColors.white.semiBold12);
                        }),
                        child: const Icon(CupertinoIcons.bell),
                      ),
                    ),
                  )),
            IconButton(
              onPressed: () {
                CustomMenu.accountMenu(context);
              },
              icon: const Icon(
                Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        body: SizedBox(
          height: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 29.h),
                        Row(
                          children: [
                            Expanded(
                              flex: 10,
                                child: _restaurantName("Hi, ${controller.appController.user.value.admin?.name ?? "-"}")),
                            const SizedBox(width: 10),
                            Expanded(
                                flex: 1,
                                child: RefreshWidget(onTap: controller.refreshPage)
                            )
                          ],
                        ),
                        SizedBox(height: 20.h),
                        _promotionText,
                        SizedBox(height: 40.h),
                        Row(
                          children: [
                            Expanded(
                              child: CustomFeatureBox(
                                title: MyStrings.dashboard.tr,
                                icon: MyAssets.dashboard,
                                onTap: controller.onAdminDashboardClick,
                              ),
                            ),
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Obx(
                                () => Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CustomFeatureBox(
                                      title: "Request",
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
                        SizedBox(height: 30.h),
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
                            SizedBox(width: 24.w),
                            Expanded(
                              child: Obx(
                                () => Stack(
                                  children: [
                                    CustomFeatureBox(
                                      title: "Client",
                                      icon: MyAssets.kitchenPorter,
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
                      ],
                    ),
                  ),
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

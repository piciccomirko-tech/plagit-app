import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_candidate_category_slider_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_header_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_tab_item_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/widgets/client_home_premium_tab_widget.dart';
import 'package:mh/app/modules/common_modules/auth/login/widgets/language_drop_down.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../widgets/client_progress_indicator_home.dart';
import 'dart:io';

class OldClientHomePremiumView extends GetView<ClientHomePremiumController> {
  const OldClientHomePremiumView({super.key});



  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Obx(() => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: CustomAppbar.appbar(
            context: context,
            onRefresh: controller.onRefresh,
            title: MyStrings.home.tr,
            isPlagItPlus: false,
            centerTitle: false,
            visibleBack: false,
            actions: [
              SizedBox(width: 10.w),
              const LanguageDropdown(),
              SizedBox(width: 10.w),
              Obx(() {
                int count =
                    controller.notificationsController.unreadCount.value;
                return GestureDetector(
                  onTap: () => Get.toNamed(Routes.notifications),
                  child: Badge(
                    isLabelVisible: count > 0,
                    backgroundColor: MyColors.c_C6A34F,
                    label: Text(
                        count >= 20
                            ? '20+'
                            : count == 0
                                ? ''
                                : count.toString(),
                        style: TextStyle(
                            fontSize: Get.width > 600 ? 13 : 12,
                            color: MyColors.white)),
                    child: Image.asset(MyAssets.bell,
                        height: 25.w,
                        width: 25.w,
                        color: MyColors.l111111_dwhite(context)),
                  ),
                );
              }),
              SizedBox(width: 30.w),
              Obx(() {
                int msgCount =
                    Get.find<ClientHomeController>().unreadMessages.value;
                return InkResponse(
                  onTap: () => Get.toNamed(Routes.chatIt),
                  child: Badge(
                    isLabelVisible: msgCount > 0,
                    backgroundColor: MyColors.c_C6A34F,
                    label: Text(msgCount > 0 ? msgCount.toString() : '',
                        style: TextStyle(
                            fontSize: Get.width > 600 ? 13 : 12,
                            color: MyColors.white)),
                    child: Image.asset(MyAssets.chat,
                        height: 25.w,
                        width: 25.w,
                        color: MyColors.l111111_dwhite(context)),
                  ),
                );
              }),
              SizedBox(width: 20.w),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: controller.onRefresh,
            backgroundColor: MyColors.lightCard(context),
            color: MyColors.primaryLight,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              controller: controller.scrollController,
              child: Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  children: [
                    Obx(() => Visibility(
                          visible: (controller.userProfileCompletionDetails
                                          .value?.profileCompleted ??
                                      0) <
                                  80 &&
                              controller.socialPostDataLoaded.value == true,
                          child: Padding(
                            padding: EdgeInsets.all(15.0.w),
                            child: GestureDetector(
                              onTap: () =>
                                  Get.toNamed(Routes.clientEditProfile),
                              child: ClientProgressIndicatorHomeWidget(
                                message: controller.getProgressMessage(),
                                progress: (controller
                                            .userProfileCompletionDetails
                                            .value
                                            ?.profileCompleted ??
                                        0) -
                                    0,
                              ),
                            ),
                          ),
                        )),
                    Padding(
                      padding: EdgeInsets.all(15.0.w),
                      child: const ClientHomePremiumHeaderWidget(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0.w),
                      child:
                          const ClientHomePremiumCandidateCategorySliderWidget(),
                    ),
                    _suggestedEmployees,
                    _employeeShortlisted,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                      child: Stack(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(50.0),
                            onTap: () {},
                            child: Container(
                              margin: EdgeInsets.only(bottom: 15.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.sp, vertical: 20.sp),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                gradient: Utils.primaryGradient,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: 20 / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          MyColors.lightCard(context)),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    "20%",
                                    style: TextStyle(color: MyColors.lightCard(context)),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                              child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 20.sp,
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.0.w),
                      child: const ClientHomePremiumTabWidget(),
                    ),
                    const ClientHomePremiumTabItemWidget()
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: controller.isNewPostAvailable.value &&
                  controller.selectedTabIndex.value == 1
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom: Platform.isIOS ? 100.0 : 60.0,
                  ),
                  child: FloatingActionButton(
                    backgroundColor: MyColors.primaryDark,
                    mini: true,
                    onPressed: () {
                      controller.onRefresh();
                    },
                    child: Icon(
                      CupertinoIcons.refresh,
                      size: 20,
                    ),
                  ),
                )
              : null,
        ));
  }

  Widget get _suggestedEmployees => Obx(
        () => Visibility(
          visible:
              Get.find<ClientHomeController>().countTotalRequestedEmployees() >
                  0,
          child: Padding(
            padding: EdgeInsets.only(left: 15.0.w, right: 15.0.w, top: 15.0.w),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: Get.find<ClientHomeController>()
                      .onSuggestedEmployeesClick,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    margin: EdgeInsets.only(bottom: 15.0.w),
                    decoration: BoxDecoration(
                        border: Border.all(color: MyColors.noColor, width: 0.5),
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: Utils.primaryGradient),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Get.find<ClientHomeController>().countTotalRequestedEmployees()} ${MyStrings.candidates.tr} ${MyStrings.areRequested.tr}",
                                style: Get.width > 600
                                    ? MyColors.white.semiBold13
                                    : MyColors.white.semiBold12,
                              ),
                              SizedBox(height: 7.h),
                              Text(
                                "${AppInfo.appName.toUpperCase()} ${MyStrings.suggestYou.tr} ${Get.find<ClientHomeController>().countSuggestedEmployees()} ${MyStrings.candidates.tr}",
                                style: Get.width > 600
                                    ? (MyColors.white.regular9)
                                        .copyWith(fontSize: 12.sp)
                                    : MyColors.white.regular10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.c_C6A34F,
                          ),
                          child: Icon(Icons.arrow_forward,
                              color: MyColors.white,
                              size: Get.width > 600 ? 16.sp : 15),
                        ),
                        SizedBox(
                          width: 15.w,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.find<ClientHomeController>()
                          .deleteAllRequestsFromClient();
                      // controller.isRequestRemove.value = true; // Update the state
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );

  Widget get _employeeShortlisted => Obx(
        () => Visibility(
          visible: Get.find<ClientHomeController>()
                  .shortlistController
                  .totalShortlisted
                  .value >
              0,
          child: Padding(
            padding: EdgeInsets.all(15.0.w),
            child: Stack(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50.0),
                  onTap: Get.find<ClientHomeController>().onShortlistClick,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 15.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.sp, vertical: 10.sp),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        gradient: Utils.primaryGradient),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${Get.find<ClientHomeController>().shortlistController.totalShortlisted.value} ${Get.find<ClientHomeController>().shortlistController.totalShortlisted.value > 1 ? MyStrings.candidates.tr : MyStrings.candidate.tr} ${MyStrings.areShortListed.tr}",
                                style: Get.width > 600
                                    ? MyColors.white.semiBold13
                                    : MyColors.white.semiBold12,
                              ),
                              SizedBox(height: 7.h),
                              Text(
                                MyStrings.hireThem.tr,
                                style: Get.width > 600
                                    ? MyColors.white.regular9
                                    : MyColors.white.regular10,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 2.w,
                        ),
                        Container(
                          padding: EdgeInsets.all(5.sp),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyColors.c_C6A34F,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: MyColors.white,
                            size: 15,
                          ),
                        ),
                        SizedBox(
                          width: 10.w,
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                    child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Get.find<ClientHomeController>()
                          .shortlistController
                          .deleteAllShortList();
                      // controller.isShortListRemove.value = true; // Update the state
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      );
}

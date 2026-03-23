import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_home_body_widget.dart';
import 'package:mh/app/routes/app_pages.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../../common/local_storage/storage.dart';
import '../../../../common/local_storage/storage_helper.dart';
import '../../../../helpers/responsive_helper.dart';

class EmployeeHomeView extends GetView<EmployeeHomeController> {
  const EmployeeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    // Ensure tutorial is created only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if((Storage.getValue<String>('isFirstTimeOpen') ?? '')=='') {
        if(controller.alreadyCreatedTutorial.value==0) {
          _createTutorial();
          _showTutorial(controller.context);
        }
      }
    });

    return Scaffold(
          extendBody: true,
          appBar: CustomAppbar.appbar(
            context: context,
            title: MyStrings.home.tr,
            centerTitle: false,
            onRefresh: controller.onRefresh,
            visibleBack: false,
            actions: [
              // SizedBox(width: 10.w),
              // const LanguageDropdown(),
              SizedBox(width: 10.w),
              _buildNotificationsCount(context),
              SizedBox(width: ResponsiveHelper.isTab(Get.context)? 10.w:30.w),
              _buildChatOption(context),
              SizedBox(width: ResponsiveHelper.isTab(Get.context)? 10.w:20.w),
              // InkWell(
              //   onTap: (){
              //     Get.toNamed(Routes.chatBot);
              //   },
              //   child: Image.asset(MyAssets.chatBot,
              //       height: 30.w,
              //       width: 30.w,
              //       color: MyColors.l111111_dwhite(context)),
              // ),
              // SizedBox(width: 20.w),
            ],
          ),
          body: EmployeeHomeBodyWidget(),
          // floatingActionButton: controller.isNewPostAvailable.value &&
          //         controller.selectedTabIndex.value == 1
          //     ? Padding(
          //         padding: EdgeInsets.only(
          //           bottom: Platform.isIOS ? 100.0 : 60.0,
          //         ),
          //         child: FloatingActionButton(
          //           backgroundColor: MyColors.primaryDark,
          //           mini: true,
          //           onPressed: () {
          //             controller.onRefresh();
          //           },
          //           child: Icon(
          //             CupertinoIcons.refresh,
          //             size: 20,
          //           ),
          //         ),
          //       )
          //     : null,
        );
  }


  void _showTutorial(context) {
    controller.tutorialCoachMark.show(context:context);
  }

  void _createTutorial() {
    controller.tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: MyColors.primaryDark,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        if (kDebugMode) {
          print("finish");
        }
        StorageHelper.setFirstTimeLogin(isFirstTime:'No');
      },
      onClickTarget: (target) {
        if (kDebugMode) {
          print('onClickTarget: $target');
        }
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        if (kDebugMode) {
          print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
        }},
      onClickOverlay: (target) {
        if (kDebugMode) {
          print('onClickOverlay: $target');
        }
      },
      onSkip: () {
        if (kDebugMode) {
          print("skip");
        }
        StorageHelper.setFirstTimeLogin(isFirstTime:'No');
        return true;
      },
    );
    controller.alreadyCreatedTutorial(1);
  }

  List<TargetFocus> _createTargets() {
    return [
      TargetFocus(
        identify: "Notifications",
        keyTarget: controller.keyNotifications,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Check your notifications here.\n You will get Candidate Check in Check out Notification, also Social Post Updates and Payment Updates as well as new tips notification from admin",
              style: TextStyle(color: Colors.white, fontFamily: MyAssets.fontKlavika, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Messages",
        keyTarget: controller.keyMessages,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "Check your messages here.\nStay connected! Chat in real time with Contractors, Business, or Admin Support.",
              style: TextStyle(color: Colors.white, fontFamily: MyAssets.fontKlavika, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Dashboard",
        keyTarget: controller.keyDashboard,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "\n\n\nIn Dashboard\nYou can see your list of hired history under any contractors also can see their feedback",
              style: TextStyle(color: Colors.white, fontFamily: MyAssets.fontKlavika, fontSize: 18),
            ),
          ),
        ],
      ),
      TargetFocus(
        identify: "Calender",
        keyTarget: controller.keyCalender,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: const Text(
              "\n\n\nIn My calender\nYou can change your unavailable dates also can update them so that contractors can make correct decisions",
              style: TextStyle(color: Colors.white, fontFamily: MyAssets.fontKlavika, fontSize: 18),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildChatOption(BuildContext context) {
    return Obx(
      () {
        int msgCount = controller.unreadMessages.value;
        return GestureDetector(
          key: controller.keyMessages,
          onTap: () => Get.toNamed(Routes.chatIt),
          child: Badge(
            isLabelVisible: msgCount > 0,
            backgroundColor: MyColors.c_C6A34F,
            label: Text(
              msgCount.toString(),
              style: TextStyle(
                fontSize: Get.width > 600 ? 13 : 12,
                color: MyColors.white,fontFamily: MyAssets.fontKlavika,
              ),
            ),
            child: Image.asset(
              MyAssets.chat,
              height: ResponsiveHelper.isTab(Get.context)? 15.w:25.w,
              width: ResponsiveHelper.isTab(Get.context)? 15.w:25.w,
              color: MyColors.l111111_dwhite(context),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationsCount(BuildContext context) {
    return Obx(
      () {
        int count = controller.notificationsController.unreadCount.value;
        return GestureDetector(
          key: controller.keyNotifications,
          onTap: () => Get.toNamed(Routes.notifications),
          child: Badge(
            isLabelVisible: count > 0,
            backgroundColor: MyColors.c_C6A34F,
            label: Text(
              count >= 20 ? '20+' : count.toString(),
              style: TextStyle(
                fontSize: Get.width > 600 ? 13 : 12,
                color: MyColors.white,fontFamily: MyAssets.fontKlavika,
              ),
            ),
            child: Image.asset(
              MyAssets.bell,
              height: ResponsiveHelper.isTab(Get.context)? 15.w:25.w,
              width: ResponsiveHelper.isTab(Get.context)? 15.w:25.w,
              color: MyColors.l111111_dwhite(context),
            ),
          ),
        );
      },
    );
  }
}

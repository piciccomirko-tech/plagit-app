import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/profile_card_widget.dart';
import 'package:mh/app/modules/client/client_home_premium/controllers/client_home_premium_controller.dart';
import 'package:mh/app/modules/client/client_profile/controllers/client_profile_controller.dart';
import 'package:mh/app/modules/client/client_profile/widgets/client_premium_header_widget.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/style/theme_controller.dart';

class ClientProfileView extends GetView<ClientProfileController> {
  ClientProfileView({super.key});
  final ThemeController themeController =
      Get.find(); // Access the theme controller

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
          title: MyStrings.myProfile.tr, context: context, centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0.w),
          child: Column(
            children: [
              const ClientPremiumHeaderWidget(),
              controller.appController.currentUserIsAlter.value?SizedBox():InkResponse(
                onTap: () => Get.toNamed(Routes.clientEditProfile),
                child: ProfileCardWidget(
                  title: MyStrings.editProfile.tr,
                  iconPath: MyAssets.editProfile,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              controller.appController.currentUserIsAlter.value?SizedBox():InkResponse(
                onTap: () => Get.toNamed(Routes.clientAccessControl),
                child: ProfileCardWidget(
                  title: MyStrings.accessControl.tr,
                  iconPath: MyAssets.accessControl,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              InkResponse(
                onTap: () => Get.toNamed(Routes.language),
                child: ProfileCardWidget(
                  title: MyStrings.language.tr,
                  icon: Icons.language,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              Obx(
                () => ProfileCardWidget(
                  title: MyStrings.themeMode.tr,
                  iconPath: MyAssets.theme,
                  trailing: Switch(
                    activeColor: MyColors.primaryLight,
                    value: themeController.themeMode.value == ThemeMode.dark,
                    onChanged: (value) {
                      if (value) {
                        themeController.switchTheme("dark"); // Set to dark mode
                      } else {
                        themeController
                            .switchTheme("light"); // Set to light mode
                      }
                    },
                  ),
                ),
              ),
              // InkResponse(
              //   onTap: () => Get.toNamed(Routes.location),
              //   child: ProfileCardWidget(
              //     title: "Language",
              //     icon: CupertinoIcons.location_solid,
              //     trailing: const Icon(CupertinoIcons.chevron_forward,
              //         color: MyColors.lightGrey),
              //   ),
              // ),
              // ProfileCardWidget(
              //   title: MyStrings.notificationSound.tr,
              //   iconPath: MyAssets.notification,
              //   trailing: Switch(
              //       activeColor: MyColors.primaryLight,
              //       value: true,
              //       onChanged: (value) {}),
              // ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.settings),
                child: ProfileCardWidget(
                  title: MyStrings.settings.tr,
                  iconPath: MyAssets.aboutUs,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              // GestureDetector(
              //   onTap: () => Get.toNamed(Routes.aboutUs),
              //   child: ProfileCardWidget(
              //     title: MyStrings.aboutUs.tr,
              //     iconPath: MyAssets.aboutUs,
              //     trailing: const Icon(CupertinoIcons.chevron_forward,
              //         color: MyColors.lightGrey),
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () => Get.toNamed(Routes.contactUs),
              //   child: ProfileCardWidget(
              //     title: MyStrings.contactUs.tr,
              //     iconPath: MyAssets.contactUs,
              //     trailing: const Icon(CupertinoIcons.chevron_forward,
              //         color: MyColors.lightGrey),
              //   ),
              // ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.clientSubscriptionPlans),
                child: ProfileCardWidget(
                  title: MyStrings.subscriptionPlan.tr,
                  iconPath: MyAssets.gem,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              InkResponse(
                onTap: () => Get.toNamed(Routes.clientSavedPost),
                child: ProfileCardWidget(
                  title: MyStrings.mySavedPost.tr,
                  icon: CupertinoIcons.bookmark,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.blocking),
                child: ProfileCardWidget(
                  title: MyStrings.blocking.tr,
                  iconPath: MyAssets.blocking,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              GestureDetector(
                onTap: () => Get.find<AppController>().onLogoutClick(),
                child: ProfileCardWidget(
                  title: MyStrings.logOut.tr,
                  iconPath: MyAssets.logOut,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              controller.appController.currentUserIsAlter.value?SizedBox():GestureDetector(
                onTap: () => Get.find<ClientHomePremiumController>()
                    .onAccountDeleteClick(),
                child: ProfileCardWidget(
                  title: MyStrings.deleteAccount.tr,
                  iconPath: MyAssets.logOut,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              const SizedBox(height: 10),
              Text("Plagit App v ${AppInfo.version}",
                  style: MyColors.l111111_dwhite(context).regular12),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

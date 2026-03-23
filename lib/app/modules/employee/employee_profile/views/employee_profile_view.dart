import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/employee/employee_edit_profile/widgets/employee_header_widget.dart';
import 'package:mh/app/common/widgets/profile_card_widget.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_profile/controllers/employee_profile_controller.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/style/theme_controller.dart';

class EmployeeProfileView extends GetView<EmployeeProfileController> {
  EmployeeProfileView({super.key});
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.myProfile.tr,
        context: context,
        onBackButtonPressed: () async {
          // Find the EmployeeHomeController instance
          final employeeHomeController = Get.find<EmployeeHomeController>();

          // Call getProfileCompletion with the user ID
          employeeHomeController.getProfileCompletion(
              Get.find<AppController>().user.value.userId);
await employeeHomeController.getPublicEmployeeDetails();

          // Optionally navigate back if required
          Get.back();
        },
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0.w),
          child: Column(
            children: [
              const EmployeeHeaderWidget(),

              GestureDetector(
                onTap: () => Get.toNamed(Routes.employeeEditProfile),
                child: ProfileCardWidget(
                  title: MyStrings.editProfile.tr,
                  iconPath: MyAssets.editProfile,
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
              GestureDetector(
                onTap: () => Get.toNamed(Routes.settings),
                child: ProfileCardWidget(
                  title: MyStrings.settings.tr,
                  iconPath: MyAssets.aboutUs,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              // ProfileCardWidget(
              //   title: MyStrings.notificationSound.tr,
              //   iconPath: MyAssets.notification,
              //   trailing: Switch(
              //       activeColor: MyColors.primaryLight,
              //       value: true,
              //       onChanged: (value) {}),
              // ),
            
              // GestureDetector(
              //     onTap: () => Get.toNamed(Routes.aboutUs),
              //   child: ProfileCardWidget(
              //     title: MyStrings.aboutUs.tr,
              //     iconPath: MyAssets.aboutUs,
              //     trailing: const Icon(CupertinoIcons.chevron_forward,
              //         color: MyColors.lightGrey),
              //   ),
              // ),
              // GestureDetector(
              //     onTap: () => Get.toNamed(Routes.contactUs),
              //   child: ProfileCardWidget(
              //     title: MyStrings.contactUs.tr,
              //     iconPath: MyAssets.contactUs,
              //     trailing: const Icon(CupertinoIcons.chevron_forward,
              //         color: MyColors.lightGrey),
              //   ),
              // ),
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
              GestureDetector(
                onTap: () =>
                    Get.find<EmployeeHomeController>().onAccountDeleteClick(),
                child: ProfileCardWidget(
                  title: MyStrings.deleteAccount.tr,
                  iconPath: MyAssets.logOut,
                  trailing: const Icon(CupertinoIcons.chevron_forward,
                      color: MyColors.lightGrey),
                ),
              ),
              const SizedBox(height: 10),
              Text("Plagit App v ${AppInfo.version}",
                  style: MyColors.l111111_dwhite(context).regular12)
            ],
          ),
        ),
      ),
    );
  }
}

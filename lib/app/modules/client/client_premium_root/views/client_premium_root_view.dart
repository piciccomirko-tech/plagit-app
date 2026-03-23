import 'package:flutter/services.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/client/client_premium_root/controllers/client_premium_root_controller.dart';
import 'package:mh/app/modules/client/client_premium_root/widgets/client_premium_bottom_nav_bar_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

class ClientPremiumRootView extends GetView<ClientPremiumRootController> {
  const ClientPremiumRootView({super.key});

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return Obx(() {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          if (controller.selectedIndex.value != 0) {
            controller.selectedIndex.value = 0;
          } else {
            final result = await Get.dialog<bool>(
              AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r)),
                title: Text('Exit App'),
                content: Text('Do you want to exit the app?'),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: Text('No',style: TextStyle(color: MyColors.primaryLight),),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: Text('Yes',style: TextStyle(color: MyColors.primaryLight),),
                  ),
                ],
              ),
            );
            if (result == true) {
              // Use system navigator to exit app
              SystemNavigator.pop();
            }
          }
        },
        child: Scaffold(
            extendBody: true,
            body: Stack(
              children: [
                controller.currentPage,
                Obx(() => controller.showExpandable.value
                    ? Positioned(
                        child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 120.0),
                          child: Stack(
                            children: [
                              Image.asset(MyAssets.expandable),
                              Positioned.fill(
                                  child: Align(
                                alignment: Alignment.center,
                                child: IntrinsicHeight(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: () {
                                              controller.showExpandable.value =
                                                  !controller
                                                      .showExpandable.value;
                                              Get.toNamed(Routes.createPost);
                                            },
                                            child: Row(
                                              children: [
                                                ColorFiltered(
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                          MyColors.c_9A9A9A,
                                                          BlendMode.color),
                                                  child: Image.asset(
                                                      MyAssets.socialPost,
                                                      width: 20.w,
                                                      height: 20.w),
                                                ),
                                                Text(
                                                    "  ${MyStrings.createSocialPost.tr}",
                                                    style: MyColors
                                                        .c_9A9A9A.medium17)
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Flexible(
                                          flex: 2,
                                          child: VerticalDivider(
                                            thickness: 1.0,
                                            color: MyColors.c_9A9A9A,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: () {
                                              controller.showExpandable.value =
                                                  !controller
                                                      .showExpandable.value;
                                              Get.toNamed(Routes.createJobPost);
                                            },
                                            child: Row(
                                              children: [
                                                ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                      MyColors.c_9A9A9A
                                                          .withOpacity(1),
                                                      BlendMode.color),
                                                  child: Image.asset(
                                                      MyAssets.jobPost,
                                                      width: 20.w,
                                                      height: 20.w),
                                                ),
                                                Text(
                                                    "  ${MyStrings.createJobPost.tr}",
                                                    style: MyColors
                                                        .c_9A9A9A.medium17)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      ))
                    : const Wrap())
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: keyboardIsOpened
                ? null
                : ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: Obx(() => FloatingActionButton(
                          onPressed: controller.onFloatingButtonClick,
                          backgroundColor: controller.showExpandable.value
                              ? MyColors.c_9A9A9A
                              : MyColors.primaryDark,
                          child: Icon(
                              controller.showExpandable.value
                                  ? Icons.clear
                                  : Icons.add,
                              color: Colors.white,
                              size: Get.width > 600 ? 20.sp : null),
                        )),
                  ),
            bottomNavigationBar: const ClientPremiumBottomNavBarWidget()),
      );
    });
  }
}

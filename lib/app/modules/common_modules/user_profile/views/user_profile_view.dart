import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../controllers/user_profile_controller.dart';
import '../widgets/user_profile_employee_tab_item_widget.dart';
import '../widgets/user_profile_employee_tab_widget.dart';
import '../widgets/user_profile_social_user_info_widget.dart';
import '../widgets/user_profile_tab_items_widget.dart';
import '../widgets/user_profile_tab_widget.dart';

class UserProfileView extends GetView<UserProfileController> {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      bottomNavigationBar: _bottomBar(context),
      appBar: CustomAppbar.appbar(title: 'User Profile', context: Get.context!),
      body: Obx(() => controller.loading.value == true
          ? Center(child: CustomLoader.loading())
          : controller.loadingUserDetails.value == true
              ? Center(child: CustomLoader.loading())
              : controller.loadingFollowers.value == true
                  ? Center(child: CustomLoader.loading())
                  : controller.employee.value.role?.toUpperCase() == "CLIENT"
                      ? SingleChildScrollView(
                          controller: controller.scrollController,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 15.w),
                              UserProfileSocialUserInfoWidget(),
                              UserProfileTabWidget(),
                              UserProfileTabItemWidget(),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          controller: controller.scrollController,
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(height: 15.w),
                              UserProfileEmployeeTabWidget(),
                              UserProfileEmployeeTabItemWidget(),
                            ],
                          ),
                        )),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Obx(() => Visibility(
        visible: !controller.loading.value,
        child: controller.employee.value.role?.toUpperCase() == "EMPLOYEE" &&
                ((!controller.appController.user.value.isEmployee ||
                        controller.appController.user.value.isClient) &&
                    controller.appController.user.value.userCountry
                            .toLowerCase() ==
                        controller.employee.value.countryName?.toLowerCase() &&
                    !controller.appController.user.value.isAdmin)
            ? CustomBottomBar(
                child: CustomButtons.button(
                  height: Get.width > 600 ? 30.h : 48.h,
                  fontSize: 17,
                  onTap: ((controller.employee.value.available ?? "").isEmpty ||
                          int.parse((controller.employee.value.available ?? "")
                                  .split(' ')
                                  .first) <=
                              0)
                      ? null
                      : controller.onBookNowClick,
                  text: ((controller.employee.value.available ?? "").isEmpty ||
                          int.parse((controller.employee.value.available ?? "")
                                  .split(' ')
                                  .first) <=
                              0)
                      ? MyStrings.booked.tr
                      : MyStrings.bookNow.tr,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                ),
              )
            : Wrap()));
  }
}

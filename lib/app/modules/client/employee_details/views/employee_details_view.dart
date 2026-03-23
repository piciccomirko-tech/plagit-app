import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/client/employee_details/widgets/employee_details_tab_item_widget.dart';
import 'package:mh/app/modules/client/employee_details/widgets/employee_details_tab_widget.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../controllers/employee_details_controller.dart';

class EmployeeDetailsView extends GetView<EmployeeDetailsController> {
  const EmployeeDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      bottomNavigationBar: _bottomBar(context),
      appBar: CustomAppbar.appbar(
          title:controller.isCandidate? "Candidate Details":"Client Details", context: context, centerTitle: true),
      body: Obx(() => controller.loading.value == true
          ? Center(child: CustomLoader.loading())
          : SingleChildScrollView(
              controller: controller.scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 15.w),
                  EmployeeDetailsTabWidget(),
                  EmployeeDetailsTabItemWidget(),
                ],
              ),
            )),
    );
  }

  Widget _bottomBar(BuildContext context) {
    return Obx(() => Visibility(
        visible: !controller.loading.value,
        child: ((!controller.appController.user.value.isEmployee ||
                    controller.appController.user.value.isClient) &&
                controller.appController.user.value.userCountry.toLowerCase() ==
                    controller.employee.value.countryName?.toLowerCase() && controller.isCandidate && !controller.appController.user.value.isAdmin)
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
            : Wrap()

        /* CustomBottomBar(
                child: CustomButtons.button(
                    height: Get.width > 600 ? 35.h : 48.h,
                    onTap: controller.onViewCalenderClick,
                    text: MyStrings.viewCalendar.tr,
                    customButtonStyle:
                        CustomButtonStyle.radiusTopBottomCorner))*/
        ));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/app_info/app_info.dart';
import 'package:mh/app/common/widgets/custom_network_image.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/auth/login/widgets/language_drop_down.dart';
import 'package:mh/app/modules/client/client_home/widgets/client_bottom_nav_bar_widget.dart';
import 'package:mh/app/modules/client/client_home/widgets/client_home_items_widget.dart';
import 'package:mh/app/modules/client/client_home/widgets/position_search_field_widget.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../controllers/client_home_controller.dart';

class ClientHomeView extends GetView<ClientHomeController> {
  const ClientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return WillPopScope(
      onWillPop: () async => Utils.appExitConfirmation(context),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0)
          ),
          backgroundColor: MyColors.c_C6A34F,
          onPressed: controller.refreshPage,
          child: const Icon(CupertinoIcons.refresh, color: Colors.white, size: 25),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const ClientBottomNavBarWidget(),
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
                child: const Icon(CupertinoIcons.bell, size: 21),
              ),
            )),
            const SizedBox(width: 30),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
                            width: Get.width,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [MyColors.c_C6A34F, Colors.blueGrey.shade900], // Gradient colors
                                ),
                                borderRadius: BorderRadius.circular(10.0)
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _restaurantName(MyStrings.hiRestaurant.trParams({
                                  "restaurantName":
                                  controller.appController.user.value.client?.restaurantName ?? "owner of the",
                                })),
                                SizedBox(height: 10.h),
                                _promotionText,
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),

                          const PositionSearchFieldWidget(),
                          _suggestedEmployees,

                          // _dueInvoice,

                          Obx(
                                () => Visibility(
                              visible: controller.shortlistController.totalShortlisted.value > 0,
                              child: SizedBox(
                                height: 20.h,
                              ),
                            ),
                          ),

                          _employeeShortlisted,

                          SizedBox(height: 20.h),
                          const ClientHomeItemsWidget()
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            Positioned.fill(
                child: Align(
                    alignment: Alignment.topCenter,
                    child: Obx(() => Visibility(
                        visible: controller.positionList.isNotEmpty,
                        child: Container(
                          margin: const EdgeInsets.only(top: 80.0, left: 15.0, right: 15.0),
                          height: MediaQuery.of(context).size.height * 0.35,
                          decoration: BoxDecoration(
                              color: MyColors.lightCard(context)
                          ),
                          child: ListView.builder(
                              itemCount: controller.positionList.length,
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                DropdownItem position = controller.positionList[index];
                                return ListTile(
                                  onTap: () => controller.onSearchItemTap(position: position),
                                  leading: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CustomNetworkImage(url: (position.logo ?? '').uniformImageUrl),
                                  ),
                                  title:
                                  Text(position.name ?? '', style: MyColors.l111111_dwhite(context).semiBold16),
                                  trailing: const Icon(CupertinoIcons.arrow_up_left, color: MyColors.c_C6A34F),
                                );
                              }),
                        )))))
          ],
        ),
      ),
    );
  }

  Widget _restaurantName(String name) => Text(
    name,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: MyColors.white.semiBold18,
  );

  Widget get _promotionText => Text(
    MyStrings.exploreTheFeaturesOfPlagitAppBelow.tr,
    style: MyColors.white.medium15,
  );

  Widget get _suggestedEmployees => Obx(
        () => Visibility(
      visible: (controller.requestedEmployees.value.requestEmployeeList ?? []).isNotEmpty,
      child: GestureDetector(
        onTap: controller.onSuggestedEmployeesClick,
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 20.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: MyColors.lightCard(controller.context!)
            /* gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [MyColors.c_C6A34F, Colors.blueGrey], // Gradient colors
                ),*/
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${controller.countTotalRequestedEmployees()} ${MyStrings.employees.tr} ${MyStrings.areRequested.tr}",
                      style: MyColors.c_C6A34F.semiBold16,
                    ),
                    SizedBox(height: 7.h),
                    Text(
                      "${AppInfo.appName.toUpperCase()} ${MyStrings.suggestYou.tr} ${controller.countSuggestedEmployees()} ${MyStrings.employees.tr}",
                      style: MyColors.c_C6A34F.regular12,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.c_C6A34F,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: MyColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget get _employeeShortlisted => Obx(
        () => Visibility(
      visible: controller.shortlistController.totalShortlisted.value > 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: controller.onShortlistClick,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColors.lightCard(controller.context!),
            /*gradient: const LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [MyColors.c_C6A34F, Colors.blueGrey], // Gradient colors
                  ),*/
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${controller.shortlistController.totalShortlisted.value} ${controller.shortlistController.totalShortlisted.value > 1 ? MyStrings.employees.tr : MyStrings.employee.tr} ${MyStrings.areShortListed.tr}",
                      style: MyColors.c_C6A34F.semiBold16,
                    ),
                    SizedBox(height: 7.h),
                    Text(
                      MyStrings.hireThem.tr,
                      style: MyColors.c_C6A34F.regular12,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.c_C6A34F,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: MyColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
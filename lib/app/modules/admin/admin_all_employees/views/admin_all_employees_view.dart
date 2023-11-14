import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_filter.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employees_by_id.dart';
import '../controllers/admin_all_employees_controller.dart';

class AdminAllEmployeesView extends GetView<AdminAllEmployeesController> {
  const AdminAllEmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Employees",
        context: context,
        centerTitle: true,
      ),
      body: Obx(
        () => (controller.employees.value.users ?? []).isEmpty
            ? controller.employeeDataLoading.value
                ? Padding(
                    padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 70.h),
                    child: Center(child: ShimmerWidget.clientMyEmployeesShimmerWidget()),
                  )
                : Column(
                    children: [
                      _resultCountWithFilter(),
                      const Spacer(),
                      const NoItemFound(),
                      const Spacer(),
                    ],
                  )
            : Column(
                children: [
                  _resultCountWithFilter(),
                  Expanded(
                    child: ListView.builder(
                      //controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      itemCount: controller.employees.value.users?.length ?? 0,
                      itemBuilder: (context, index) {
                        /*  if (index == controller.employees.value.users!.length - 1 &&
                            controller.moreDataAvailable.value == true) {
                          return const SpinKitThreeBounce(
                            color: MyColors.c_C6A34F,
                            size: 40,
                          );
                        }*/
                        return _employeeItem(
                          controller.employees.value.users![index],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _resultCountWithFilter() {
    return Padding(
      padding: EdgeInsets.fromLTRB(15.w, 10.h, 15.w, 0),
      child: Row(
        children: [
          Text(
            "${controller.employees.value.users?.length ?? 0}",
            style: MyColors.c_C6A34F.semiBold16,
          ),
          Text(
            " Employees are showing",
            style: MyColors.l111111_dwhite(controller.context!).semiBold16,
          ),
          const Spacer(),
          Obx(() => Visibility(
              visible: controller.nationalityDataLoad.value == true && controller.hourlyRateDataLoaded.value == true,
              child: GestureDetector(
                onTap: () => CustomFilter.customFilter(
                  context: controller.context!,
                  hourlyRateDetails: controller.hourlyRateDetails.value,
                  nationalityList: controller.nationalityList,
                  onApplyClick: controller.onApplyClick,
                  onResetClick: controller.onResetClick,
                  showPositionId: true,
                ),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.c_DDBD68,
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    color: Colors.white,
                  ),
                ),
              )))
        ],
      ),
    );
  }

  Widget _employeeItem(Employee user) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w).copyWith(
        bottom: 20.h,
      ),
      decoration: BoxDecoration(
        color: MyColors.lightCard(controller.context!),
        borderRadius: BorderRadius.circular(10.0).copyWith(
          bottomRight: const Radius.circular(11),
        ),
        border: Border.all(
          width: .5,
          color: MyColors.c_A6A6A6,
        ),
      ),
      child: InkWell(
        onTap: () => controller.onEmployeeClick(user),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: 122.w,
                child: CustomButtons.button(
                  height: 28.w,
                  text:
                      "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${user.hourlyRate ?? 0} / hour",
                  margin: EdgeInsets.zero,
                  fontSize: 12,
                  customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                  onTap: () {},
                ),
              ),
            ),
            Positioned(
              right: 10.w,
              top: 5.h,
              child: _chat(user: user),
            ),
            Positioned(
              right: 40.w,
              top: 5.h,
              child: GestureDetector(
                onTap: () => controller.onCalenderClick(employeeId: user.id ?? ''),
                child: Image.asset(
                  MyAssets.calender2,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
            Row(
              children: [
                _image((user.profilePicture ?? "").imageUrl),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Flexible(
                                        flex: user.rating! > 0.0 ? 2 : 4,
                                        child: _name("${user.firstName ?? "-"} ${user.lastName ?? ""}")),
                                    if (user.certified != null && user.certified == true)
                                      Image.asset(MyAssets.certified, height: 30, width: 30),
                                    Expanded(flex: 2, child: _rating(user.rating ?? 0)),
                                    const Expanded(flex: 2, child: Wrap()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      const Divider(
                        thickness: .5,
                        height: 1,
                        color: MyColors.c_D9D9D9,
                        endIndent: 13,
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _detailsItem(controller.getPositionLogo(user.positionId!), user.positionName ?? "", ""),
                          _activeStatus(active: user.active ?? false),
                          const SizedBox(width: 7),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _detailsItem(
                              MyAssets.totalHour, MyStrings.totalHour.tr, (user.totalWorkingHour ?? 0.0).toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _image(String profilePicture) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 13, 16),
        width: 74.w,
        height: 74.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.withOpacity(.1),
        ),
        child: CustomNetworkImage(
          url: profilePicture,
          radius: 5,
        ),
      );

  Widget _name(String name) => Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: MyColors.l111111_dwhite(controller.context!).medium14,
      );

  Widget _rating(double rating) => Visibility(
        visible: rating > 0.0,
        child: Row(
          children: [
            Container(
              height: 2.h,
              width: 2.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.l111111_dwhite(controller.context!),
              ),
            ),
            SizedBox(width: 10.w),
            const Icon(
              Icons.star,
              color: MyColors.c_FFA800,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              rating.toString(),
              style: MyColors.l111111_dwhite(controller.context!).medium14,
            ),
          ],
        ),
      );

  Widget _detailsItem(String icon, String title, String value) => Expanded(
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 14.w,
              height: 14.w,
            ),
            SizedBox(width: 10.w),
            Text(
              title,
              style: MyColors.l7B7B7B_dtext(controller.context!).medium11,
            ),
            SizedBox(width: 3.w),
            Text(
              value,
              style: MyColors.l111111_dwhite(controller.context!).medium11,
            ),
          ],
        ),
      );

  Widget _activeStatus({required bool active}) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: ((active == true)) ? MyColors.c_00C92C_10 : MyColors.c_FF5029_10,
        ),
        child: Row(
          children: [
            Container(
              height: 11,
              width: 11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ((active == true)) ? MyColors.c_00C92C : MyColors.c_C92C1A,
              ),
            ),
            const SizedBox(width: 5),
            Text(((active == true)) ? 'Active' : 'Inactive',
                style: MyColors.l111111_dwhite(controller.context!).medium11)
          ],
        ),
      );

  Widget _chat({required Employee user}) => GestureDetector(
        onTap: () => controller.onChatClick(user),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.message,
                color: MyColors.c_C6A34F,
              ),
              Positioned(
                top: -15,
                right: -10.w,
                child: Obx(
                  () {
                    Iterable<Map<String, dynamic>> result = controller.adminHomeController.employeeChatDetails.where(
                        (Map<String, dynamic> data) =>
                            data["role"] == "EMPLOYEE" &&
                            data['${user.id}_unread'] == 0 &&
                            data["allAdmin_unread"] > 0);
                    if (result.isEmpty) return Container();
                    return Padding(
                      padding: EdgeInsets.only(top: 5.0.h, right: 3.0.w),
                      child: CustomBadge(result.first["allAdmin_unread"].toString()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';

import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_filter.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employees_by_id.dart';
import '../controllers/admin_client_request_position_employees_controller.dart';

class AdminClientRequestPositionEmployeesView extends GetView<AdminClientRequestPositionEmployeesController> {
  const AdminClientRequestPositionEmployeesView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        context: context,
        title: "Employees",
      ),
      body: Obx(
        () => (controller.employees.value.users ?? []).isEmpty
            ? controller.isLoading.value
                ? Padding(
                    padding: EdgeInsets.only(top: 70.h, left: 15.w, right: 15.w),
                    child: ShimmerWidget.clientMyEmployeesShimmerWidget(),
                  )
                : Column(
                    children: [
                      _resultCountWithFilter(),
                      const NoItemFound(),
                    ],
                  )
            : Column(
                children: [
                  _resultCountWithFilter(),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      itemCount: controller.employees.value.users?.length ?? 0,
                      itemBuilder: (context, index) {
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
            (controller.employees.value.users?.length ?? 0).toString(),
            style: MyColors.c_C6A34F.semiBold16,
          ),
          Text(
            " ${controller.clientRequestDetail.positionName ?? "Employees"} are showing",
            style: MyColors.l111111_dwhite(controller.context!).semiBold16,
          ),
          const Spacer(),
          Obx(() => Visibility(
              visible: controller.nationalityDataLoaded.value == true && controller.hourlyRateDataLoaded.value == true,
              child: GestureDetector(
                onTap: () => CustomFilter.customFilter(
                  context: controller.context!,
                  hourlyRateDetails: controller.hourlyRateDetails.value,
                  nationalityList: controller.nationalityList,
                  onApplyClick: controller.onApplyClick,
                  onResetClick: controller.onResetClick,
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
              ))),
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
              child: Row(
                children: [
                  if (user.isSuggested != null && user.isSuggested == true)
                    InkWell(
                        onTap: () => controller.onCancelClick(employeeId: user.id ?? ''),
                        child: const Icon(Icons.cancel, color: Colors.red, size: 20)),
                  SizedBox(width: 10.w),
                  SizedBox(
                      width: 100.w,
                      child: CustomButtons.button(
                        height: 23.w,
                        text: (user.isHired ?? false)
                            ? controller.hireStatus.value
                            : user.isSuggested != null && user.isSuggested == true
                                ? "Suggested"
                                : "Suggest",
                        margin: EdgeInsets.zero,
                        fontSize: 12,
                        customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                        onTap: (user.isHired ?? false) || (user.isSuggested != null && user.isSuggested == true)
                            ? null
                            : () => controller.onSuggestClick(user),
                      )),
                ],
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
                                        flex: user.rating! > 0.0 ? 3 : 4,
                                        child: _name("${user.firstName ?? "-"} ${user.lastName ?? ""}")),
                                    Expanded(flex: 2, child: _rating(user.rating ?? 0.0)),
                                    const Expanded(flex: 2, child: Wrap())
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
                          _detailsItem(MyAssets.exp, MyStrings.exp.tr, (user.employeeExperience ?? 0).toString()),
                          _detailsItem(
                              MyAssets.totalHour, MyStrings.totalHour.tr, (user.totalWorkingHour ?? 0).toString()),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _detailsItem(MyAssets.rate, MyStrings.rate.tr,
                              "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.admin?.countryName ?? '')}${user.hourlyRate ?? 0}"),
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
        visible: rating > 0,
        child: Row(
          children: [
            SizedBox(width: 10.w),
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
}

import 'package:badges/badges.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_filter.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../../../../models/employees_by_id.dart';
import '../controllers/mh_employees_by_id_controller.dart';
import 'package:badges/badges.dart' as badge;

class MhEmployeesByIdView extends GetView<MhEmployeesByIdController> {
  const MhEmployeesByIdView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
          title: controller.position.name ?? "Employees",
          context: context,
          centerTitle: true,
          actions: [
            Obx(
              () => Visibility(
                visible: controller.shortlistController.totalShortlisted.value > 0,
                child: Center(
                  child: badge.Badge(
                    position: badge.BadgePosition.topEnd(top: -9, end: -4),
                    onTap: controller.goToShortListedPage,
                    ignorePointer: false,
                    badgeContent: Text(
                      controller.shortlistController.totalShortlisted.value.toString(),
                      style: MyColors.white.semiBold12,
                    ),
                    badgeStyle: const BadgeStyle(
                      badgeColor: MyColors.c_C6A34F,
                      elevation: 0,
                    ),
                    child: GestureDetector(
                      onTap: controller.goToShortListedPage,
                      child: const Icon(Icons.bookmark_outline_rounded),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
          ]),
      body: Obx(
        () => (controller.employees.value.users ?? []).isEmpty
            ? controller.isLoading.value
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 70.h),
                      child: ShimmerWidget.clientMyEmployeesShimmerWidget(),
                    ),
                  )
                : const NoItemFound()
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
      padding: EdgeInsets.fromLTRB(15, 10.h, 15, 0),
      child: Row(
        children: [
          Text(
            (controller.employees.value.users?.length ?? 0).toString(),
            style: MyColors.c_C6A34F.semiBold16,
          ),
          Text(
            " ${controller.position.name ?? "Employees"} are showing",
            style: MyColors.l111111_dwhite(controller.context!).semiBold16,
          ),
          const Spacer(),
          Obx(() => Visibility(
              visible:
                  controller.hourlyDetailsDataLoaded.value == true && controller.nationalityDataLoaded.value == true,
              child: GestureDetector(
                onTap: () => CustomFilter.customFilter(
                  context: controller.context!,
                  nationalityList: controller.nationalityList,
                  hourlyRateDetails: controller.hourlyRateDetails.value,
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
              right: 5,
              top: 3,
              child: Obx(
                () => controller.shortlistController.getIcon(
                    requestedDateList: <RequestDateModel>[],
                    employeeId: user.id!,
                    isFetching: controller.shortlistController.isFetching.value,
                    fromWhere: '',
                  uniformMandatory: user.hasUniform == true ? null : false

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
                                        flex: user.rating! > 0.0 ? 3 : 4,
                                        child: _name("${user.firstName ?? "-"} ${user.lastName ?? ""}")),
                                    if (user.certified != null && user.certified == true)
                                      Image.asset(MyAssets.certified, height: 30, width: 30),
                                    Expanded(flex: 2, child: _rating(user.rating ?? 0.0)),
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
                          _detailsItem(MyAssets.exp, MyStrings.exp.tr, "${user.employeeExperience ?? 0} years"),
                          _detailsItem(MyAssets.flag, '', user.nationality??''),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(children: [
                        _detailsItem(MyAssets.rate, 'Rate:',
                            "${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${(user.hourlyRate ?? 0.0).toStringAsFixed(2)}"),
                        _detailsItem(MyAssets.manager, MyStrings.age.tr, user.dateOfBirth?.calculateAge() ?? ''),
                      ]),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _detailsItem(MyAssets.calender2, 'Available:', user.available ?? ''),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButtons.button(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            height: 23,
                            text: (user.available == null || int.parse(user.available!.split(' ').first) <= 0)
                                ? "Booked"
                                : "Book Now",
                            margin: EdgeInsets.zero,
                            fontSize: 12,
                            customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                            onTap: (user.available == null || int.parse(user.available!.split(' ').first) <= 0)
                                ? null
                                : () => controller.onBookNowClick(user),
                          )
                        ],
                      )
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
        width: 70.w,
        height: 74.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.withOpacity(.1),
        ),
        child: CustomNetworkImage(
          url: profilePicture,
          fit: BoxFit.fill,
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
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(controller.context!).medium11,
              ),
            ),
          ],
        ),
      );
}

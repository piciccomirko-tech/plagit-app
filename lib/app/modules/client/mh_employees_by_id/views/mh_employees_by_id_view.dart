import 'package:badges/badges.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import '../../../../common/local_storage/storage_helper.dart';
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
          title: controller.position.name ?? MyStrings.employees.tr,
          context: context,
          centerTitle: true,
          actions: [
            Obx(
              () => Visibility(
                visible:
                    controller.shortlistController.totalShortlisted.value > 0,
                child: Center(
                  child: badge.Badge(
                    position:
                        badge.BadgePosition.topEnd(top: -9.sp, end: -4.sp),
                    onTap: controller.goToShortListedPage,
                    ignorePointer: false,
                    badgeContent: Text(
                      controller.shortlistController.totalShortlisted.value
                          .toString(),
                      style: MyColors.white.semiBold12,
                    ),
                    badgeStyle: const BadgeStyle(
                      badgeColor: MyColors.c_C6A34F,
                      elevation: 0,
                    ),
                    child: GestureDetector(
                      onTap: controller.goToShortListedPage,
                      child: Icon(Icons.bookmark_outline_rounded,
                          size: Get.width > 600 ? 35 : 25),
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
                      padding:
                          EdgeInsets.only(left: 15.w, right: 15.w, top: 55.h),
                      child: ShimmerWidget.clientMyEmployeesShimmerWidget(
                          height: 135.w),
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
                      itemBuilder: (BuildContext context, int index) {
                        return _employeeItem(
                          (controller.employees.value.users ?? [])[index],
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
      padding: EdgeInsets.fromLTRB(15.sp, 10.h, 15.sp, 0),
      child: Row(
        children: [
          Text(
            (controller.employees.value.users?.length ?? 0).toString(),
            style: Get.width > 600
                ? MyColors.c_C6A34F.semiBold13
                : MyColors.c_C6A34F.semiBold16,
          ),
          Text(
            " ${controller.position.name ?? MyStrings.employees.tr} ${MyStrings.areShowing.tr}",
            style: Get.width > 600
                ? MyColors.l111111_dwhite(controller.context!).semiBold13
                : MyColors.l111111_dwhite(controller.context!).semiBold16,
          ),
          const Spacer(),
          Obx(() => Visibility(
              visible: controller.hourlyDetailsDataLoaded.value == true &&
                  controller.nationalityDataLoaded.value == true,
              child: GestureDetector(
                onTap: () => CustomFilter.customFilter(
                  context: controller.context!,
                  nationalityList: controller.nationalityList,
                  hourlyRateDetails: controller.hourlyRateDetails.value,
                  onApplyClick: controller.onApplyClick,
                  onResetClick: controller.onResetClick,
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColors.c_C6A34F,
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
        bottom: 15.w,
      ),
      decoration: BoxDecoration(
        color: MyColors.lightCard(controller.context!),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          width: .5,
          color: MyColors.lightGrey,
        ),
      ),
      child: InkWell(
        onTap: () => controller.onEmployeeClick(user),
        child: Stack(
          children: [
            Obx(
              () => Positioned.fill(
                right: StorageHelper.getLanguage == 'ar'?0:15,
                left: StorageHelper.getLanguage == 'ar'?15:0,
                top: 16.h,
                child: Align(
                  alignment: StorageHelper.getLanguage == 'ar'
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  child: controller.shortlistController.getIcon(
                      requestedDateList: <RequestDateModel>[],
                      employeeId: user.id!,
                      isFetching:
                          controller.shortlistController.isFetching.value,
                      fromWhere: '',
                      uniformMandatory: user.hasUniform == true ? null : false),
                ),
              ),
            ),
            Row(
              children: [
                Column(
                  children: [
                    ((user.profilePicture ?? "").isEmpty) ||
                            user.profilePicture == "undefined"
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(16, 16, 13, 16),
                            width: 70.w,
                            height: 74.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.grey.withOpacity(.1),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: Image.asset(MyAssets.employeeDefault,
                                    fit: BoxFit.fill)),
                          )
                        : _image((user.profilePicture ?? "").imageUrl),
                    Container(
                      height: Get.width > 600 ? 30.h : 35.h,
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(horizontal: 10.sp,vertical: 0),
                      decoration: BoxDecoration(
                        color: MyColors.c_C6A34F,
                        // gradient: Utils.primaryGradient,
                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                          onTap:  (user.available == null || int.parse(user.available!.split(' ').first) <= 0) ? null : () => controller.onBookNowClick(user),
                          child: Center(
                            child: Text(
                              (user.available == null ||
                                      int.parse(user.available!
                                              .split(' ')
                                              .first) <=
                                          0)
                                  ? MyStrings.booked.tr
                                  : MyStrings.bookNow.tr.capitalize!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontFamily: MyAssets.fontKlavika,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: MyColors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.w,)
                    // Padding(
                    //   padding: const EdgeInsets.only(left:8,right:8,bottom: 8.0),
                    //   child: CustomButtons.button(
                    //     padding:  EdgeInsets.symmetric(horizontal: 10.sp),
                    //     height: Get.width>600?30.h:38.h,
                    //     text: (user.available == null || int.parse(user.available!.split(' ').first) <= 0)
                    //         ? MyStrings.booked.tr
                    //         : MyStrings.bookNow.tr,
                    //     margin: EdgeInsets.zero,
                    //     fontSize: 14.sp,
                    //     customButtonStyle: CustomButtonStyle.circular,
                    //     onTap: (user.available == null || int.parse(user.available!.split(' ').first) <= 0)
                    //         ? null
                    //         : () => controller.onBookNowClick(user),
                    //   ),
                    // ),
                  ],
                ),
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
                                        child: _name(
                                            "${user.firstName ?? "-"} ${user.lastName ?? ""}")),
                                    if (user.certified != null &&
                                        user.certified == true)
                                      Image.asset(MyAssets.certified,
                                          height: 30, width: 30),
                                    Expanded(
                                        flex: 2,
                                        child: _rating(user.rating ?? 0.0)),
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
                          _detailsItem(MyAssets.exp, MyStrings.exp.tr,
                              "${user.employeeExperience ?? 0} ${MyStrings.years.tr}"),
                          _detailsItem(MyAssets.icAge, "${MyStrings.age.tr}:",
                              user.dateOfBirth?.calculateAge() ?? ''),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(children: [
                        _detailsItem(MyAssets.rate, "${MyStrings.rate.tr}:",
                            "${Utils.getCurrencySymbol()}${(user.hourlyRate ?? 0.0).toStringAsFixed(2)}"),
                        _detailsItem(MyAssets.flag, '', user.nationality ?? ''),
                      ]),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _detailsItem(
                              MyAssets.calender2,
                              "${MyStrings.available.tr}:",
                              user.available ?? ''),
                        ],
                      ),
                      SizedBox(height: 8.h),
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
        margin: const EdgeInsets.fromLTRB(16, 16, 13, 10),
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
        style: MyColors.l111111_dwhite(controller.context!).medium17,
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
              style: MyColors.l7B7B7B_dtext(controller.context!).medium15,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MyColors.l111111_dwhite(controller.context!).medium16,
              ),
            ),
          ],
        ),
      );
}

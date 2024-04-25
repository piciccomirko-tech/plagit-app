import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_bottombar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../../../../common/widgets/no_item_found.dart';
import '../controllers/client_shortlisted_controller.dart';
import '../models/shortlisted_employees.dart';

class ClientShortlistedView extends GetView<ClientShortlistedController> {
  const ClientShortlistedView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.shortList.tr,
        context: context,
      ),
      bottomNavigationBar: _bottomBar(context),
      body: Obx(
        () => controller.shortlistController.isFetching.value
            ? Center(
                child: Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 70.h),
                child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 130),
              ))
            : controller.shortlistController.shortList.isEmpty
                ? const NoItemFound()
                : Column(
                    children: [
                      SizedBox(height: 22.h),
                      ...controller.shortlistController.getUniquePositions().map((String e) {
                        return _employeeInSamePosition(e);
                      }),
                    ],
                  ),
      ),
    );
  }

  Widget _employeeInSamePosition(String positionId) {
    final List<ShortList> employees = controller.shortlistController.getEmployeesBasedOnPosition(positionId);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(15.w, 0, 15.w, 12.h),
          child: Text(
            "${Utils.getPositionName(positionId)} (${employees.length})",
            style: MyColors.l111111_dwhite(controller.context!).semiBold16,
          ),
        ),
        ...employees.map((e) {
          return _employeeItem(e);
        }),
      ],
    );
  }

  Widget _employeeItem(ShortList employee) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.w),
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
          child: Row(
            children: [
              _image((employee.employeeDetails?.profilePicture ?? "").imageUrl),
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
                              SizedBox(height: 5.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _name(employee.employeeDetails?.name ?? "-"),
                                  if (employee.employeeDetails?.certified != null &&
                                      employee.employeeDetails?.certified == true)
                                    Image.asset(MyAssets.certified, height: 30, width: 30),
                                  _rating(employee.employeeDetails?.rating ?? 0.0),
                                  const Spacer(),
                                  Obx(
                                    () => controller.shortlistController.getIcon(
                                        requestedDateList: <RequestDateModel>[],
                                        uniformMandatory: employee.employeeDetails?.hasUniform == true ? null : false,
                                        employeeId: employee.employeeId!,
                                        isFetching: controller.shortlistController.isFetching.value,
                                        fromWhere: ''),
                                  ),
                                  SizedBox(width: 9.w),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Divider(
                      thickness: .5,
                      height: 1,
                      color: MyColors.c_D9D9D9,
                      endIndent: 13.w,
                    ),
                    SizedBox(height: 10.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => controller.onDaysSelectedClick(
                                requestDateList: employee.requestDateList ?? [], shortListId: employee.sId ?? ''),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                              decoration:
                                  BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: MyColors.c_F5F5F5),
                              child: Row(
                                children: [
                                  Image.asset(MyAssets.calender2, height: 20, width: 20),
                                  Text(' ${employee.requestDateList?.calculateTotalDays()} ${MyStrings.daysSelected.tr}',
                                      style: MyColors.black.medium12)
                                ],
                              ),
                            ),
                          ),
                          if (employee.employeeDetails?.hasUniform == true)
                            InkWell(
                              onTap: () => controller.onUniformClick(
                                  positionId: employee.employeeDetails?.positionId ?? '',
                                  shortListId: employee.sId ?? '',
                                  requestDateList: employee.requestDateList ?? []),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                decoration:
                                    BoxDecoration(borderRadius: BorderRadius.circular(5.0), color: MyColors.c_F5F5F5),
                                child: Row(
                                  children: [
                                    Image.asset(MyAssets.uniform, height: 18, width: 18),
                                    Obx(() => Text(
                                        controller.selectedOption.value == 'Yes'
                                            ? ' ${MyStrings.yesNeed.tr}'
                                            : controller.selectedOption.value == 'No'
                                                ? ' ${MyStrings.noNeed.tr}'
                                                : ' ${MyStrings.uniform.tr}',
                                        style: MyColors.black.medium12))
                                  ],
                                ),
                              ),
                            ),
                          if (employee.requestDateList!.isNotEmpty)
                            Obx(
                              () => GestureDetector(
                                onTap: () => controller.onSelectClick(employee),
                                child: Container(
                                  width: 25.h,
                                  height: 25.h,
                                  margin: EdgeInsets.only(right: 10.0.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: controller.shortlistController.selectedForHire.contains(employee)
                                        ? Colors.green.shade400
                                        : MyColors.c_F5F5F5,
                                    border: Border.all(
                                      color: controller.shortlistController.selectedForHire.contains(employee)
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: controller.shortlistController.selectedForHire.contains(employee)
                                        ? Colors.white
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: InkWell(
                                  onTap: () => Get.toNamed(Routes.calender, arguments: [
                                        employee.employeeId ?? '',
                                        employee.sId ?? '',
                                        employee.employeeDetails?.hasUniform == true ? null : false
                                      ]),
                                  child: Image.asset(MyAssets.calender2, height: 25, width: 25)),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
            margin: const EdgeInsets.only(bottom: 20.0),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            height: 30.h,
            width: 280.w,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0.0)
                    .copyWith(bottomLeft: const Radius.circular(10.0), bottomRight: const Radius.circular(10.0)),
                color: MyColors.c_C6A34F),
            child: Center(
                child: Text(
                    (employee.requestDateList??[]).isNotEmpty
                        ? '${MyStrings.totalEstimatedAmount.tr}: ${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${employee.requestDateList?.calculateTotalHourlyRate(hourlyRate: employee.employeeDetails?.hourlyRate ?? 0.0).toStringAsFixed(2)}'
                        : '${MyStrings.hourlyRate.tr}: ${Utils.getCurrencySymbol(Get.find<AppController>().user.value.client?.countryName ?? '')}${employee.employeeDetails?.hourlyRate!.toStringAsFixed(2) ?? '0.00'}',
                    style: MyColors.white.medium13)))
      ],
    );
  }

  Widget _image(String profilePicture) => Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 13, 8),
        width: 74.w,
        height: 74.h,
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
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: MyColors.l111111_dwhite(controller.context!).medium14,
      );

  Widget _rating(double rating) => Visibility(
        visible: rating > 0,
        child: Row(
          children: [
            SizedBox(width: 5.w),
            Container(
              height: 2.h,
              width: 2.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.l111111_dwhite(controller.context!),
              ),
            ),
            SizedBox(width: 5.w),
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

  Widget _bottomBar(BuildContext context) {
    return Obx(() => Visibility(
          visible: controller.shortlistController.shortList.isNotEmpty,
          child: CustomBottomBar(
            child: CustomButtons.button(
              onTap: controller.onBookAllClick,
              text: controller.shortlistController.selectedForHire.isEmpty ||
                      controller.shortlistController.selectedForHire.length ==
                          controller.shortlistController.totalShortlisted.value
                  ? MyStrings.bookAll.tr
                  : "${MyStrings.book.tr} (${controller.shortlistController.selectedForHire.length}) ${MyStrings.employee.tr}",
              customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
            ),
          ),
        ));
  }
}

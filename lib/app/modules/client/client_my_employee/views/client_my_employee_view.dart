import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/client/client_my_employee/models/client_my_employees_model.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/routes/app_pages.dart';
import '../../../../common/utils/exports.dart';
import '../../../../common/widgets/custom_appbar.dart';
import '../../../../common/widgets/custom_network_image.dart';
import '../controllers/client_my_employee_controller.dart';

class ClientMyEmployeeView extends GetView<ClientMyEmployeeController> {
  const ClientMyEmployeeView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: MyStrings.myCandidates.tr,
        context: context,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: MyColors.c_C6A34F.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _selectDateRange(context),
                            child: Row(
                              children: [
                                Obx(
                                  () => Text(
                                    "${controller.startDate.value.dMMMy}  -  ${controller.endDate.value.dMMMy}",
                                    style: MyColors.l111111_dwhite(context)
                                        .medium16,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                          color: MyColors.c_C6A34F.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: GestureDetector(
                        onTap: () => controller.onDateRangePicked(DateTimeRange(
                            start: DateTime.now(), end: DateTime.now())),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              child: Text(
                                MyStrings.todaysCandidates.tr,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    MyColors.l111111_dwhite(context).medium16,
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
            Obx(
              () => controller.isLoading.value
                  ? _loading
                  : controller.employees.isEmpty
                      ? _noEmployeeHireYet
                      : _showEmployeeList,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _noEmployeeHireYet => const Center(child: NoItemFound());

  Widget get _loading => Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
            child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 130)),
      );

  Widget get _showEmployeeList => ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        itemCount: controller.employees.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: false,
        itemBuilder: (context, index) {
          return _employeeItem(
            controller.employees[index],
          );
        },
      );

  Widget _employeeItem(EmployeeModel hiredHistory) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15.w).copyWith(
        bottom: 15.w,
      ),
      decoration: BoxDecoration(
        color: MyColors.lightCard(controller.context!),
        borderRadius: BorderRadius.circular(10.0).copyWith(
          bottomRight: const Radius.circular(11),
        ),
        border: Border.all(
          width: .5,
          color: MyColors.noColor,
        ),
      ),
      child: InkWell(
        onTap: () => controller.onEmployeeClick(Employee(id:hiredHistory.employeeId)),
        child: Stack(
          children: [
            Positioned(
              right: 5.w,
              top: 3.h,
              child: Obx(
                () => controller.shortlistController.getIcon(
                    uniformMandatory:
                        hiredHistory.employeeDetails?.hasUniform == true
                            ? null
                            : false,
                    requestedDateList: <RequestDateModel>[],
                    employeeId: hiredHistory.employeeId ?? '',
                    isFetching: controller.shortlistController.isFetching.value,
                    fromWhere: ''),
              ),
            ),
            Positioned(
              right: 40.w,
              top: 4.h,
              child: _chat(
                unreadMessage: hiredHistory.unreadMessage ?? 0,
                liveChatDataTransferModel: LiveChatDataTransferModel(
                    toName: hiredHistory.employeeDetails?.name ?? '',
                    toId: hiredHistory.employeeId ?? '',
                    senderId: controller.appController.user.value.userId,
                    toProfilePicture:
                        (hiredHistory.employeeDetails?.profilePicture ?? "")
                            .imageUrl,
                    bookedId: hiredHistory.id ?? '', isAdmin: false),
              ),
            ),
            Row(
              children: [
                ((hiredHistory.employeeDetails?.profilePicture ?? "")
                            .isEmpty) ||
                        hiredHistory.employeeDetails?.profilePicture ==
                            "undefined"
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
                    : _image(
                        (hiredHistory.employeeDetails?.profilePicture ?? "")
                            .imageUrl),
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
                                        flex: (hiredHistory.employeeDetails
                                                        ?.rating ??
                                                    0.0) >
                                                0.0
                                            ? 3
                                            : 4,
                                        child: _name(hiredHistory
                                                .employeeDetails?.name ??
                                            "-")),
                                    if (hiredHistory
                                                .employeeDetails?.certified !=
                                            null &&
                                        hiredHistory
                                                .employeeDetails?.certified ==
                                            true)
                                      Image.asset(MyAssets.certified,
                                          height: 30, width: 30),
                                    Expanded(
                                        flex: 2,
                                        child: _rating(hiredHistory
                                                .employeeDetails?.rating ??
                                            0.0)),
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
                          _detailsItem(
                              MyAssets.exp,
                              "",
                              Utils.getPositionName(
                                  hiredHistory.employeeDetails?.positionId ??
                                      "")),
                          InkWell(
                              onTap: () => controller.onCalenderClick(
                                  bookedDateList:
                                      hiredHistory.bookedDate ?? []),
                              child: Image.asset(MyAssets.calender2,
                                  height: 25, width: 25)),
                          SizedBox(width: 8.w)
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _detailsItem(MyAssets.rate, '${MyStrings.rate.tr}:',
                              "${Utils.getCurrencySymbol()}${(hiredHistory.employeeDetails?.hourlyRate ?? 0.0).toStringAsFixed(2)}"),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Obx(() => Visibility(
                          visible: controller.startDate.value ==
                                  DateTime.now().toString().split(" ").first &&
                              (hiredHistory.employeeDetails?.distance ?? "")
                                  .isNotEmpty,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _detailsItem(
                                  MyAssets.distance,
                                  '${MyStrings.distance.tr}:',
                                  double.parse(hiredHistory
                                                  .employeeDetails?.distance ??
                                              "0.0") >
                                          0.124274
                                      ? "${hiredHistory.employeeDetails?.distance ?? ""} ${MyStrings.milesAway.tr}"
                                      : MyStrings.arrived.tr),
                              Visibility(
                                  visible: double.parse(hiredHistory
                                              .employeeDetails?.distance ??
                                          "0.0") >
                                      0.124274,
                                  child: InkWell(
                                      onTap: () => controller.onMapsPressed(
                                          employeeInfo: hiredHistory),
                                      child: Image.asset(MyAssets.maps,
                                          height: 22, width: 22))),
                              SizedBox(width: 8.w)
                            ],
                          ))),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Obx(() => Visibility(
                          //     visible: true,
                          //     child: SizedBox(
                          //       width: 122.w,
                          //       child: CustomButtons.button(
                          //           height: 28.w,
                          //           text: MyStrings.previousDates.tr,
                          //           margin: EdgeInsets.zero,
                          //           fontSize: 12,
                          //           backgroundColor: Colors.teal,
                          //           customButtonStyle: CustomButtonStyle.radiusTopBottomCorner,
                          //           onTap: () =>
                          //               controller.onPrevDatePressed(employeeId: hiredHistory.employeeId ?? '')),
                          //     ))),
                          SizedBox(
                            width: 122.w,
                          ),
                          SizedBox(
                            width: 122.w,
                            child: CustomButtons.button(
                              height: 35.h,
                              text: MyStrings.bookNow.tr,
                              margin: EdgeInsets.zero,
                              fontSize: 15,
                              customButtonStyle:
                                  CustomButtonStyle.radiusTopBottomCorner,
                              onTap: () =>
                                  Get.toNamed(Routes.calender, arguments: [
                                hiredHistory.employeeId ?? '',
                                '',
                                hiredHistory.employeeDetails?.hasUniform == true
                                    ? null
                                    : false
                              ]),
                            ),
                          ),
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
        style: MyColors.l111111_dwhite(controller.context!).medium17,
      );

  Widget _rating(double rating) => Visibility(
        visible: rating > 0.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
              size: 15,
            ),
            SizedBox(width: 2.w),
            Text(
              rating.toString(),
              style: MyColors.l111111_dwhite(controller.context!).medium16,
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
            Text(
              value,
              style: MyColors.l111111_dwhite(controller.context!).medium16,
            ),
          ],
        ),
      );

  Widget _chat(
          {required LiveChatDataTransferModel liveChatDataTransferModel,
          required int unreadMessage}) =>
      GestureDetector(
        onTap: () => controller.chatWithEmployee(
            liveChatDataTransferModel: liveChatDataTransferModel),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.message,
                color: MyColors.c_C6A34F,
              ),
              Visibility(
                  visible: unreadMessage > 0,
                  child: Positioned(
                    top: -10.h,
                    right: -5.w,
                    child: CircleAvatar(
                        backgroundColor: MyColors.white,
                        radius: 10,
                        child: Text(unreadMessage.toString(),
                            style: MyColors.c_C6A34F.semiBold12)),
                  ))
            ],
          ),
        ),
      );

  Future<void> _selectDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      initialDateRange: DateTimeRange(
        start: controller.startDate.value,
        end: controller.endDate.value,
      ),
      builder: (BuildContext context, Widget? child) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: Get.height-140,
                ),child: Theme(
                // Use white colors for light theme and dark colors for dark theme
                data: isDarkMode
                    ? ThemeData.dark().copyWith(
                  // Adjust the dark mode colors as needed
                  primaryColor: Colors.grey[800], // Dark primary color
                  hintColor: Colors.grey[600], // Dark accent color
                  dialogBackgroundColor: Colors.grey[900], // Dark background color
                  // Add other color adjustments if needed

                  textTheme: TextTheme(
                    bodyMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    labelLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    labelMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    labelSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    titleLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    titleMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    titleSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    displayLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    displayMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    displaySmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    headlineLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    headlineMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                    headlineSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.white54),
                  ),
                )
                    : ThemeData.light().copyWith(
                  // Adjust the light mode colors as needed
                  primaryColor: Colors.blue, // Light primary color
                  hintColor: Colors.blueAccent, // Light accent color
                  dialogBackgroundColor: Colors.white, // Light background color
                  // Add other color adjustments if needed
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    labelLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    labelMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    labelSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    titleLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    titleMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    titleSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    displayLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    displayMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    displaySmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    headlineLarge: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    headlineMedium: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                    headlineSmall: TextStyle(fontFamily: MyAssets.fontKlavika,color: Colors.black54),
                  ),
                ),
                child: child!,
              ),
              ),
            ],
          );
      },
    );

    if (picked != null &&
        (picked.start != controller.startDate.value ||
            picked.end != controller.endDate.value)) {
      controller.onDateRangePicked(picked);
    }
  }
}

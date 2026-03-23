import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/controllers/admin_todays_employees_controller.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/models/admin_todays_employee_response_model.dart';
import '../../../../common/style/my_decoration.dart';
import '../../../../common/widgets/custom_network_image.dart';

class AdminTodaysEmployeeBodyWidget extends GetWidget<AdminTodaysEmployeesController> {
  const AdminTodaysEmployeeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                  child: SizedBox(
                height: 40.h,
                child: Obx(
                      () => ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: DropdownButtonFormField<String>( iconSize: 20.w,
                      dropdownColor: MyColors.lightCard(context),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      onChanged: controller.onClientChange,
                      isExpanded: true,
                      itemHeight: Get.width>600? 70.h:58.h,
                      borderRadius: BorderRadius.circular(5.0),
                      isDense: false,
                      hint: Text(
                        controller.clientLoading.value ? MyStrings.loading.tr : MyStrings.selectClient.tr,
                        style: MyColors.l7B7B7B_dtext(context).regular18,
                      ),
                      value: controller.selectedRestaurantName.value,
                      items: controller.restaurants.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: MyColors.l111111_dwhite(context).medium16,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      decoration:  InputDecoration(
                        filled: true,
                        fillColor: MyColors.c_C6A34F.withOpacity(0.5),
                        contentPadding: const EdgeInsets.fromLTRB(10, 0, 5, 15),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        hintMaxLines: 1,
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                  child: Container(
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(color: MyColors.c_C6A34F.withOpacity(0.5), borderRadius: BorderRadius.circular(5.0)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(MyAssets.calendar, height: 20.h, width: 20.w),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _selectDateRange(context),
                      child: Row(
                        children: [
                          Obx(
                                () => Text(
                              "${controller.startDate.value.dMMM}-${controller.endDate.value.dMMM}",
                              style: MyColors.l111111_dwhite(context).medium16,
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                           Icon(Icons.arrow_drop_down,size: 20.sp,),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
          child: Obx(
            () => Visibility(
              visible: controller.todaysEmployeesList.isNotEmpty,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(MyAssets.manager, height: 25, width: 25),
                  Text(
                    " ${controller.todaysEmployeesList.length}",
                    style: MyColors.l111111_dwhite(context).semiBold24,
                  ),
                  Text(' ${MyStrings.candidates.tr}${MyStrings.areShowing.tr}', style: MyColors.l111111_dwhite(context).semiBold15)
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => Visibility(
            visible: controller.todaysEmployeesList.isNotEmpty,
            child: Expanded(
              child: GridView.builder(
                itemCount: controller.todaysEmployeesList.length,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Center(
                    child: Container(
                      width: 182.w,
                      height: 212.w,
                      decoration: MyDecoration.cardBoxDecoration(context: controller.context!),
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10.0),
                          onTap: () {
                            Get.bottomSheet(
                              AdminEmployeeHiredHistoryDetailsWidget(bookedDateList: controller.todaysEmployeesList[index].bookedDate),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 90.w,
                                height: 80.w,
                                child: CustomNetworkImage(url: (controller.todaysEmployeesList[index].employeeDetails?.profilePicture?? '').imageUrl,radius: 130,),
                              ),
                              SizedBox(height: 9.h),
                              Text(
                                controller.todaysEmployeesList[index].employeeDetails?.name ?? "",
                                style: Get.width>600?MyColors.l111111_dwhite(controller.context!).medium16:MyColors.l111111_dwhite(controller.context!).medium18,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                controller.todaysEmployeesList[index].employeeDetails?.positionName ?? "",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Get.width>600?MyColors.l111111_dwhite(controller.context!).medium10:MyColors.l111111_dwhite(controller.context!).medium12,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                controller.selectedRestaurantName.value,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: MyColors.l111111_dwhite(controller.context!).medium12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // child: HorizontalDataTable(
              //   leftHandSideColumnWidth: 150.w,
              //   rightHandSideColumnWidth: 850.w,
              //   isFixedHeader: true,
              //   headerWidgets: _getTitleWidget(),
              //   leftSideItemBuilder: _generateFirstColumnRow,
              //   rightSideItemBuilder: _generateRightHandSideColumnRow,
              //   itemCount: controller.todaysEmployeesList.length,
              //   rowSeparatorWidget: Container(
              //     height: 6.h,
              //     color: MyColors.lFAFAFA_dframeBg(context),
              //   ),
              //   leftHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
              //   rightHandSideColBackgroundColor: MyColors.lffffff_dbox(context),
              // ),
            ),
          ),
        ),
        Obx(
          () => Visibility(
            visible: controller.todaysEmployeesDataLoaded.value == true && controller.todaysEmployeesList.isEmpty,
            child: controller.todaysEmployeesDataLoaded.value == false
                ? const CircularProgressIndicator.adaptive(
                    backgroundColor: MyColors.c_C6A34F,
                  )
                : const NoItemFound(),
          ),
        ),
      ],
    );
  }
  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget(MyStrings.date.tr, 150.w),
      _getTitleItemWidget(MyStrings.candidateName.tr, 150.w),
      _getTitleItemWidget('${MyStrings.business.tr} ${MyStrings.name.tr}', 150.w),
      _getTitleItemWidget(MyStrings.position.tr, 150.w),
      _getTitleItemWidget('${MyStrings.contractor.tr} ${MyStrings.rate.tr}', 100.w),
      _getTitleItemWidget(MyStrings.startTime.tr, 150.w),
      _getTitleItemWidget(MyStrings.endTime.tr, 150.w)
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 62.h,
      color: MyColors.c_C6A34F,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: MyColors.lffffff_dframeBg(controller.context!).semiBold14,
        ),
      ),
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      width: 150.w,
      height: 71.h,
      color: Colors.white,
      child: _cell(
          width: 90.w,
          widget: Text(
            controller.startDate.value.EdMMMy,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
          )),
    );
  }

  Widget _cell({required double width, required Widget widget}) => SizedBox(
        width: width,
        height: 71.h,
        child: Center(
          child: widget,
        ),
      );

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        _cell(
            width: 150.w,
            widget: Text(
              controller.todaysEmployeesList[index].employeeDetails?.name ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.selectedRestaurantName.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              controller.todaysEmployeesList[index].employeeDetails?.positionName ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 100.w,
            widget: Text(
              "${Utils.getCurrencySymbol()}${controller.todaysEmployeesList[index].employeeDetails?.hourlyRate ?? 0.0}",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              '${controller.todaysEmployeesList[index].bookedDate![0].startDate}\n${controller.todaysEmployeesList[index].bookedDate![0].startTime}',
              // controller.getTime(index: index, tag: 'start'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            )),
        _cell(
            width: 150.w,
            widget: Text(
              '${controller.todaysEmployeesList[index].bookedDate![0].endDate}\n${controller.todaysEmployeesList[index].bookedDate![0].endTime}',
              // controller.getTime(index: index, tag: 'end'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: MyColors.l7B7B7B_dtext(controller.context!).semiBold13,
            ))
      ],
    );
  }

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

        return
          Column(
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
        (picked.start != controller.startDate.value || picked.end != controller.endDate.value)) {
      controller.onDateRangePicked(picked);
    }
  }

}

class AdminEmployeeHiredHistoryDetailsWidget extends GetWidget {
  final List<dynamic>? bookedDateList;
  // Preprocess to get unique month-year values

  const AdminEmployeeHiredHistoryDetailsWidget({super.key, required this.bookedDateList});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          height: Get.height * 0.7,
          decoration: BoxDecoration(
            color: MyColors.lightCard(Get.context!),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 20.0.sp, vertical: 10.0.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Total Work Schedule with calculated months
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 15.0.sp, vertical: 2.0.sp),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      color: MyColors.c_C6A34F,
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${MyStrings.previousDates.tr} ',
                            style: Get.width > 600
                                ? MyColors.white.semiBold12
                                : MyColors.white.semiBold15,
                          ),
                          TextSpan(
                            text: '${bookedDateList?.length}',
                            style: Get.width > 600
                                ? MyColors.white.semiBold16
                                : MyColors.white.semiBold24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.sp),

                  if (bookedDateList!=null && bookedDateList!.isEmpty)
                    Text("No dates found for this employee", style: Get.width > 600
                        ? MyColors.white.semiBold11:MyColors.white.semiBold15),
                  if (bookedDateList!.isNotEmpty)
                    GridView.builder(
                      itemCount: bookedDateList!.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Adjust the number of items per row
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio:
                        3 / 1, // Control the height/width ratio
                      ),
                      itemBuilder: (context, index) {
                        // var requestDate = uniqueRequestDates[index];
                        final requestDate = bookedDateList![index];
                        // final monthYear = DateFormat.yMMM().format(
                        //   DateTime.tryParse(requestDate.startDate ?? '') ??
                        //       DateTime.now(),
                        // );
                        String formattedDateRange = formatDateRangeWithTime(
                            requestDate.startDate,
                            requestDate.startTime,
                            requestDate.endDate,
                            requestDate.endTime);

                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.0.sp),
                              decoration: BoxDecoration(
                                color: MyColors.c_C6A34F.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: MyColors.c_C6A34F.withOpacity(0.5),
                                  width: 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  formattedDateRange,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: Get.width*.03),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: InkWell(
                onTap: () => Get.back(),
                child: CircleAvatar(
                  radius: 12.sp,
                  backgroundColor: Colors.red,
                  child: Icon(
                    CupertinoIcons.clear,
                    color: MyColors.white,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
String formatDateRangeWithTime(String? startDateStr, String? startTimeStr, String? endDateStr, String? endTimeStr) {
  // Parse start and end dates (without time)
  DateTime? startDate = DateTime.tryParse(startDateStr ?? '');
  DateTime? endDate = DateTime.tryParse(endDateStr ?? '');

  // If startDate or endDate are invalid (null), just use the date part without time
  if (startDate == null || endDate == null) {
    return 'Invalid Date(s)';
  }

  // Format dates with or without time based on availability of time strings
  String startFormatted = DateFormat('d MMM yyyy').format(startDate);  // Default date format (no time)
  String endFormatted = DateFormat('d MMM yyyy').format(endDate);

  // Add time if time strings are valid and non-empty
  if (startTimeStr != null && startTimeStr.isNotEmpty) {
    try {
      // Combine date and time if both are valid
      startDate = DateTime.parse("$startDateStr $startTimeStr");
      startFormatted = DateFormat('d MMM yyyy HH:mm').format(startDate);  // Add time to start date
    } catch (e) {
      // If parsing fails, just keep the date without time
      if (kDebugMode) {
        print("Error parsing start date and time: $e");
      }
    }
  }

  if (endTimeStr != null && endTimeStr.isNotEmpty) {
    try {
      // Combine date and time if both are valid
      endDate = DateTime.parse("$endDateStr $endTimeStr");
      endFormatted = DateFormat('d MMM yyyy HH:mm').format(endDate);  // Add time to end date
    } catch (e) {
      // If parsing fails, just keep the date without time
      if (kDebugMode) {
        print("Error parsing end date and time: $e");
      }
    }
  }

  // Add day suffix
  int startDay = startDate!.day;
  int endDay = endDate!.day;

  String startWithSuffix = startFormatted.replaceFirst("$startDay", addDaySuffix(startDay));
  String endWithSuffix = endFormatted.replaceFirst("$endDay", addDaySuffix(endDay));

  // Return the formatted range string with or without time
  return "from $startWithSuffix\nto $endWithSuffix";
}
String addDaySuffix(int day) {
  if (day >= 11 && day <= 13) {
    return "${day}th";
  }
  switch (day % 10) {
    case 1:
      return "${day}st";
    case 2:
      return "${day}nd";
    case 3:
      return "${day}rd";
    default:
      return "${day}th";
  }
}
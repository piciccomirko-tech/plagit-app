import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/client/create_job_post/controllers/create_job_post_controller.dart';

class MonthWidget extends StatelessWidget {
  final CreateJobPostController controller;
  final DateTime currentMonth;
  const MonthWidget({super.key, required this.controller, required this.currentMonth});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final int daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final int firstDayWeekday = (DateTime(currentMonth.year, currentMonth.month, 1).weekday + 5) % 7 + 1;
    final int weeks = (daysInMonth + firstDayWeekday - 1) ~/ 7 + 1;

    return GridView.builder(
      itemCount: weeks * 7,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        final int day = index + 1 - firstDayWeekday;
        if (day <= 0 || day > daysInMonth) {
          return Container();
        }
        final DateTime currentDate = DateTime(currentMonth.year, currentMonth.month, day);

        Color textColor = Colors.black;
        Color containerColor = Colors.transparent;
        bool canTapDate = false;

        if (currentDate.toString().substring(0, 10) == today.toString().substring(0, 10)) {
          textColor = MyColors.white;
          containerColor = Colors.blue;
          canTapDate = true;
        } /*else if (controller.selectedDates.contains(currentDate) == true) {
          textColor = MyColors.c_C6A34F;
          canTapDate = false;
        } else if (controller.requestDateList
            .any((RequestDateModel dateRange) => controller.isDateInSelectedRange(currentDate, dateRange))) {
          containerColor = MyColors.c_DDBD68.withOpacity(0.8);
          canTapDate = false;
        } */else if (currentDate.isBefore(DateTime.now()) || controller.initialDate.value == currentDate) {
          textColor = Colors.grey;
          canTapDate = false;
        } else {
          textColor = Colors.green; // Available days should be green
          canTapDate = true;
        }
        return InkResponse(
          onTap: canTapDate == true ? () => controller.onDateClick(currentDate: currentDate) : null,
          child: Obx(() {
            final bool isSelected = controller.selectedDates.contains(currentDate);
            final bool isDateInRange = controller.requestDateList
                .any((RequestDateModel dateRange) => controller.isDateInSelectedRange(currentDate, dateRange));

            if (isSelected == true) {
              containerColor = MyColors.c_C6A34F;
              textColor = MyColors.white; // Change container color for selected dates
            } else if (isDateInRange == true) {
              containerColor = MyColors.c_DDBD68.withOpacity(0.8);
              textColor = MyColors.white;
            } else if (isSelected == false && canTapDate == true) {
              containerColor = Colors.transparent;
              textColor = Colors.green;
            }
            return Container(
              margin: const EdgeInsets.all(5.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected == true ? MyColors.c_C6A34F : containerColor,
              ),
              child: Text(
                day.toString(),
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15), // Text color based on textColor variable
              ),
            );
          }),
        );
        /*GestureDetector(
          onTap: canTapDate
              ? () => controller.onDateClick(currentDate: currentDate)
              : canUpdateUnavailableDate
                  ? () => controller.onEmployeeUnavailableDateUpdate(currentDate: currentDate)
                  : null,
          child: Obx(() {
            final bool isSelected = controller.selectedDates.contains(currentDate);
            final bool isDateInRange = Get.isRegistered<EmployeeHomeController>()
                ? controller.isDateInSelectedRangeForEmployee(currentDate)
                : controller.requestDateList.any((RequestDateModel dateRange) =>
                    controller.isDateInSelectedRangeForShortList(currentDate, dateRange));

            if (isSelected == true) {
              containerColor = MyColors.c_C6A34F;
              textColor = MyColors.white; // Change container color for selected dates
            } else if (isDateInRange == true) {
              containerColor = MyColors.c_DDBD68.withOpacity(0.8);
              textColor = MyColors.white;
            } else if (isSelected == false && canTapDate == true) {
              containerColor = Colors.transparent;
              textColor = Colors.green;
            }
            return Container(
              margin: const EdgeInsets.all(5.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor),
                color: isSelected ? MyColors.c_C6A34F : containerColor,
              ),
              child: Text(
                day.toString(),
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15), // Text color based on textColor variable
              ),
            );
          }),
        );*/
      },
    );
  }
}

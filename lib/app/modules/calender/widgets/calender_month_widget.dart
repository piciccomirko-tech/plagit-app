import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/calender/controllers/calender_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_shortlisted/models/add_to_shortlist_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class CalenderMonthWidget extends StatelessWidget {
  final DateTime month;
  final CalenderController controller;
  const CalenderMonthWidget({super.key, required this.month, required this.controller});

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int firstDayWeekday = (DateTime(month.year, month.month, 1).weekday + 5) % 7 + 1;
    final int weeks = (daysInMonth + firstDayWeekday - 1) ~/ 7 + 1;

    return GridView.builder(
      itemCount: weeks * 7,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemBuilder: (context, index) {
        final int day = index + 1 - firstDayWeekday;
        if (day <= 0 || day > daysInMonth) {
          return Container();
        }
        final DateTime currentDate = DateTime(month.year, month.month, day);

        Color borderColor = Colors.transparent;
        Color textColor = Colors.black;
        Color containerColor = Colors.transparent;

        bool canTapDate = false;
        bool canUpdateUnavailableDate = false;

        if (Get.isRegistered<ClientHomeController>() == true &&
            currentDate.toString().substring(0, 10) == today.toString().substring(0, 10)) {
          borderColor = MyColors.c_C6A34F; // Today's date should be red
          textColor = Colors.green;
          canTapDate = true;
        } else if (currentDate.toString().substring(0, 10) == today.toString().substring(0, 10)) {
          borderColor = MyColors.c_C6A34F; // Today's date should be red
          textColor = Colors.grey;
        } else if (controller.dateListModel.value.bookedDates!.containsDate(currentDate)) {
          textColor = Colors.red;
        } else if (controller.dateListModel.value.pendingDates!.containsDate(currentDate)) {
          textColor = Colors.amber;
        } else if (controller.dateListModel.value.unavailableDates!.containsDate(currentDate)) {
          textColor = Colors.blue;
          if (Get.isRegistered<EmployeeHomeController>()) {
            canUpdateUnavailableDate = true;
          }
        } else if (currentDate.isBefore(DateTime.now()) || controller.selectedDate.value == currentDate) {
          textColor = Colors.grey;
        } else {
          textColor = Colors.green; // Available days should be green
          canTapDate = true;
        }

        return GestureDetector(
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
        );
      },
    );
  }
}

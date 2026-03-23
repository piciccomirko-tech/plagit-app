import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/values/my_color.dart';

import '../../../../common/values/my_assets.dart';
import '../../../../common/widgets/custom_dropdown.dart';
import '../controllers/create_job_post_controller.dart';

class MultiMonthDropdownPicker extends StatelessWidget {
  MultiMonthDropdownPicker({
    Key? key,
  }) : super(key: key);
  final CreateJobPostController controller =
      Get.find<CreateJobPostController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown to select months
        // Obx(() {
        //   return DropdownButton<DateTime>(
        //     hint: Text("Choose Months"),
        //     value: null, // The dropdown doesn't display a selected value since we allow multiple
        //     items: controller.availableMonths.map((month) {
        //       return DropdownMenuItem<DateTime>(
        //         value: month,
        //         child: Text(DateFormat.yMMM().format(month)),
        //       );
        //     }).toList(),
        //     onChanged: (DateTime? selectedMonth) {
        //       if (selectedMonth != null) {
        //         controller.toggleMonthSelection(selectedMonth);
        //       }
        //     },
        //     isExpanded: true,
        //   );
        // }),
        // const SizedBox(height: 20),
        CustomDropdown(
          prefixIcon: Icons.calendar_today, // Icon for the dropdown
          hints: 'Choose Months', // Hint for the dropdown
          value: '', // Initially no value selected
          items: controller.availableMonths.map((month) {
            // Map available months to string format
            return DateFormat.yMMM().format(
                month); // Format the DateTime to a readable month format
          }).toList(), // Convert to list
          onChange: (selectedMonth) {
            // Handle changes
            DateTime? month = controller.availableMonths.firstWhere(
                (element) =>
                    DateFormat.yMMM().format(element) == selectedMonth,
                orElse: () => DateTime
                    .now()); // Find the matching DateTime object from the list
            controller
                .toggleMonthSelection(month); // Toggle the selected month
          },
        ),
        // Wrap the dynamic content in a ConstrainedBox or SingleChildScrollView
        Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.sp),
          child: SizedBox(
            // height: 200,
            child: Center(
              child: SingleChildScrollView(
                child: Obx(() {
                  if (controller.selectedMonths.isNotEmpty) {
                    return Wrap(
                      spacing: 8.0,
                      children: controller.selectedMonths.map((month) {
                        return Chip(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: BorderSide(color: MyColors.c_C6A34F.withOpacity(0.5))
                          ),
                          backgroundColor: MyColors.c_C6A34F.withOpacity(0.5),
                          label: Text(DateFormat.yMMM().format(month), style: TextStyle(fontSize: 11.sp,fontFamily: MyAssets.fontKlavika),),
                          deleteIconColor: Colors.red,
                          onDeleted: () {
                            controller.toggleMonthSelection(month);
                          },
                        );
                      }).toList(),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text("No months selected yet",style: TextStyle(fontFamily: MyAssets.fontKlavika),),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

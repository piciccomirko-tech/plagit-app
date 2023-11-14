import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_home_card_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_location_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_name_widget.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_today_work_schedule_widget.dart';
import 'employee_todays_dashboard_widget.dart';

class EmployeeHomeBodyWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeHomeBodyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      primary: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: const Column(
         mainAxisAlignment: MainAxisAlignment.center,
         crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmployeeNameWidget(),
            EmployeeTodayWorkScheduleWidget(),
            EmployeeTodayDashboardWidget(),
            EmployeeHomeCardWidget(),
            EmployeeLocationWidget(),
          ],
        ),
      ),
    );

  }
}

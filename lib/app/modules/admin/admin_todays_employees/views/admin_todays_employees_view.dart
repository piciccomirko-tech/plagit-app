import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/admin/admin_todays_employees/widgets/admin_todays_employee_body_widget.dart';
import '../controllers/admin_todays_employees_controller.dart';

class AdminTodaysEmployeesView extends GetView<AdminTodaysEmployeesController> {
  const AdminTodaysEmployeesView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: CustomAppbar.appbar(
        context: context,
        title: MyStrings.todaysCandidates.tr
      ),
      body: Obx(() {
        if (controller.todaysEmployeesDataLoaded.value == false) {
          return Center(child: CustomLoader.loading());
        } else {
          return const AdminTodaysEmployeeBodyWidget();
        }
      }),
    );
  }
}

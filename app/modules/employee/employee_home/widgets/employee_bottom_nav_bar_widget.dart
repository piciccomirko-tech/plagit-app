import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/widgets/custom_bottombar.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_home/widgets/employee_check_in_checkout_widget.dart';

class EmployeeBottomNavBarWidget extends GetView<EmployeeHomeController> {
  const EmployeeBottomNavBarWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: controller.showCheckInCheckOutWidget == true,
        child: const CustomBottomBar(
          child: EmployeeCheckInCheckoutWidget(),
        )));
  }
}

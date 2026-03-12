import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

class EmployeeLocationWidget extends GetWidget<EmployeeHomeController> {
  const EmployeeLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _locationFetchError;
  }

  Widget get _locationFetchError => Obx(() => controller.locationFetchError.value.isNotEmpty
      ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, color: Colors.amber),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              controller.locationFetchError.value,
              style: MyColors.l111111_dwhite(controller.context!).semiBold15,
            ),
          ),
        ],
      )
      : const Wrap());
}

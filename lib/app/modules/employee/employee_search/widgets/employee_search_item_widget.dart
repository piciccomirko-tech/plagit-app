import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/dropdown_item.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/modules/employee/employee_search/controllers/employee_search_controller.dart';

class EmployeeSearchItemWidget extends GetWidget<EmployeeSearchController> {
  const EmployeeSearchItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Visibility(
        visible: Get.find<EmployeeHomeController>().featureList.isNotEmpty,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  topLeft: Radius.circular(15.0)
              ),
              color: MyColors.lightCard(context)),
          child: ListView.builder(
              itemCount: Get.find<EmployeeHomeController>().featureList.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                DropdownItem position =
                Get.find<EmployeeHomeController>().featureList[index];
                return ListTile(
                  onTap: () => Get.find<EmployeeHomeController>()
                      .onSearchItemTap(position: int.parse('${position.id}')),
                  leading: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: Image.asset('${position.logo}'),
                  ),
                  title: Text(position.name ?? '',
                      style: MyColors.l111111_dwhite(context).semiBold16),
                  trailing: const Icon(CupertinoIcons.arrow_up_left,
                      color: MyColors.c_C6A34F),
                );
              }),
        ))
    );
  }
}

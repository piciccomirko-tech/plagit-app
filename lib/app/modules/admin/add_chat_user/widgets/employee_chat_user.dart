import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/admin/add_chat_user/controllers/add_chat_user_controller.dart';

import '../../../../common/values/my_assets.dart';

class EmployeeChatUser extends GetWidget<AddChatUserController> {
  const EmployeeChatUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.employeesDataLoaded.value == false) {
        return Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Center(child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 90)),
        );
      } else if (controller.employeesDataLoaded.value == true && (controller.employees.value.users ?? []).isEmpty) {
        return const Center(child: NoItemFound());
      } else {
        return ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: (controller.employees.value.users ?? []).length,
            itemBuilder: (BuildContext context, int index) {
              Employee emp = (controller.employees.value.users ?? [])[index];
              return ListTile(
                onTap: () => controller.onUserTapped(employee: emp),
                leading: emp.profilePicture!=null && emp.profilePicture!.isNotEmpty?
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: NetworkImage((emp.profilePicture??"").imageUrl),
                ):CircleAvatar(
                  backgroundColor: MyColors.primaryLight,
                  radius: 26,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.transparent,
                    backgroundImage:  AssetImage(MyAssets.employeeDefault),)) ,
                title: Text("${emp.firstName ?? ""} ${emp.lastName}", style: MyColors.l111111_dwhite(context).medium16),
                subtitle: Text(emp.email ?? "", style: MyColors.l111111_dwhite(context).regular13),
              );
            });
      }
    });
  }
}

import 'package:flutter/cupertino.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

import '../../enums/user_type.dart';
import '../../modules/client/client_home/controllers/client_home_controller.dart';
import '../controller/app_controller.dart';
import '../utils/exports.dart';

class CustomMenu {
  static accountMenu(
    BuildContext context, {
    Function()? onProfileTap,
    Function()? onSettingsTap,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: MyColors.lightCard(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(
              context,
              [
                UserType.client,
                UserType.employee,
              ],
              CupertinoIcons.person,
              MyStrings.profile.tr,
              onProfileTap ?? () {},
            ),
            const Divider(height: 1),
            if (Get.isRegistered<ClientHomeController>() == true)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuItem(
                    context,
                    [
                      UserType.client,
                      UserType.employee,
                    ],
                    CupertinoIcons.settings,
                    MyStrings.settings.tr,
                    onSettingsTap ?? () {},
                  ),
                  const Divider(height: 1),
                ],
              ),
            _menuItem(
              context,
              [UserType.client, UserType.employee, UserType.admin],
              Icons.logout,
              MyStrings.logOut.tr,
              Get.find<AppController>().onLogoutClick,
            ),
            const Divider(height: 1),
            _menuItem(
              context,
              [UserType.client, UserType.employee],
              Icons.remove_circle_outlined,
              MyStrings.deleteAccount.tr,
              Get.isRegistered<ClientHomeController>() ? Get.find<ClientHomeController>().onAccountDeleteClick :
    Get.isRegistered<ClientHomeController>()? Get.find<EmployeeHomeController>().onAccountDeleteClick:(){},
              deleteIcon: true,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _menuItem(
    BuildContext context,
    List<UserType> permissions,
    IconData icon,
    String title,
    Function() onTap, {
    bool deleteIcon = false,
  }) {
    return Visibility(
      visible: permissions.contains(Get.find<AppController>().user.value.userType),
      child: ListTile(
        leading: Icon(icon, color: deleteIcon ? Colors.red : Colors.grey),
        title: Text(
          title,
          style: deleteIcon
              ? MyColors.l111111_dtext(context).semiBold16.copyWith(color: Colors.red)
              : MyColors.l111111_dtext(context).regular16_5,
        ),
        onTap: onTap,
      ),
    );
  }
}

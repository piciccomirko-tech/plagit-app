import 'package:flutter/cupertino.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

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
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: MyColors.lightCard(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(
              context,
              [UserType.client, UserType.employee,],
              CupertinoIcons.person,
              "Profile",
              onProfileTap ?? () {},
            ),
            const Divider(height: 1),
            if(Get.isRegistered<ClientHomeController>() == true)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _menuItem(
                    context,
                    [UserType.client, UserType.employee,],
                    CupertinoIcons.settings,
                    "Settings",
                    onSettingsTap ?? () {},
                  ),
                  const Divider(height: 1),
                ],
              ),
            _menuItem(
              context,
              [UserType.client, UserType.employee, UserType.admin],
              Icons.logout,
              "Logout",
              Get.find<AppController>().onLogoutClick,
            ),
            const Divider(height: 1),
            _menuItem(
              context,
              [UserType.client, UserType.employee],
              Icons.remove_circle_outlined,
              "Delete Account",
              Get.isRegistered<ClientHomeController>() ? Get.find<ClientHomeController>().onAccountDeleteClick : () {},
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
              ? MyColors.l111111_dtext(context).semiBold15.copyWith(color: Colors.red)
              : MyColors.l111111_dtext(context).regular16_5,
        ),
        onTap: onTap,
      ),
    );
  }
}
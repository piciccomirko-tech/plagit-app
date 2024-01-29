import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';

import '../utils/exports.dart';
import 'custom_badge.dart';

class ChatWithUserChoose {
  static show(BuildContext context, {int msgFromAdmin = 0, int msgFromClient = 0}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: MyColors.lightCard(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _menuItem(context, MyStrings.chatWithAdmin.tr, Icons.chat, Get.find<EmployeeHomeController>().chatWithAdmin,
                trailing: msgFromAdmin == 0 ? null : CustomBadge(msgFromAdmin.toString())),
            const Divider(height: 1),
            _menuItem(
                context, MyStrings.chatWithRestaurant.tr, Icons.chat, Get.find<EmployeeHomeController>().chatWithClient,
                trailing: msgFromClient == 0 ? null : CustomBadge(msgFromClient.toString())),
          ],
        ),
      ),
    );
  }

  static Widget _menuItem(
    BuildContext context,
    String title,
    IconData icon,
    Function() onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: MyColors.l111111_dtext(context).regular16_5,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

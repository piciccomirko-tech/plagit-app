import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../modules/client/client_home/controllers/client_home_controller.dart';
import '../utils/exports.dart';

class ClientHelpOption {
  static show(BuildContext context, {
    int msgFromAdmin = 0
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
              "Chat with Admin / support",
              Icons.chat,
              Get.find<ClientHomeController>().chatWithAdmin,
              trailing: msgFromAdmin == 0 ? null : CustomBadge(msgFromAdmin.toString())
            ),
            const Divider(height: 1),
            _menuItem(
              context,
              "Request for Employees",
              Icons.chat,
              Get.find<ClientHomeController>().requestEmployees,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _menuItem(
    BuildContext context,
    String title,
    IconData icon,
    Function() onTap,{
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

import '../utils/exports.dart';

class ChatWithUserChoose {
  static show(BuildContext context, {int msgFromAdmin = 0, int msgFromClient = 0}) {
    showModalBottomSheet(
     constraints: BoxConstraints(
      maxWidth:  Get.width,              
    ),
      context: context,
      builder: (context) => Container(
        color: MyColors.lightCard(context),
        padding: EdgeInsets.symmetric( horizontal: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           /* _menuItem(context, MyStrings.chatWithAdmin.tr, Icons.chat, Get.find<EmployeeHomeController>().chatWithAdmin,
                trailing: msgFromAdmin == 0 ? null : CustomBadge(msgFromAdmin.toString())),
            const Divider(height: 1),
            _menuItem(
                context, MyStrings.chatWithRestaurant.tr, Icons.chat, Get.find<EmployeeHomeController>().chatWithClient,
                trailing: msgFromClient == 0 ? null : CustomBadge(msgFromClient.toString())),*/
          ],
        ),
      ),
    );
  }

}

import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';

import '../../../../helpers/responsive_helper.dart';

class ChatCategoryWidget extends GetWidget<ChatItController> {
  const ChatCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(()=>Row(
        children: List.generate(controller.chatCategoryList.length, (int index){
          ChatCategoryModel chatCategory = controller.chatCategoryList[index];
          return GestureDetector(
            onTap: ()=>controller.onChatCategoryChange(index: index),
            child: Container(
              margin: const EdgeInsets.only(right: 15.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: chatCategory.tapped== true?MyColors.primaryLight:MyColors.lightGrey.withOpacity(0.3)
              ),
              child: Text(chatCategory.title.tr, style: chatCategory.tapped== true && ResponsiveHelper.isTab(context)
                  ?MyColors.white.regular10:
              ResponsiveHelper.isTab(context)?MyColors.l111111_dwhite(context).regular10:MyColors.l111111_dwhite(context).regular15
              ),
            ),
          );
        })
    ));
  }
}

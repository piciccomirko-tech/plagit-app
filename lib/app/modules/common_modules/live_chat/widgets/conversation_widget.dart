import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/live_chat/controllers/live_chat_controller.dart';
import 'package:mh/app/modules/common_modules/live_chat/widgets/message_widget.dart';

class ConversationWidget extends GetWidget<LiveChatController> {
  const ConversationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messageLoaded.value == false) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (controller.messageLoaded.value == true &&
          controller.messageList.isEmpty) {
        return Center(
            child: Text(MyStrings.noConversationFound.tr,
                style: MyColors.l111111_dwhite(context).medium13));
      } else {
        return GestureDetector(
          onTap: () => Utils.unFocus(),
          child: Padding(
            padding:
                EdgeInsets.only(left: 15.0.sp, right: 15.0.sp, top: 15.0.sp),
            child: ListView.builder(
                reverse: true,
                controller: controller.scrollController,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: controller.messageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                      onLongPress: () {
                        controller.setTextForCopy(controller.messageList[index].text ?? '');
                      },
                      onTap: () {
                        controller.textNeedToBeCopied('');
                      },
                      child: MessageWidget(messageModel: controller.messageList[index], index: index));
                }),
          ),
        );
      }
    });
  }
}

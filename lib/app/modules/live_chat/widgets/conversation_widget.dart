import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/modules/live_chat/controllers/live_chat_controller.dart';
import 'package:mh/app/modules/live_chat/widgets/message_widget.dart';

class ConversationWidget extends GetWidget<LiveChatController> {
  const ConversationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.messageLoaded.value == false) {
        return const Center(child: CupertinoActivityIndicator());
      } else if (controller.messageLoaded.value == true && controller.messageList.isEmpty) {
        return const Center(child: Text("No conversation found"));
      } else {
        return InkWell(
          onTap: () => Utils.unFocus(),
          child: Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
            child: ListView.builder(
                reverse: true,
                controller: controller.scrollController,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: controller.messageList.length,
                itemBuilder: (BuildContext context, int index) {
                  return MessageWidget(messageModel: controller.messageList[index], index: index);
                }),
          ),
        );
      }
    });
  }
}

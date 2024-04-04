import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/modules/chat_it/widgets/chat_user_search_widget.dart';
import 'package:mh/app/modules/chat_it/widgets/chat_user_widget.dart';
import 'package:mh/app/modules/live_chat/widgets/conversation_widget.dart';

import '../controllers/chat_it_controller.dart';

class ChatItView extends GetView<ChatItController> {
  const ChatItView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;

    return Scaffold(
      appBar: CustomAppbar.appbar(
        title: "Chat It",
        context: context,
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: MyColors.c_C6A34F,
        onPressed: controller.onAddChatUserPressed,
        child: const Icon(Icons.add, color: MyColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chats", style: MyColors.l111111_dwhite(context).semiBold26),
            SizedBox(height: 15.h),
            const ChatUserSearchWidget(),
            SizedBox(height: 15.h),
            Obx(() {
              if (controller.conversationDataLoaded.value == false) {
                return Center(child: CustomLoader.loading());
              } else if (controller.conversationDataLoaded.value == true && controller.conversationList.isEmpty) {
                return const Center(child: Text("No conversation found"));
              } else {
                return ListView.builder(
                    itemCount: controller.conversationList.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (BuildContext context, int index) =>
                        ChatUserWidget(conversation: controller.conversationList[index]));
              }
            }),
          ],
        ),
      ),
    );
  }
}

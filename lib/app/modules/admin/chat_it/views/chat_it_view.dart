import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/admin/chat_it/widgets/chat_category_widget.dart';
import 'package:mh/app/modules/admin/chat_it/widgets/chat_user_search_widget.dart';
import 'package:mh/app/modules/admin/chat_it/widgets/chat_user_widget.dart';
import '../controllers/chat_it_controller.dart';

class ChatItView extends GetView<ChatItController> {
  const ChatItView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Obx(()=> Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:CustomAppbar.appbar(
        title: "${MyStrings.messages.tr} (${controller.conversationDataLoaded.value == true &&
            controller.conversationList.isNotEmpty?controller.unreadMessages.value:0})",
        context: context,
      ) ,
      floatingActionButton: controller.floatingWidget,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            children: [
              SizedBox(height: 15.h),
              const ChatUserSearchWidget(),
              SizedBox(height: 15.h),
              const ChatCategoryWidget(),
              SizedBox(height: 15.h),
              controller.conversationDataLoaded.value == false?
              Center(child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 90)):
              controller.conversationDataLoaded.value == true &&
                  controller.conversationList.isEmpty?
              const Center(child: NoItemFound()):
              ListView.builder(
                  itemCount: controller.conversationList.length,
                  shrinkWrap: true,
                  primary: false,
                  reverse: false,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == controller.conversationList.length - 1 &&
                        controller.isMoreDataAvailable.value == true) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    return ChatUserWidget(
                        conversation:
                        controller.conversationList[index]);}),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    ),);
  }
}

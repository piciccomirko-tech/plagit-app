import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/common/widgets/no_item_found.dart';
import 'package:mh/app/common/widgets/shimmer_widget.dart';
import 'package:mh/app/modules/chat_it/widgets/chat_user_search_widget.dart';
import 'package:mh/app/modules/chat_it/widgets/chat_user_widget.dart';
import '../controllers/chat_it_controller.dart';

class ChatItView extends GetView<ChatItController> {
  const ChatItView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
   Utils.unFocus();
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              Text("Chats", style: MyColors.l111111_dwhite(context).semiBold26),
              SizedBox(height: 15.h),
              const ChatUserSearchWidget(),
              SizedBox(height: 15.h),
              Obx(() {
                if (controller.conversationDataLoaded.value == false) {
                  return Center(child: ShimmerWidget.clientMyEmployeesShimmerWidget(height: 90));
                } else if (controller.conversationDataLoaded.value == true && controller.filteredConversationList.isEmpty) {
                  return const Center(child: NoItemFound());
                } else {
                  return ListView.builder(
                      itemCount: controller.filteredConversationList.length,
                      shrinkWrap: true,
                      primary: false,
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) =>
                          ChatUserWidget(conversation: controller.filteredConversationList[index]));
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

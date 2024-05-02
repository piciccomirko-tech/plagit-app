import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar_back_button.dart';
import 'package:mh/app/modules/live_chat/widgets/conversation_widget.dart';
import 'package:mh/app/modules/live_chat/widgets/message_type_widget.dart';
import '../controllers/live_chat_controller.dart';

class LiveChatView extends GetView<LiveChatController> {
  const LiveChatView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return PopScope(
      onPopInvoked: controller.onBackPressed,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0XFF000000).withOpacity(.08),
                  offset: const Offset(0, 3),
                  blurRadius: 10.0,
                )
              ],
            ),
            child: AppBar(
              backgroundColor: MyColors.lightCard(context),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(10.0),
                ),
              ),
              leading: const Align(child: CustomAppbarBackButton()),
              centerTitle: true,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: MyColors.c_C6A34F,
                    radius: 19,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(controller.liveChatDataTransferModel.toProfilePicture),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(controller.liveChatDataTransferModel.toName,
                            style: MyColors.l111111_dwhite(context).semiBold16, overflow: TextOverflow.ellipsis, maxLines: 2),
                        SizedBox(height: 3.h),
                        Text("Online", style: MyColors.c_A6A6A6.medium10)
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Flexible(child: ConversationWidget()), MessageTypeWidget()],
        ),
      ),
    );
  }
}

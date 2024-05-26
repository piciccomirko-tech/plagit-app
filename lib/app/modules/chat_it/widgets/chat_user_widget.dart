import 'package:intl/intl.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_badge.dart';
import 'package:mh/app/modules/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/chat_it/models/chat_it_model.dart';

class ChatUserWidget extends StatelessWidget {
  final Conversation conversation;
  const ChatUserWidget({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onLongPress: () => Get.find<ChatItController>().onLongTapped(conversationId: conversation.id ?? ""),
      onTap: () => Get.find<ChatItController>().onUserTapped(member: (conversation.members ?? []).first),
      child: Stack(
        children: [
          Container(
            decoration: MyDecoration.cardBoxDecoration(context: context),
            margin:  EdgeInsets.only(bottom: 10.sp),
            child: ListTile(
              contentPadding:  EdgeInsets.symmetric(horizontal: 10.sp),
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(((conversation.members ?? []).first.profilePicture ?? "").imageUrl),
              ),
              title: Text((conversation.members ?? []).first.name ?? "Guest",
                  style: Get.width>600?MyColors.l111111_dwhite(context).semiBold12:MyColors.l111111_dwhite(context).semiBold15),
              subtitle: Text(conversation.latestMessage?.text ?? "No message",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (conversation.latestMessage?.read ?? false) == true
                      ? MyColors.l111111_dwhite(context).regular13
                      : MyColors.l111111_dwhite(context).semiBold13),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((conversation.members ?? []).first.role ?? "", style: Get.width>600?MyColors.l111111_dwhite(context).medium9:MyColors.l111111_dwhite(context).medium12),
                  Text(
                      DateFormat('dd MMM yyyy, hh:mm a').format(conversation.latestMessage?.dateTime ?? DateTime.now()),
                      style:TextStyle(fontSize: Get.width>600?13:9, color: MyColors.c_C6A34F, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 2,
            child: Visibility(
              visible: (conversation.unreadMsg ?? 0) > 0,
              child: CustomBadge(conversation.unreadMsg.toString()),
            ),
          )
        ],
      ),
    );
  }
}

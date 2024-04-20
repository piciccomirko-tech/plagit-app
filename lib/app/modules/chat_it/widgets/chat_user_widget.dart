import 'package:intl/intl.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/chat_it/models/chat_it_model.dart';

class ChatUserWidget extends StatelessWidget {
  final Conversation conversation;
  const ChatUserWidget({super.key, required this.conversation});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => Get.find<ChatItController>().onUserTapped(member: (conversation.members ?? []).first),
      child: Container(
        decoration: MyDecoration.cardBoxDecoration(context: context),
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(((conversation.members ?? []).first.profilePicture ?? "").imageUrl),
          ),
          title: Text((conversation.members ?? []).first.name ??"Guest",
              style: MyColors.l111111_dwhite(context).semiBold15),
          subtitle: Text(conversation.latestMessage?.text ?? "No message",
              style: (conversation.latestMessage?.read ?? false) == false
                  ? MyColors.l111111_dwhite(context).regular13
                  : MyColors.l111111_dwhite(context).semiBold13),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text((conversation.members ?? []).first.role ?? "", style: MyColors.l111111_dwhite(context).medium12),
              Text(DateFormat('dd MMM yyyy, hh:mm a').format(conversation.latestMessage?.dateTime ?? DateTime.now()), style: MyColors.c_C6A34F.medium10),
            ],
          ),
        ),
      ),
    );
  }
}

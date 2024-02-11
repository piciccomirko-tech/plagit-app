import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/live_chat/controllers/live_chat_controller.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  final int index;
  const MessageWidget({super.key, required this.messageModel, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: messageModel.senderDetails?.senderId == Get.find<AppController>().user.value.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
            margin:
                EdgeInsets.only(bottom: Get.find<LiveChatController>().messageList.length - 1 == index ? 10.0 : 2.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: messageModel.senderDetails?.senderId == Get.find<AppController>().user.value.userId
                    ? MyColors.c_C6A34F
                    : Colors.blueGrey.shade300),
            child: Row(
              children: [
                Text('${messageModel.text}', style: MyColors.white.medium15),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Text(DateFormat.jm().format(messageModel.dateTime ?? DateTime.now()),
                            style: Colors.grey.shade100.medium10),
                        Visibility(
                            visible:
                                messageModel.senderDetails?.senderId == Get.find<AppController>().user.value.userId,
                            child: const Icon(Icons.check, color: Colors.white, size: 12))
                      ],
                    )
                  ],
                )
              ],
            )),
        const Wrap()
      ],
    );
  }
}

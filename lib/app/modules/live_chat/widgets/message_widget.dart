import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  const MessageWidget({super.key, required this.messageModel});

  @override
  Widget build(BuildContext context) {
    print('MessageWidget.build: ${messageModel.dateTime}');
    return Row(
      mainAxisAlignment: messageModel.senderDetails?.senderId == Get.find<AppController>().user.value.userId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: messageModel.senderDetails?.senderId == Get.find<AppController>().user.value.userId
                    ? MyColors.c_C6A34F
                    : Colors.grey.shade400),
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
                        Text(DateFormat.jm().format(messageModel.dateTime??DateTime.now()), style: Colors.grey.shade100.medium10),
                        const Icon(Icons.check, color: Colors.white, size:12)],
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

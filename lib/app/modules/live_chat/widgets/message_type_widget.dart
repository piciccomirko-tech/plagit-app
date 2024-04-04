import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/live_chat/controllers/live_chat_controller.dart';

class MessageTypeWidget extends GetWidget<LiveChatController> {
  const MessageTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(10.0),
          ),
          color: MyColors.lightCard(context),
          boxShadow: [
            BoxShadow(
              color: const Color(0XFF000000).withOpacity(.08),
              offset: Offset(0, 3.h),
              blurRadius: 10.0,
            )
          ]),
      child: Row(
        children: [
          Expanded(
              flex: 7,
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: TextFormField(
                    maxLines: null,
                    style: MyColors.l111111_dwhite(context).medium16,
                    controller: controller.tecMessage,
                    decoration: InputDecoration(
                        hintText: "Type here...",
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        fillColor: MyColors.c_C6A34F.withOpacity(0.1),
                        filled: true),
                  ),
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: InkResponse(
              onTap: controller.sendMessage,
              child: const CircleAvatar(
                backgroundColor: MyColors.c_C6A34F,
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}

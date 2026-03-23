import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/message_response_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'copy_able_text_widget.dart';

class MessageWidget extends StatelessWidget {
  final MessageModel messageModel;
  final int index;
  const MessageWidget(
      {super.key, required this.messageModel, required this.index});

  @override
  Widget build(BuildContext context) {
    final AppController appController = Get.find<AppController>();
    bool isCurrentUser=true;
    if(appController.user.value.isAdmin){
      isCurrentUser = messageModel.senderDetails?.role == "ADMIN" || messageModel.senderDetails?.role == "SUPER_ADMIN";
    }else{
      isCurrentUser= messageModel.senderId == appController.user.value.userId || (( messageModel.sendByPlagItSupport==true) && appController.user.value.isAdmin);
    }
    final TextStyle textStyle = Get.width > 600 ? MyColors.white.medium12 : MyColors.white.medium15;
    final TextStyle timestampStyle = Get.width > 600 ? MyColors.white.medium9 : MyColors.white.medium10;
    final MainAxisAlignment messageAlignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final CrossAxisAlignment textAlignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final BorderRadius borderRadius = isCurrentUser
        ? const BorderRadius.only(
      topLeft: Radius.circular(10),
        topRight: Radius.circular(10), bottomLeft: Radius.circular(10))
        : const BorderRadius.only(
      topRight: Radius.circular(10),
        topLeft: Radius.circular(10), bottomRight: Radius.circular(10));
    final Color backgroundColor = isCurrentUser ? MyColors.c_C6A34F : Colors.blueGrey.shade300;

    return Row(
      mainAxisAlignment: messageAlignment,
      children: [
        Flexible(
          flex: 10,
          child: Container(
            margin:  EdgeInsets.only(bottom: 10, left: isCurrentUser ? 20:0, right: isCurrentUser?0:20),
            padding: EdgeInsets.symmetric(horizontal: 10.0.sp, vertical: 5.0.sp),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: backgroundColor,
            ),
            child: Column(
              crossAxisAlignment: textAlignment,
              children: [
              CopyableTextWidget(
                    text:messageModel.text?.trim() ?? '',
                    // "${messageModel.senderDetails?.role}",
                    textStyle: textStyle,
                  ),
                SizedBox(height: 2.w),
              Text(
                  timeago.format( messageModel.dateTime ?? DateTime.now()),
                  style: timestampStyle,
                ),
            ],),
            // child: Column(
            //   crossAxisAlignment: CrossAxisAlignment.end,
            //   children: [
            //     CopyableTextWidget(
            //       text:messageModel.text?.trim() ?? '',
            //       // "${messageModel.senderDetails?.role}",
            //       textStyle: textStyle,
            //     ),
            //      SizedBox(height: 2.w), // Space between message and timestamp
            //     Row(
            //       mainAxisSize: MainAxisSize.min,
            //       mainAxisAlignment: MainAxisAlignment.end,
            //       children: [
            //         Text(
            //           timeago.format( messageModel.dateTime ?? DateTime.now()),
            //           style: timestampStyle,
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/live_chat/controllers/live_chat_controller.dart';

class MessageTypeWidget extends GetWidget<LiveChatController> {
  const MessageTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
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
                  borderRadius: BorderRadius.circular(30.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                        hintText: "Type here...",
                        border: InputBorder.none,
                        fillColor: MyColors.c_C6A34F.withOpacity(0.1),
                        filled: true),
                  ),
                ),
              )),
          const SizedBox(width: 10),
          const Expanded(
            flex: 1,
            child: CircleAvatar(
              backgroundColor: MyColors.c_C6A34F,
              child: Icon(Icons.send, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/style/my_decoration.dart';
import 'package:mh/app/common/values/my_color.dart';
import 'package:mh/app/modules/chat_it/controllers/chat_it_controller.dart';

class ChatUserSearchWidget extends GetWidget<ChatItController> {
  const ChatUserSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MyDecoration.cardBoxDecoration(context: context),
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: TextFormField(
          cursorColor: MyColors.c_C6A34F,
          style: MyColors.l111111_dwhite(context).medium15,
          controller: controller.tecSearch,
          autofocus: false,
          decoration: InputDecoration(
              suffixIcon: Obx(() => Visibility(
                  visible: controller.showClearIcon.value == true,
                  child: InkWell(
                      onTap: controller.clearIconTap,
                      child: const Icon(CupertinoIcons.clear, color: Colors.red, size: 18)))),
              prefixIcon: const Icon(CupertinoIcons.search, color: MyColors.c_C6A34F),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10.0),
              ),
              filled: true,
              fillColor: MyColors.lightCard(context),
              contentPadding: const EdgeInsets.all(15.0),
              border: InputBorder.none,
              hintText: "Search by user name...",
              hintStyle: MyColors.c_7B7B7B.medium15),
          onChanged: controller.onSearchChatUser,
        ),
      ),
    );
  }
}

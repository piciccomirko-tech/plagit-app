import 'package:flutter/cupertino.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';

class ChatUserSearchWidget extends GetWidget<ChatItController> {
  const ChatUserSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.width>600?60:50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: TextFormField(
          cursorColor: MyColors.c_C6A34F,
          style: Get.width>600?MyColors.l111111_dwhite(context).regular10:MyColors.l111111_dwhite(context).regular13,
          controller: controller.tecSearch,
          autofocus: false,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                  color: MyColors.noColor,
                  width: 0.5
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                    color: MyColors.lightGrey,
                    width: 0.5
                ),
              ),
              suffixIcon: Obx(() => Visibility(
                  visible: controller.showClearIcon.value == true,
                  child: InkWell(
                      onTap: controller.clearIconTap,
                      child: const Icon(CupertinoIcons.clear, color: Colors.red, size: 18)))),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(MyAssets.searchIcon),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: MyColors.lightGrey,
                    width: 0.5
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                    color: MyColors.lightGrey,
                    width: 0.5
                ),
                borderRadius: BorderRadius.circular(30.0),
              ),
            filled: true,
              fillColor: MyColors.lightCard(context),
              contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              border: InputBorder.none,
              hintText: MyStrings.searchByName.tr,
              hintStyle: Get.width>600?MyColors.c_7B7B7B.medium10:MyColors.c_7B7B7B.medium15),
          onChanged: controller.onSearchChatUser,
        ),
      ),
    );
  }
}

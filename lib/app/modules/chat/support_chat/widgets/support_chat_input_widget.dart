import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/values/my_assets.dart';
import 'package:mh/app/modules/chat/support_chat/controllers/support_chat_controller.dart';

import '../../../../common/values/my_color.dart';

class SupportChatInputWidget extends GetWidget<SupportChatController> {
  const SupportChatInputWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
      padding: EdgeInsets.only(bottom: controller.appController.bottomPadding.value),
      child: Container(
        padding:  const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20 / 2,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
          color: Get.theme.cardColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 4),
              blurRadius: 32,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Card(
            elevation: 0,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 54.w,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(color: Color.fromRGBO(8, 56, 73, 0.5)),
                        BoxShadow(
                          offset: Offset(0, .5),
                          blurRadius: 1,
                          color: Color(0xFFF9F8F9),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(25),
                      color: MyColors.lnull_d111111(context),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: controller.tecController,
                        cursorColor: MyColors.l111111_dwhite(context),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        style: MyColors.l111111_dwhite(context).regular16,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Message",
                          hintStyle: MyColors.text.regular16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                GestureDetector(
                  onTap: controller.onSendTap,
                  child: Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyColors.c_C6A34F,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: const Offset(-2, 2),
                        child: Image.asset(
                          MyAssets.msgSend,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),
      ),
    ));
  }
}

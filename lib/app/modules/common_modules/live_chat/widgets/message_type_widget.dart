import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/modules/common_modules/live_chat/controllers/live_chat_controller.dart';

import '../../../../helpers/responsive_helper.dart';

class MessageTypeWidget extends GetWidget<LiveChatController> {
  const MessageTypeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0.sp),
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
              flex: ResponsiveHelper.isTab(Get.context)?8:7,
              child: SizedBox(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: TextFormField(
                    minLines: 1,
                    maxLines: 4,
                    style: Get.width > 600
                        ? MyColors.l111111_dwhite(context).medium12
                        : MyColors.l111111_dwhite(context).medium16,
                    controller: controller.tecMessage,
                    decoration: InputDecoration(
                        hintText: MyStrings.typeHere.tr,
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        fillColor: MyColors.c_C6A34F.withOpacity(0.1),
                        filled: true),
                  ),
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
            flex: ResponsiveHelper.isTab(Get.context)?0:1,
            child: Obx(
              () => controller.messageText.trim().isNotEmpty
                  ? InkResponse(
                      onTap: controller.messageText.trim().isNotEmpty
                          ? controller.sendMessage
                          : null,
                      child: const CircleAvatar(
                        backgroundColor: MyColors.c_C6A34F,
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    )
                  : const CircleAvatar(
                      backgroundColor: MyColors.lightGrey,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
            ),
          )
        ],
      ),
    );
  }
}

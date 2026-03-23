import 'package:flutter/foundation.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_appbar.dart';
import 'package:mh/app/modules/common_modules/dialogflow/controllers/dialog_flow_controller.dart';

import 'message_view.dart';

class DialogFlowView extends GetView<DialogFlowController> {
  const DialogFlowView({super.key});
  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return Obx(() => Scaffold(
          appBar: CustomAppbar.appbar(
              title: '${MyStrings.plagIt.tr} ${MyStrings.chatBot.tr}',
              context: context,
              centerTitle: true),
          body: Container(
            decoration: const BoxDecoration(),
            child: Column(
              children: [
                Expanded(
                  child: MessagesScreen(
                    messages: controller.messages,
                    scrollController: controller.scrollController,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: TextFormField(
                            onChanged: (val){
                              if (kDebugMode) {
                                print(val.trim());
                              }
                              if(val.trim().isEmpty){
                                controller.disableSendButton(true);
                              }else{
                                controller.disableSendButton(false);
                              }
                            },
                            controller: controller.controller,
                            style:  Get.width > 600
                                    ? MyColors.l111111_dwhite(context).medium12
                                    : MyColors.l111111_dwhite(context).medium16,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              hintStyle: TextStyle(color:Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              contentPadding: const EdgeInsets.all(12.0),
                            ),
                            onFieldSubmitted: (text) {
                              if (controller.isResponding.value) {
                                null;
                              } else {
                                controller.sendMessage(text);
                                controller.controller.clear();
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      InkResponse(
                        onTap: () {
                          if (controller.isResponding.value) {
                            null;
                          } else {
                            controller.sendMessage(controller.controller.text);
                            controller.controller.clear();
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: controller.isResponding.value?MyColors.lightGrey:MyColors.c_C6A34F,
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                ),
                if (controller.isLoading.value)
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ));
  }
}

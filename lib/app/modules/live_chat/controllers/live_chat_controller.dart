import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/modules/live_chat/models/send_message_request_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class LiveChatController extends GetxController {
  late LiveChatDataTransferModel liveChatDataTransferModel;
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  final AppController _appController = Get.find<AppController>();
  BuildContext? context;
  RxList<MessageModel> messageList = <MessageModel>[].obs;
  RxBool messageLoaded = false.obs;
  late String conversationId;
  TextEditingController tecMessage = TextEditingController();
  @override
  void onInit() {
    liveChatDataTransferModel = Get.arguments;
    _getConversationId();
    super.onInit();
  }

  @override
  void onReady() {
    _getMessagesFromSocket();
    super.onReady();
  }

  @override
  void onClose() {
    tecMessage.dispose();
    Utils.unFocus();
    super.onClose();
  }

  void _getConversationId() {
    ConversationCreateRequestModel conversationCreateRequestModel =
        ConversationCreateRequestModel(isAdmin: true, senderId: liveChatDataTransferModel.toId);
    _apiHelper
        .createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ConversationResponseModel response) {
        if (response.status == "success" && response.statusCode == 201 && response.details != null) {
          conversationId = response.details?.id ?? "";
          _getAllMessages(conversationId: conversationId);
        }
      });
    });
  }

  void _getAllMessages({required String conversationId}) async {
    MessageRequestModel messageRequestModel = MessageRequestModel(conversationId: conversationId, limit: 10, page: 1);
    Either<CustomError, MessageResponseModel> responseData =
        await _apiHelper.getMessages(messageRequestModel: messageRequestModel);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (MessageResponseModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        messageList.value = response.messages ?? [];
        messageList.sort((MessageModel a, MessageModel b) => (a.id ?? "").compareTo(b.id ?? ""));
        messageList.refresh();
        messageLoaded.value = true;
      }
    });
  }

  void sendMessage() {
    SendMessageRequestModel sendMessageRequestModel = SendMessageRequestModel(
        senderId: _appController.user.value.userId,
        conversationId: conversationId,
        dateTime: DateTime.now().toString(),
        text: tecMessage.text);
    _apiHelper.sendMessage(sendMessageRequestModel: sendMessageRequestModel);
  }

  void _getMessagesFromSocket() {
    try {
      Get.find<SocketController>().socket?.on('new_message', (data) async {
        print('LiveChatController._getMessagesFromSocket: ${jsonEncode(data)}');
        messageList.add(MessageModel.fromJson(data));
        messageList.refresh();
        print('LiveChatController._getMessagesFromSocket: ${messageList.length}');
      });
    } catch (_) {}
  }
}

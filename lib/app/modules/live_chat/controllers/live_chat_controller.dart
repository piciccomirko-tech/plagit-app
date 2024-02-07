import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';

class LiveChatController extends GetxController {
  late LiveChatDataTransferModel liveChatDataTransferModel;
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  BuildContext? context;
  RxList<MessageModel> messageList = <MessageModel>[].obs;
  RxBool messageLoaded = false.obs;
  @override
  void onInit() {
    liveChatDataTransferModel = Get.arguments;
    _getConversationId();
    super.onInit();
  }

  @override
  void onClose() {
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
        if (response.status == "success" && response.statusCode == 201) {
          _getMessages(conversationId: response.details?.id ?? "");
        }
      });
    });
  }

  void _getMessages({required String conversationId}) async {
    MessageRequestModel messageRequestModel = MessageRequestModel(conversationId: conversationId, limit: 10, page: 1);
    Either<CustomError, MessageResponseModel> responseData =
        await _apiHelper.getMessages(messageRequestModel: messageRequestModel);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (MessageResponseModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        messageList.value = response.messages ?? [];
        messageLoaded.value = true;
        print('LiveChatController._getMessages:${messageLoaded.value}');
      }
    });
  }
}

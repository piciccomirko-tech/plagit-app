import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/one_to_one_msg.dart';
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
  late ScrollController scrollController;
  int pageNumber = 1;
  RxBool moreMessageAvailable = false.obs;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    liveChatDataTransferModel = Get.arguments;
    _getConversationId();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
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
    scrollController.dispose();
    super.onClose();
  }

  void _getConversationId() {
    ConversationCreateRequestModel conversationCreateRequestModel;
    if (liveChatDataTransferModel.senderId == null) {
      conversationCreateRequestModel =
          ConversationCreateRequestModel(isAdmin: true, senderId: liveChatDataTransferModel.toId);
    } else {
      conversationCreateRequestModel = ConversationCreateRequestModel(
          senderId: liveChatDataTransferModel.senderId,
          receiverId: liveChatDataTransferModel.toId,
          bookedId: liveChatDataTransferModel.bookedId);
    }

    _apiHelper
        .createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ConversationResponseModel response) {
        if (response.status == "success" && response.statusCode == 201 && response.details != null) {
          conversationId = response.details?.id ?? "";
          _getAllMessages();
        }
      });
    });
  }

  void _getAllMessages() async {
    MessageRequestModel messageRequestModel =
        MessageRequestModel(conversationId: conversationId, limit: 20, page: pageNumber);
    Either<CustomError, MessageResponseModel> responseData =
        await _apiHelper.getMessages(messageRequestModel: messageRequestModel);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (MessageResponseModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        messageList.value = response.messages ?? [];
        messageList.refresh();
        messageLoaded.value = true;
      }
    });
  }

  void _getMoreMessages() async {
    MessageRequestModel messageRequestModel =
        MessageRequestModel(conversationId: conversationId, limit: 20, page: pageNumber);
    Either<CustomError, MessageResponseModel> responseData =
        await _apiHelper.getMessages(messageRequestModel: messageRequestModel);
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (MessageResponseModel response) {
      if (response.status == "success" && response.statusCode == 200) {
        if ((response.messages ?? []).isNotEmpty) {
          moreMessageAvailable.value = true;
          messageList.addAll(response.messages ?? []);
          messageList.refresh();
        } else {
          moreMessageAvailable.value = false;
          Utils.showSnackBar(message: 'No message available...', isTrue: false);
        }
      }
    });
  }

  void sendMessage() {
    SendMessageRequestModel sendMessageRequestModel = SendMessageRequestModel(
        senderId: _appController.user.value.userId,
        conversationId: conversationId,
        dateTime: DateTime.now().toString(),
        text: tecMessage.text);
    tecMessage.clear();
    Get.find<SocketController>().socket?.emit('message', sendMessageRequestModel.toJson());
    _apiHelper.sendMessage(sendMessageRequestModel: sendMessageRequestModel);
  }

  void _getMessagesFromSocket() {
    Get.find<SocketController>().socket?.on('message', (data) async {
      MessageModel newMessage = MessageModel.fromJson(data);
      if (conversationId == newMessage.conversationId) {
        messageList.insert(0, newMessage);
        messageList.refresh();
        _scrollToBottom();
        showNotification(newMessage: newMessage);
      }
    });
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollListener() {
    if (scrollController.position.atEdge) {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        pageNumber++;
        _getMoreMessages();
      }
    }
  }

  Future<void> showNotification({required MessageModel newMessage}) async {
  if(newMessage.senderId != Get.find<AppController>().user.value.userId){
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id', // Change this value for different channels
      'your_channel_name', // Change this value for different channels
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'New Message', // Title
      newMessage.text ?? "", // Body
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
  }
}

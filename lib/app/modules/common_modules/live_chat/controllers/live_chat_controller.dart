
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/controller/socket_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/admin/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/client/client_home/controllers/client_home_controller.dart';
import 'package:mh/app/modules/client/client_my_employee/controllers/client_my_employee_controller.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/conversation_create_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/conversation_response_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/message_request_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/message_response_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/send_message_request_model.dart';
import 'package:mh/app/modules/employee/employee_home/controllers/employee_home_controller.dart';
import 'package:mh/app/repository/api_helper.dart';

import '../../../../models/client_edit_profile.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';

class LiveChatController extends GetxController {
  late LiveChatDataTransferModel liveChatDataTransferModel;
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  final AppController appController = Get.find<AppController>();
  BuildContext? context;
  RxList<MessageModel> messageList = <MessageModel>[].obs;
  RxBool messageLoaded = false.obs;
  late String conversationId;
  TextEditingController tecMessage = TextEditingController();
  late ScrollController scrollController;
  int pageNumber = 1;
  RxBool moreMessageAvailable = false.obs;
  RxString messageText = ''.obs; // Rx variable to hold the text value
  final loadingUserInfo=true.obs;
  final clientProfilePicUrl=''.obs;
  final textNeedToBeCopied = ''.obs;
  final toUserTypeIsCandidate=true.obs;

  @override
  void onInit() {
    liveChatDataTransferModel = Get.arguments;
    _getConversationId();
    _getToUserInfo();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
       // Listen to changes in the text field
    tecMessage.addListener(() {
      messageText.value = tecMessage.text;
    });
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
  void setTextForCopy(String text){
    if(text.trim().isEmpty) return;
    textNeedToBeCopied(text);

  }
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: textNeedToBeCopied.value));
    textNeedToBeCopied('');

  }
  void _getConversationId() {
    ConversationCreateRequestModel conversationCreateRequestModel;
    if (liveChatDataTransferModel.senderId == null) {
      conversationCreateRequestModel = ConversationCreateRequestModel(
          isAdmin: true, senderId: liveChatDataTransferModel.toId);
    } else {
      conversationCreateRequestModel = ConversationCreateRequestModel(
          senderId: liveChatDataTransferModel.senderId,
          receiverId: liveChatDataTransferModel.toId,
          bookedId: liveChatDataTransferModel.bookedId);
    }
    if(liveChatDataTransferModel.id == null){
      _apiHelper.createConversation(conversationCreateRequestModel: conversationCreateRequestModel)
          .then((Either<CustomError, ConversationResponseModel> responseData) {
        // log("responsedata: ${responseData.asRight.details?.country}");
        // log("responsedata left: ${responseData.asLeft}");
        responseData.fold((CustomError customError) {
          log("Error: ${customError.msg}");
          // Utils.errorDialog(context!, customError); h
        }, (ConversationResponseModel response) {
          log("Success: ${response.details?.country}");
          log("Success: ${response.details?.id}");
          log("Success: ${response.details?.isAdmin}");
          if (response.status == "success" &&
              response.statusCode == 201 &&
              response.details != null) {
            log("great");
            conversationId = response.details?.id ?? "";
            log("cov id: $conversationId");
            _getAllMessages();
          }
        });
      });
    }else{
      conversationId = liveChatDataTransferModel.id ?? "";
      _getAllMessages();
    }
  }

  void _getAllMessages() async {
    // MessageRequestModel messageRequestModel = MessageRequestModel(
    //     conversationId: liveChatDataTransferModel.id.toString(), limit: 20, page: pageNumber);
    MessageRequestModel messageRequestModel = MessageRequestModel(
        conversationId: conversationId.toString(), limit: 20, page: pageNumber);
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

  void _getToUserInfo() async {
      try {
        loadingUserInfo.value = true;
        Either<CustomError, ClientEditProfileModel> response = await _apiHelper
            .clientDetails(liveChatDataTransferModel.toId);
        response.fold(
              (error) {
                loadingUserInfo.value = false;
          },
              (clientProfile) async {
            if (clientProfile.details == null) {
              loadingUserInfo.value = false;
              return;
            }

            UserDetails details = clientProfile.details!;
            toUserTypeIsCandidate.value=details.employee??false;
            // if(liveChatDataTransferModel.role?.toLowerCase() == "client" ) {
            if(liveChatDataTransferModel.toId==appController.user.value.client?.id || liveChatDataTransferModel.toId==appController.user.value.employee?.id){
              clientProfilePicUrl.value = '';
            }else {
            clientProfilePicUrl.value = details.profilePicture ?? '';
          }
          // }else if(liveChatDataTransferModel.role?.toLowerCase() == "employee" ) {
            //   clientProfilePicUrl.value = details.em ?? '';
            // }
            loadingUserInfo.value = false;
          },
        );
      } catch (_) {
        loadingUserInfo.value = false;
      }

    }

  void _getMoreMessages() async {
    MessageRequestModel messageRequestModel = MessageRequestModel(
        conversationId: conversationId, limit: 20, page: pageNumber);
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
        }
      }
    });
  }

  void sendMessage() {
    if (tecMessage.text.trim().isNotEmpty ) {
      SendMessageRequestModel sendMessageRequestModel = SendMessageRequestModel(
          senderId: appController.user.value.userId,
          conversationId: conversationId,
          dateTime: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
              .format(DateTime.now().toUtc()),
          text: tecMessage.text);
      tecMessage.clear();
      Map<String, dynamic> json = sendMessageRequestModel.toJson();
      if(appController.user.value.isAdmin){
        json["sendByPlagItSupport"] = true;
      }
      Get.find<SocketController>()
          .socket
          ?.emit('message', json);
      _apiHelper.sendMessage(sendMessageRequestModel: sendMessageRequestModel);
    }
  }

  void _getMessagesFromSocket() {
    Get.find<SocketController>().socket?.on('message', (data) async {
      if (data["sendByPlagItSupport"] == true) {
        data["senderDetails"] = {
            "role": "ADMIN"
        };
      }
      MessageModel newMessage = MessageModel.fromJson(data);
      log("new message:"+newMessage.toRawJson())   ;  
       if (conversationId == newMessage.conversationId) {
        messageList.insert(0, newMessage);
        messageList.refresh();
        _scrollToBottom();
      }
    }); 
  }
// Conversion function: from ClientId to SocialUser
  SocialUser clientIdToSocialUser(ClientId clientId) {
    return SocialUser(
      id: clientId.id,
      name: clientId.name ?? clientId.restaurantName,
      positionId: clientId.positionId,
      positionName: clientId.positionName,
      email: clientId.email,
      role: clientId.role,
      profilePicture: clientId.profilePicture,
      countryName: clientId.countryName,
    );
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
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pageNumber++;
        _getMoreMessages();
      }
    }
  }

  void onBackPressed(bool h, f) {
    if(messageLoaded.value == true){
    if (Get.isRegistered<AdminHomeController>()) {
      Get.find<AdminHomeController>().getUnreadMessages();
    } else if (Get.isRegistered<ClientHomeController>()) {
      Get.find<ClientHomeController>().getMessages();
      if (Get.isRegistered<ClientMyEmployeeController>()) {
        Get.find<ClientMyEmployeeController>().getAllHiredEmployees();
      }
    } else if (Get.isRegistered<EmployeeHomeController>()) {
      Get.find<EmployeeHomeController>().getUnreadMessages();
    }
    Get.find<ChatItController>().getConversationList();
    Get.find<ChatItController>().onChatCategoryChange( index: 0);
  } else{
    
  }}
 
}

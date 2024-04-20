import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/chat_it/models/chat_it_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class ChatItController extends GetxController {
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  BuildContext? context;

  RxList<Conversation> conversationList = <Conversation>[].obs;
  RxList<Conversation> filteredConversationList = <Conversation>[].obs;
  RxBool conversationDataLoaded = false.obs;

  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;
  @override
  void onInit() {
    getConversationList();
    super.onInit();
  }

  void getConversationList() async {
    conversationDataLoaded.value = false;
    Either<CustomError, ChatItModel> responseData = await _apiHelper.getConversations();
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ChatItModel response) {
      if ([200, 201].contains(response.statusCode) && response.status == "success") {
        conversationList.value = response.conversations ?? [];
        filteredConversationList = conversationList;
        filteredConversationList.sort((a, b) => b.updatedAt!.compareTo(a.updatedAt!));
        filteredConversationList.refresh();
      }
    });
    conversationDataLoaded.value = true;
  }

  void onUserTapped({required Member member}) => Get.toNamed(Routes.liveChat,
      arguments: LiveChatDataTransferModel(
          toName: member.name ?? "Guest",
          toId: member.id ?? "",
          toProfilePicture: (member.profilePicture ?? "").imageUrl));

  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    Utils.unFocus();
    getConversationList();
  }

  void onAddChatUserPressed() => Get.toNamed(Routes.addChatUser);

  void onSearchChatUser(String query) {
    if (query.isNotEmpty) {
      showClearIcon.value = true;
      List<Conversation> tempList = [];
      tempList.addAll(conversationList);
      filteredConversationList.assignAll(tempList.where((conversation) {
        return conversation.members!.any((member) => member.name!.toLowerCase().contains(query.toLowerCase()));
      }).toList());
    } else {
      getConversationList();
      showClearIcon.value = false;
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter_app_badge_control/flutter_app_badge_control.dart';
import 'package:mh/app/common/controller/app_controller.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/admin/chat_it/models/chat_it_model.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

import '../../../../models/unread_message_response_model.dart';

class ChatItController extends GetxController {
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  BuildContext? context;

  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;

  RxList<ChatCategoryModel> chatCategoryList = <ChatCategoryModel>[
    ChatCategoryModel(title: MyStrings.all, tapped: true),
    ChatCategoryModel(title: MyStrings.unread, tapped: false),
   if(Get.find<AppController>().user.value.client?.client==true ) ChatCategoryModel(title: "Plagit Support", tapped: false)
  ].obs;

  List<Conversation> originalConversationList = []; // Keep this as a field
  RxList<Conversation> conversationList = <Conversation>[].obs;
  RxBool conversationDataLoaded = false.obs;
  int page = 1;
  RxInt conversationsCurrentPage = 1.obs;
  final selectedCatIndex =0.obs;
  final unreadMessages =0.obs;
  ScrollController scrollController = ScrollController();
  RxBool isMoreDataAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    // getConversationList();
    paginateConversation();
    getConversationListAsPagination();
  }

  @override
  void onReady() {
    super.onReady();
  }

  void onSupportClick() => Get.toNamed(Routes.liveChat,
      arguments: LiveChatDataTransferModel(
          toName: "Support",
          toId: Get.find<AppController>().user.value.client?.id ?? "",
          toProfilePicture:
              "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"));

  void onUserTapped({required Member member, required bool isAdmin, required String id}) {
    Get.toNamed(
        Routes.liveChat,
        arguments: LiveChatDataTransferModel(
            id: id,
            role: member.role ?? "",
            toName:
            checkAdmin(isAdmin: isAdmin) ? "Support" : member.name ?? "Guest",
            toId: member.id ?? "",
            toProfilePicture: checkAdmin(isAdmin: isAdmin)
                ? "https://www.iconpacks.net/icons/2/free-chat-support-icon-1721-thumb.png"
                : (member.profilePicture ?? "").imageUrl));
  }

  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    getConversationList();
    Utils.unFocus();
  }

  void onAddChatUserPressed() => Get.toNamed(Routes.addChatUser);

  void onSearchChatUser(String query) {
    if (originalConversationList.isEmpty) {
      originalConversationList.addAll(conversationList);
    }

    if (query.isNotEmpty) {
      showClearIcon.value = true;
      conversationList.assignAll(
        originalConversationList.where((conversation) {
          return conversation.members!.any((member) =>
              (member.name ?? '').toLowerCase().contains(query.toLowerCase()));
        }).toList(),
      );
    } else {
      showClearIcon.value = false;
      conversationList.assignAll(originalConversationList); // Reset to original
    }
  }

  void onLongTapped({required String conversationId}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: MyStrings.areYouSureRemoveConversation.tr,
      onConfirm: () async {
        Get.back();
        CustomLoader.show(context!);
        _apiHelper
            .deleteConversation(conversationId: conversationId)
            .then((Either<CustomError, CommonResponseModel> response) {
          CustomLoader.hide(context!);
          response.fold((CustomError customError) {
            Utils.errorDialog(context!, customError);
          }, (responseModel) {
            if (responseModel.status == "success") {
              Utils.showSnackBar(
                  message: responseModel.message ?? "", isTrue: true);
              getConversationList();
            } else {
              Utils.showSnackBar(
                  message: responseModel.message ?? "", isTrue: false);
            }
          });
        });
      },
      confirmButtonText: MyStrings.remove.tr,
    );
  }

  void onChatCategoryChange({required int index}) {
    selectedCatIndex.value=index;
    for (int i = 0; i < chatCategoryList.length; i++) {
      if(index==2) continue;
      chatCategoryList[i].tapped = i == index;
    }
    chatCategoryList.refresh();
    if (index == 0) {
      // getConversationList();
      getConversationListAsPagination();
    } else if (index == 1) {
      // conversationList.value = conversationList
      //     .where((Conversation value) => value.unreadMsg != 0)
      //     .toList();
      //
      // conversationList.refresh();
      getConversationListAsPagination();
    } else if (index == 2) {
       if(Get.find<AppController>().user.value.client?.client==true ){
      onSupportClick();
       }
    }
  }

  Future<void> getUnreadMessages() async {
    Either<CustomError, UnreadMessageResponseModel> responseData = await _apiHelper.getUnreadMessages();
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (UnreadMessageResponseModel response) {
      if (response.status == "success") {
        unreadMessages.value = response.unreadConversationsCount ?? 0;
        FlutterAppBadgeControl.isAppBadgeSupported().then((value) {
          FlutterAppBadgeControl.updateBadgeCount(unreadMessages.value);
        });
      }
    });
  }

  void paginateConversation() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadNextPage();
        // page++;
        // await getMoreConversation();
        // debugPrint('current $page Getting conv');
      }
    });
  }

  Future<void> getConversationList() async {
    conversationDataLoaded.value = false;
    Either<CustomError, ChatItModel> responseData = await _apiHelper.getConversations();
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ChatItModel response) {
      if ([200, 201].contains(response.statusCode) &&
          response.status == "success") {
        if(selectedCatIndex.value==0){
          conversationList.value = response.conversations ?? [];
        }else if(selectedCatIndex.value==1){
          conversationList.value = (response.conversations ?? []).where((Conversation value) => value.unreadMsg != 0).toList();
        }
        conversationList.sort((a, b) {
          // Provide a default value of DateTime(0) when updatedAt is null
          DateTime aUpdatedAt = a.updatedAt ?? DateTime(0);
          DateTime bUpdatedAt = b.updatedAt ?? DateTime(0);
          return bUpdatedAt.compareTo(aUpdatedAt);  // b comes before a for descending order
        });
        conversationList.refresh();
      }
    });
    conversationDataLoaded.value = true;
  }

  Future<void> getConversationListAsPagination() async {
    conversationDataLoaded.value = false;
    conversationsCurrentPage.value=1;
    getUnreadMessages();
    Either<CustomError, ChatItModel> responseData = await _apiHelper.getConversations(
        limit: 20,
        pageNumber: conversationsCurrentPage.value,
        unread: selectedCatIndex.value==1
    );
    responseData.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (ChatItModel response) {
      if ([200, 201].contains(response.statusCode) &&
          response.status == "success") {
          conversationList.value = response.conversations ?? [];
      }
    });
    conversationDataLoaded.value = true;
  }

  void loadNextPage() async {
      conversationsCurrentPage.value++;
      await getMoreConversationAsPagination();
  }

  Future<void> getMoreConversationAsPagination() async {
    try {
      isMoreDataAvailable.value = true;
      Either<CustomError, ChatItModel> response = await _apiHelper.getConversations(
          pageNumber: conversationsCurrentPage.value,
          limit: 10,
          unread: selectedCatIndex.value==1
      );
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ChatItModel responseModel) {
        if ([200, 201].contains(responseModel.statusCode) &&
            responseModel.status == "success") {
          if (responseModel.conversations!.isNotEmpty) {
            isMoreDataAvailable.value = true;
          } else {
            isMoreDataAvailable.value = false;
          }
          conversationList.addAll(responseModel.conversations ?? []);
          conversationList.refresh();
        }
      });
    } catch (e) {
      isMoreDataAvailable.value = false;
    }
  }

  Future<void> getMoreConversation() async {
    try {
      isMoreDataAvailable.value = true;
      Either<CustomError, ChatItModel> response = await _apiHelper.getConversations(pageNumber: page,limit: 10);
      response.fold((CustomError customError) {
        Utils.errorDialog(context!, customError);
      }, (ChatItModel responseModel) {
        if ([200, 201].contains(responseModel.statusCode) &&
            responseModel.status == "success") {
          if (responseModel.conversations!.isNotEmpty) {
            isMoreDataAvailable.value = true;
          } else {
            isMoreDataAvailable.value = false;
          }
          conversationList.addAll(responseModel.conversations ?? []);
          conversationList.refresh();
        }
      });
    } catch (e) {
      isMoreDataAvailable.value = false;
    }
  }

  Future<void> refreshConversationListOnSocketEvent() async {
    Either<CustomError, ChatItModel> responseData =
        await _apiHelper.getConversations();
    responseData.fold((CustomError customError) {
    }, (ChatItModel response) {
      if ([200, 201].contains(response.statusCode) &&
          response.status == "success") {
        conversationList.value = response.conversations ?? [];
        conversationList.refresh();
      }
    });
  }

  Widget get floatingWidget => Get.find<AppController>().user.value.isAdmin
      ? FloatingActionButton.small(
          backgroundColor: MyColors.c_C6A34F,
          onPressed: onAddChatUserPressed,
          child: const Icon(Icons.add, color: MyColors.white),
        )
      : Wrap();

  bool checkAdmin({required bool isAdmin}) =>
      ((Get.find<AppController>().user.value.isPremiumClient ||
              Get.find<AppController>().user.value.isClient ||
              Get.find<AppController>().user.value.isEmployee) &&
          isAdmin == true);
}

class ChatCategoryModel {
  String title;
  bool tapped;

  ChatCategoryModel({required this.title, required this.tapped});
}

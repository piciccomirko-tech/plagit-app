import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mh/app/common/extensions/extensions.dart';
import 'package:mh/app/common/utils/utils.dart';
import 'package:mh/app/common/values/my_strings.dart';
import 'package:mh/app/common/widgets/custom_dialog.dart';
import 'package:mh/app/common/widgets/custom_loader.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mh/app/modules/chat_it/models/chat_it_model.dart';
import 'package:mh/app/modules/employee/employee_home/models/common_response_model.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class ChatItController extends GetxController {
  final ApiHelper _apiHelper = Get.find<ApiHelper>();
  final AdminHomeController adminHomeController = Get.find<AdminHomeController>();
  BuildContext? context;

  TextEditingController tecSearch = TextEditingController();
  RxBool showClearIcon = false.obs;


  void onUserTapped({required Member member}) => Get.toNamed(Routes.liveChat,
      arguments: LiveChatDataTransferModel(
          toName: member.name ?? "Guest",
          toId: member.id ?? "",
          toProfilePicture: (member.profilePicture ?? "").imageUrl));

  void clearIconTap() {
    tecSearch.clear();
    showClearIcon.value = false;
    Utils.unFocus();
    adminHomeController.homeMethods();
  }

  void onAddChatUserPressed() => Get.toNamed(Routes.addChatUser);

  void onSearchChatUser(String query) {
    if (query.isNotEmpty) {
      showClearIcon.value = true;
      List<Conversation> tempList = [];
      tempList.addAll(adminHomeController.conversationList);
      adminHomeController.conversationList.assignAll(tempList.where((conversation) {
        return conversation.members!.any((member) => member.name!.toLowerCase().contains(query.toLowerCase()));
      }).toList());
    } else {
      adminHomeController.homeMethods();
      showClearIcon.value = false;
    }
  }

  void onLongTapped({required String conversationId}) {
    CustomDialogue.confirmation(
      context: Get.context!,
      title: MyStrings.confirm.tr,
      msg: "Are you sure to remove this conversation?",
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
              Utils.showSnackBar(message: responseModel.message ?? "", isTrue: true);
              adminHomeController.homeMethods();
            } else {
              Utils.showSnackBar(message: responseModel.message ?? "", isTrue: false);
            }
          });
        });
      },
      confirmButtonText: MyStrings.remove.tr,
    );
  }
}

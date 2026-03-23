import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mh/app/modules/common_modules/live_chat/models/live_chat_data_transfer_model.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../models/social_feed_response_model.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../client/client_home_premium/models/job_post_request_model.dart';
import '../../../common_modules/live_chat/models/conversation_create_request_model.dart';
import '../../../common_modules/live_chat/models/conversation_response_model.dart';
import '../../admin_home/controllers/admin_home_controller.dart';

class AdminAllClientsController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final AdminHomeController adminHomeController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  Rx<Employees> clients = Employees().obs;
  RxBool clientsDataLoading = true.obs;
  RxBool isFetching = false.obs;
  var isFetchingId = '0'.obs;

  RxInt currentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreDataAvailable = true.obs;

  @override
  void onInit() {
    _getClients();
    paginateTask();
    super.onInit();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onInit();
  }

  Future<void> _getClients() async {
    clientsDataLoading.value = true;

    Either<CustomError, Employees> response =
        await _apiHelper.getAllUsersFromAdmin(
            requestType: "CLIENT", pageNumber: currentPage.value);
    clientsDataLoading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _getClients);
    }, (Employees clients) {
      this.clients.value = clients;

      for (int i = 0; i < (this.clients.value.users ?? []).length; i++) {
        var item = this.clients.value.users![i];
        if (adminHomeController.chatUserIds.contains(item.id)) {
          this.clients.value.users?.removeAt(i);
          this.clients.value.users?.insert(0, item);
        }
      }

      this.clients.refresh();
    });
  }

  void onChatClick(Employee employee) {
    isFetching.value = true;
    isFetchingId.value = employee.id!;
    ConversationCreateRequestModel conversationCreateRequestModel =
        ConversationCreateRequestModel(
            senderId: Get.find<AppController>().user.value.userId,
            receiverId: employee.id,
            isAdmin: false);
    _apiHelper
        .createConversationWithCandidate(
            conversationCreateRequestModel: conversationCreateRequestModel)
        .then((Either<CustomError, ConversationResponseModel> responseData) {
      responseData.fold((CustomError customError) {
        log("Error: ${customError.msg}");
      }, (ConversationResponseModel response) {
        if (response.status == "success" &&
            response.statusCode == 201 &&
            response.details != null) {
          log("great");
          log("cov id: ${response.details?.id ?? ""}");
          Get.toNamed(Routes.liveChat,
              arguments: LiveChatDataTransferModel(
                  id: response.details?.id,
                  role: employee.role,
                  toName: employee.restaurantName ?? 'Unknown Restaurant',
                  toId: employee.id!,
                  toProfilePicture: (employee.profilePicture ?? "").imageUrl));
        }
      });
      isFetching.value = false;
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
  void paginateTask() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadNextPage();
      }
    });
  }

  void loadNextPage() async {
    currentPage.value++;
    await _getMoreClients();
  }

  Future<void> _getMoreClients() async {
    Either<CustomError, Employees> response =
        await _apiHelper.getAllUsersFromAdmin(
            requestType: "CLIENT", pageNumber: currentPage.value);

    response.fold((CustomError customError) {
      moreDataAvailable.value = false;
      // Utils.showSnackBar(message: 'No more client are here...', isTrue: false);
    }, (Employees clients) {
      if (clients.users!.isNotEmpty) {
        moreDataAvailable.value = true;
      } else {
        moreDataAvailable.value = false;
        //Utils.showSnackBar(message: 'No more client are here...', isTrue: false);
      }
      this.clients.value.users?.addAll(clients.users ?? []);
      this.clients.refresh();
    });
  }
}

import 'package:dartz/dartz.dart';
import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../admin_home/controllers/admin_home_controller.dart';

class AdminAllClientsController extends GetxController {
  BuildContext? context;

  final AppController appController = Get.find();
  final AdminHomeController adminHomeController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  Rx<Employees> clients = Employees().obs;
  RxBool clientsDataLoading = true.obs;

/*  RxInt currentPage = 1.obs;
  final ScrollController scrollController = ScrollController();
  RxBool moreDataAvailable = true.obs;*/

  @override
  void onInit() {
    _getClients();
    // paginateTask();
    super.onInit();
  }

  @override
  void onClose() {
    // scrollController.dispose();
    super.onInit();
  }

  Future<void> _getClients() async {
    clientsDataLoading.value = true;

    Either<CustomError, Employees> response = await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT");
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
    Get.toNamed(Routes.supportChat, arguments: {
      MyStrings.arg.fromId: appController.user.value.userId,
      MyStrings.arg.toId: employee.id ?? "",
      MyStrings.arg.supportChatDocId: employee.id ?? "",
      MyStrings.arg.receiverName: employee.restaurantName ?? "-",
    });
  }

  /* void paginateTask() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
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
        await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT");

    response.fold((CustomError customError) {
      moreDataAvailable.value = false;
      Utils.showSnackBar(message: 'No more client are here...', isTrue: false);
    }, (Employees clients) {
      if (clients.users!.isNotEmpty) {
        moreDataAvailable.value = true;
      } else {
        moreDataAvailable.value = false;
        Utils.showSnackBar(message: 'No more client are here...', isTrue: false);
      }
      this.clients.value.users?.addAll(clients.users ?? []);
      this.clients.refresh();
    });
  }*/
}

import 'package:dartz/dartz.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/repository/api_helper.dart';

class AddChatUserController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final ApiHelper _apiHelper = Get.find();

  Rx<Employees> clients = Employees().obs;
  RxBool clientsDataLoading = true.obs;

  BuildContext? context;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    _getClients();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> _getClients() async {
    clientsDataLoading.value = true;

    Either<CustomError, Employees> response = await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT");
    clientsDataLoading.value = false;

    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (Employees clients) {
      this.clients.value = clients;
      this.clients.refresh();
    });
  }
}

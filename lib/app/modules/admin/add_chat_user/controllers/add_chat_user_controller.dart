import 'package:dartz/dartz.dart';
import 'package:mh/app/common/utils/exports.dart';
import 'package:mh/app/models/custom_error.dart';
import 'package:mh/app/models/employees_by_id.dart';
import 'package:mh/app/modules/chat_it/controllers/chat_it_controller.dart';
import 'package:mh/app/modules/live_chat/models/live_chat_data_transfer_model.dart';
import 'package:mh/app/repository/api_helper.dart';
import 'package:mh/app/routes/app_pages.dart';

class AddChatUserController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final ApiHelper _apiHelper = Get.find();

  Rx<Employees> clients = Employees().obs;
  RxBool clientsDataLoaded = false.obs;
  Rx<Employees> employees = Employees().obs;
  RxBool employeesDataLoaded = false.obs;

  BuildContext? context;

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    _getClients();
    _getEmployees();
  }

  Future<void> _getClients() async {
    Either<CustomError, Employees> response = await _apiHelper.getAllUsersFromAdmin(requestType: "CLIENT");
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (Employees clients) {
      this.clients.value = clients;
      this.clients.refresh();
    });
    clientsDataLoaded.value = true;
  }

  Future<void> _getEmployees() async {
    Either<CustomError, Employees> response = await _apiHelper.getAllUsersFromAdmin(requestType: "EMPLOYEE");
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError);
    }, (Employees emp) {
      employees.value = emp;
      employees.refresh();
    });
    employeesDataLoaded.value = true;
  }

  void onUserTapped({required Employee employee}) {
    Get.toNamed(Routes.liveChat,
        arguments: LiveChatDataTransferModel(
            toName:
                employee.employee == true ? "${employee.firstName}${employee.lastName}" : "${employee.restaurantName}",
            toId: employee.id ?? "",
            toProfilePicture: (employee.profilePicture ?? "").imageUrl));
  }
}

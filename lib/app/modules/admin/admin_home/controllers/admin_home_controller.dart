import 'package:dartz/dartz.dart';
import 'package:mh/app/modules/notifications/controllers/notifications_controller.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/exports.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/requested_employees.dart';
import '../../../../repository/api_helper.dart';
import '../../../../routes/app_pages.dart';

class AdminHomeController extends GetxController {
  final NotificationsController notificationsController = Get.find<NotificationsController>();
  BuildContext? context;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();

  RxBool loading = true.obs;

  Rx<RequestedEmployees> requestedEmployees = RequestedEmployees().obs;

  // unread msg track
  RxInt unreadMsgFromEmployee = 0.obs;
  RxInt unreadMsgFromClient = 0.obs;

  int numberOfRequestFromClient = 0;

  String requestId = '';

  RxList<Map<String, dynamic>> employeeChatDetails = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> clientChatDetails = <Map<String, dynamic>>[].obs;
  RxList<String> chatUserIds = <String>[].obs;

  @override
  void onInit() async {
    await homeMethods();
    super.onInit();
  }

  void onEmployeeClick() {
    Get.toNamed(Routes.adminAllEmployees);
  }

  void onClientClick() {
    Get.toNamed(Routes.adminAllClients);
  }

  void onRequestClick() {
    Get.toNamed(Routes.adminClientRequest);
  }

  void onAdminDashboardClick() {
    Get.toNamed(Routes.adminDashboard);
  }

  int getTotalRequestByPosition(int index) {
    return (requestedEmployees.value.requestEmployeeList?[index].clientRequestDetails ?? [])
        .fold(0, (previousValue, element) => previousValue + (element.numOfEmployee ?? 0));
  }

  int getTotalSuggestByPosition(int index) {
    return requestedEmployees.value.requestEmployeeList?[index].suggestedEmployeeDetails?.length ?? 0;
  }

  int get getTotalSuggestLeft {
    int total = 0;

    for (int i = 0; i < (requestedEmployees.value.requestEmployeeList ?? []).length; i++) {
      total += getTotalRequestByPosition(i) - getTotalSuggestByPosition(i);
    }

    return total;
  }

  Future<void> _fetchRequest() async {
    loading.value = true;
    Either<CustomError, RequestedEmployees> response = await _apiHelper.getRequestedEmployees();
    loading.value = false;
    response.fold((CustomError customError) {
      Utils.errorDialog(context!, customError..onRetry = _fetchRequest);
    }, (RequestedEmployees requestedEmployees) async {
      this.requestedEmployees.value = requestedEmployees;
      this.requestedEmployees.refresh();
      calculateNumberOfRequestFromClient();
    });
  }

  void reloadPage() async {
    await homeMethods();
    Utils.showSnackBar(message: MyStrings.pageRefreshed.tr, isTrue: true);
  }

  Future<void> homeMethods() async {
    notificationsController.getNotificationList();
    await _fetchRequest();
  }

  void calculateNumberOfRequestFromClient() {
    numberOfRequestFromClient = 0;
    for (var i in requestedEmployees.value.requestEmployeeList!) {
      if (i.suggestedEmployeeDetails!.isEmpty) {
        numberOfRequestFromClient += 1;
      }
    }
  }

  void onTodaysEmployeesPressed() {
    Get.toNamed(Routes.adminTodaysEmployees);
  }

  void onChatPressed() {
    Get.toNamed(Routes.chatIt);
  }
}

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/controller/app_controller.dart';
import '../../../../common/utils/utils.dart';
import '../../../../common/widgets/custom_loader.dart';
import '../../../../models/custom_error.dart';
import '../../../../models/employee_full_details.dart';
import '../../../../models/employees_by_id.dart';
import '../../../../models/user_block_unblock_response_model.dart';
import '../../../../repository/api_helper.dart';

class BlockingController extends GetxController {
  BuildContext? context;
  var selectedIndex = 0.obs;
  var isLoading = false.obs;
  var isUnBlocking = false.obs;
  var blockedUserList = <BlockUsersModel>[].obs;

  final AppController appController = Get.find();
  final ApiHelper _apiHelper = Get.find();
  Rx<EmployeeFullDetails> employee = EmployeeFullDetails().obs;

  @override
  void onInit() {
    getBlockingList();
    super.onInit();
  }

  Future<void> getBlockingList() async {
    isLoading(true);
    Either<CustomError, EmployeeFullDetails> response =
        await _apiHelper.employeeFullDetails(appController.user.value.userId);
    response.fold((CustomError l) {
      debugPrint(l.msg);
    }, (r) {
      employee.value = r;
      employee.refresh();
      blockedUserList.clear();
      for (var blockedUser in employee.value.details!.blockUsers!){
        blockedUserList.add(blockedUser);
      }
      isLoading(false);
    });
  }

  void unblockUser(String? userId, int index) {
    CustomLoader.show(context!);
    selectedIndex.value=index;
    debugPrint(userId);
    _apiHelper
        .blockUnblockUser(userId: userId??"", action: 'UNBLOCK')
        .then((Either<CustomError, UserBlockUnblockResponseModel> responseData) {
      CustomLoader.hide(context!);
      getBlockingList();
      responseData.fold((CustomError customError) {
      }, (UserBlockUnblockResponseModel response) async {
        if (response.statusCode == 200) {
          Utils.showSnackBar(message: response.message ?? "", isTrue: true);
        }
      })?.whenComplete(() {
      });
    });
  }
}
